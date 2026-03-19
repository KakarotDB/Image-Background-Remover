/**
 * main.js
 * Entry point -- wires DOM events to the processing queue and updates the UI.
 * Contains zero processing logic -- that all lives in the other modules.
 */
import { runQueue, retryJob, WARN_THRESHOLD, HARD_CAP } from './queue.js';
import JSZip from 'https://cdn.jsdelivr.net/npm/jszip@3.10.1/+esm';

// ====================================================
// WEB WORKER SETUP
// Runs AI inference off the main thread.
// Falls back to null (main-thread fallback) if module workers
// are not supported (e.g. older Safari).
// ====================================================
let aiWorker = null;
try {
  aiWorker = new Worker('/js/worker.js', { type: 'module' });
  aiWorker.onerror = (err) => {
    console.warn('AI worker failed, falling back to main thread:', err);
    aiWorker = null;
  };
} catch (e) {
  console.warn('Module workers not supported (Safari?), falling back to main thread.');
}

// ====================================================
// DOM REFS
// ====================================================
const uploadArea    = document.getElementById('upload-area');
const dropzone      = document.getElementById('dropzone');
const fileInput     = document.getElementById('file-input');
const btnChoose     = document.getElementById('btn-choose');
const warningBanner = document.getElementById('warning-banner');
const warningMsg    = document.getElementById('warning-msg');
const statusPanel   = document.getElementById('status-panel');
const statusTitle   = document.getElementById('status-title');
const statusSub     = document.getElementById('status-sub');
const progressBar   = document.getElementById('progress-bar');
const btnCancel     = document.getElementById('btn-cancel');
const queuePanel    = document.getElementById('queue-panel');
const queueGrid     = document.getElementById('queue-grid');
const queueCounter  = document.getElementById('queue-counter');
const btnNewBatch   = document.getElementById('btn-new-batch');
const btnDlAll      = document.getElementById('btn-download-all');
const fmtSelect     = document.getElementById('fmt-select');
const errorBanner   = document.getElementById('error-banner');
const errorMsg      = document.getElementById('error-msg');

// ====================================================
// STATE
// ====================================================
let currentJobs  = [];
let isProcessing = false;
let cancelSignal = { cancelled: false };

// ====================================================
// FILE INPUT EVENTS
// ====================================================

btnChoose.addEventListener('click', e => { e.stopPropagation(); fileInput.click(); });

dropzone.addEventListener('click', e => {
  if (
    e.target === dropzone ||
    e.target.closest('.dz-icon') ||
    e.target.classList.contains('dz-title') ||
    e.target.classList.contains('dz-sub') ||
    e.target.classList.contains('formats')
  ) fileInput.click();
});

fileInput.addEventListener('change', () => {
  if (fileInput.files.length) startBatch(Array.from(fileInput.files));
});

dropzone.addEventListener('dragover', e => { e.preventDefault(); dropzone.classList.add('dragover'); });
dropzone.addEventListener('dragleave', () => dropzone.classList.remove('dragover'));
dropzone.addEventListener('drop', e => {
  e.preventDefault(); dropzone.classList.remove('dragover');
  const files = Array.from(e.dataTransfer.files).filter(f => f.type.startsWith('image/'));
  if (files.length) startBatch(files);
  else showError('Please drop valid image files (JPG, PNG, WEBP).');
});

document.addEventListener('paste', e => {
  if (uploadArea.style.display === 'none') return;
  const items = e.clipboardData?.items;
  if (!items) return;
  const files = [];
  for (const item of items) {
    if (item.type.startsWith('image/')) { const f = item.getAsFile(); if (f) files.push(f); }
  }
  if (files.length) startBatch(files);
  else showError('No image found in clipboard. Copy an image first, then paste.');
});

// ====================================================
// CANCEL BUTTON
// ====================================================

btnCancel.addEventListener('click', () => {
  if (!isProcessing) return;
  cancelSignal.cancelled = true;
  if (aiWorker) aiWorker.postMessage({ type: 'cancel' });
  btnCancel.disabled    = true;
  btnCancel.textContent = 'Cancelling...';
  statusTitle.textContent = 'Cancelling...';
  statusSub.textContent   = 'Finishing the current image then stopping.';
});

// ====================================================
// OTHER BUTTONS
// ====================================================

btnNewBatch.addEventListener('click', resetUI);

btnDlAll.addEventListener('click', async () => {
  const doneJobs = currentJobs.filter(j => j.status === 'done' && j.resultUrl);
  if (!doneJobs.length) return;

  btnDlAll.disabled     = true;
  btnDlAll.textContent  = 'Zipping...';

  const fmt     = fmtSelect.value;
  const mimeMap = { png: 'image/png', jpg: 'image/jpeg', webp: 'image/webp' };
  const mime    = mimeMap[fmt] || 'image/png';
  const zip     = new JSZip();

  await Promise.all(doneJobs.map(async job => {
    const blob = await reencodeBlob(job.resultUrl, mime, fmt === 'jpg' ? 0.95 : undefined);
    zip.file(job.file.name.replace(/\.[^.]+$/, '') + '_cutout.' + fmt, blob);
  }));

  const zipBlob = await zip.generateAsync({ type: 'blob' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(zipBlob);
  a.download = 'annihilate-bg-results.zip';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);

  btnDlAll.disabled = false;
  btnDlAll.innerHTML = `
    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
      <polyline points="7,10 12,15 17,10"/><line x1="12" y1="15" x2="12" y2="3"/>
    </svg>
    Download All as ZIP`;
});

// ====================================================
// BATCH START
// ====================================================

async function startBatch(files) {
  if (isProcessing) return;

  // Filter oversized files
  const validFiles = files.filter(f => {
    if (f.size > 100 * 1024 * 1024) {
      showError(`"${f.name}" exceeds 100MB and was skipped.`);
      return false;
    }
    return true;
  });
  if (!validFiles.length) return;

  // -- Hard cap --
  if (validFiles.length > HARD_CAP) {
    showError(
      `Too many images (${validFiles.length}). Please select ${HARD_CAP} or fewer at a time ` +
      `to avoid overloading your browser. You can run multiple batches.`
    );
    return;
  }

  // -- Soft warning --
  if (validFiles.length > WARN_THRESHOLD) {
    showWarning(
      `Processing ${validFiles.length} images. ` +
      `Flat graphics will finish instantly. ` +
      `Photos may take a while on slower devices.`
    );
  } else {
    hideWarning();
  }

  isProcessing          = true;
  cancelSignal          = { cancelled: false };
  currentJobs           = [];
  hideError();

  uploadArea.style.display  = 'none';
  queuePanel.style.display  = 'block';
  statusPanel.style.display = 'block';
  btnDlAll.disabled         = true;
  btnCancel.disabled        = false;
  btnCancel.textContent     = 'Cancel';
  queueGrid.innerHTML       = '';

  await runQueue(validFiles, aiWorker, cancelSignal, onJobUpdate, onProgress, onAllDone);
}

// ====================================================
// QUEUE CALLBACKS
// ====================================================

function onJobUpdate(job) {
  const idx = currentJobs.findIndex(j => j.id === job.id);
  if (idx === -1) currentJobs.push(job);
  else currentJobs[idx] = job;
  renderJobCard(job);
  updateCounter();
}

function onProgress(title, sub, pct) {
  if (cancelSignal.cancelled) return; // don't overwrite "Cancelling..." message
  statusTitle.textContent = title;
  statusSub.textContent   = sub;
  progressBar.style.width = pct + '%';
}

function onAllDone(jobs) {
  isProcessing              = false;
  statusPanel.style.display = 'none';
  progressBar.style.width   = '0%';

  const doneCount      = jobs.filter(j => j.status === 'done').length;
  const cancelledCount = jobs.filter(j => j.status === 'cancelled').length;

  if (doneCount > 0) btnDlAll.disabled = false;

  // Show a summary if cancelled mid-batch
  if (cancelledCount > 0) {
    showWarning(
      `Cancelled. ${doneCount} image${doneCount !== 1 ? 's' : ''} completed, ` +
      `${cancelledCount} skipped. You can retry individual images below.`
    );
  }

  updateCounter();
}

// ====================================================
// RENDER JOB CARD
// ====================================================

function renderJobCard(job) {
  const existing = document.getElementById(`card-${job.id}`);
  const card     = existing || document.createElement('div');
  card.id        = `card-${job.id}`;
  card.className = `queue-item ${job.status}`;

  const statusLabels = {
    waiting:    'Waiting',
    processing: 'Processing...',
    done:       job.method === 'flood' ? '\u26A1 Done' : '\uD83E\uDDE0 Done',
    error:      'Failed',
    cancelled:  'Cancelled',
  };

  const methodBadge = job.method
    ? `<span class="method-badge ${job.method}">${job.method === 'flood' ? '\u26A1 Instant' : '\uD83E\uDDE0 AI'}</span>`
    : '';

  const resultImgHTML = job.status === 'done' && job.resultUrl
    ? `<div class="queue-img-wrap">
         <img src="${job.resultUrl}" alt="Result"
              style="background:repeating-conic-gradient(#1a1a24 0% 25%,#141420 0% 50%) 0 0/16px 16px"/>
       </div>`
    : `<div class="queue-img-wrap queue-img-placeholder">
         <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
           <rect x="3" y="3" width="18" height="18" rx="2"/>
           <circle cx="8.5" cy="8.5" r="1.5"/>
           <polyline points="21,15 16,10 5,21"/>
         </svg>
       </div>`;

  const footerHTML = (() => {
    if (job.status === 'done') {
      return `
        <div class="queue-item-meta">${job.width} x ${job.height}px</div>
        <div style="display:flex;gap:6px;align-items:center">
          ${methodBadge}
          <button class="btn-item-download" data-id="${job.id}">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2.5" stroke-linecap="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
              <polyline points="7,10 12,15 17,10"/>
              <line x1="12" y1="15" x2="12" y2="3"/>
            </svg>
            Save
          </button>
        </div>`;
    }
    if (job.status === 'error') {
      return `
        <div class="queue-item-meta" style="color:#ff6b6b">${job.error || 'Unknown error'}</div>
        <button class="btn-item-retry" data-id="${job.id}">&#x21BA; Retry</button>`;
    }
    if (job.status === 'cancelled') {
      return `
        <div class="queue-item-meta">Skipped</div>
        <button class="btn-item-retry" data-id="${job.id}">&#x21BA; Retry</button>`;
    }
    return `<div class="queue-item-meta">${formatSize(job.file.size)}</div><div>${methodBadge}</div>`;
  })();

  card.innerHTML = `
    <div class="queue-item-header">
      <span class="queue-item-name" title="${job.file.name}">${job.file.name}</span>
      <span class="queue-item-status status-${job.status}">${statusLabels[job.status] || job.status}</span>
    </div>
    <div class="queue-item-images">
      <div class="queue-img-wrap">
        <img src="${URL.createObjectURL(job.file)}" alt="Original" />
      </div>
      ${resultImgHTML}
    </div>
    <div class="queue-item-footer">${footerHTML}</div>`;

  const dlBtn    = card.querySelector('.btn-item-download');
  const retryBtn = card.querySelector('.btn-item-retry');

  if (dlBtn) dlBtn.addEventListener('click', () => downloadSingle(job));
  if (retryBtn) {
    retryBtn.addEventListener('click', async () => {
      cancelSignal = { cancelled: false }; // fresh signal for retry
      await retryJob(job, aiWorker, cancelSignal, onJobUpdate, onProgress);
      const doneCount = currentJobs.filter(j => j.status === 'done').length;
      btnDlAll.disabled = doneCount === 0;
    });
  }

  if (!existing) queueGrid.appendChild(card);
}

// ====================================================
// HELPERS
// ====================================================

function updateCounter() {
  const done  = currentJobs.filter(j => j.status === 'done').length;
  const total = currentJobs.length;
  queueCounter.innerHTML = `<span>${done}</span> / ${total} complete`;
}

function downloadSingle(job) {
  if (!job.resultUrl) return;
  const fmt     = fmtSelect.value;
  const mimeMap = { png: 'image/png', jpg: 'image/jpeg', webp: 'image/webp' };
  const mime    = mimeMap[fmt] || 'image/png';
  reencodeBlob(job.resultUrl, mime, fmt === 'jpg' ? 0.95 : undefined).then(blob => {
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = job.file.name.replace(/\.[^.]+$/, '') + '_cutout.' + fmt;
    document.body.appendChild(a); a.click(); document.body.removeChild(a);
  });
}

function reencodeBlob(objectUrl, mime, quality) {
  return new Promise(resolve => {
    const img = new Image();
    img.onload = () => {
      const c = document.createElement('canvas');
      c.width = img.naturalWidth; c.height = img.naturalHeight;
      const ctx = c.getContext('2d');
      if (mime !== 'image/png') { ctx.fillStyle = '#ffffff'; ctx.fillRect(0, 0, c.width, c.height); }
      ctx.drawImage(img, 0, 0);
      c.toBlob(resolve, mime, quality);
    };
    img.src = objectUrl;
  });
}

function resetUI() {
  queuePanel.style.display  = 'none';
  statusPanel.style.display = 'none';
  uploadArea.style.display  = 'block';
  fileInput.value           = '';
  queueGrid.innerHTML       = '';
  currentJobs               = [];
  cancelSignal              = { cancelled: false };
  progressBar.style.width   = '0%';
  btnDlAll.disabled         = true;
  hideError();
  hideWarning();
}

function showError(m)    { errorMsg.innerHTML = m; errorBanner.style.display = 'block'; }
function hideError()     { errorBanner.style.display = 'none'; errorMsg.innerHTML = ''; }
function showWarning(m)  { warningMsg.textContent = m; warningBanner.style.display = 'block'; }
function hideWarning()   { warningBanner.style.display = 'none'; }
function formatSize(b)   {
  if (b < 1024)    return b + ' B';
  if (b < 1048576) return (b/1024).toFixed(1) + ' KB';
  return (b/1048576).toFixed(1) + ' MB';
}
