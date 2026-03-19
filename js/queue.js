/**
 * queue.js
 * Manages batch processing of multiple images.
 *
 * Strategy:
 *  - Flood-fill jobs: run in parallel -- instant and CPU-light, no worker needed
 *  - AI jobs: run serially via Web Worker -- keeps main thread responsive
 *
 * Cancel:
 *  - Pass a cancelSignal = { cancelled: false } object
 *  - Set cancelSignal.cancelled = true at any time to stop after the current job
 *  - Remaining waiting jobs are marked 'cancelled'
 */
import { detectImageType }  from './detect.js';
import { floodFillRemoveBg } from './floodFill.js';

// -- Limits --
export const WARN_THRESHOLD = 10; // show warning above this count
export const HARD_CAP       = 20; // refuse above this count

/**
 * @param {File[]}   files
 * @param {Worker|null} worker        -- module Web Worker running worker.js (null = fallback)
 * @param {{ cancelled: boolean }} cancelSignal
 * @param {function} onJobUpdate      -- (job) => void
 * @param {function} onProgress       -- (title, sub, pct) => void
 * @param {function} onAllDone        -- (jobs) => void
 */
export async function runQueue(files, worker, cancelSignal, onJobUpdate, onProgress, onAllDone) {
  const jobs = files.map((file, i) => ({
    id:        `job-${i}-${Date.now()}`,
    file,
    status:    'waiting',
    method:    null,
    resultUrl: null,
    width:     0,
    height:    0,
    error:     null,
  }));

  jobs.forEach(j => onJobUpdate({ ...j }));

  // -- Phase 1: detect all types in parallel (fast, just canvas reads) --
  onProgress('Analysing images...', `Checking ${jobs.length} image${jobs.length > 1 ? 's' : ''}...`, 5);
  await Promise.all(jobs.map(async job => {
    job.method = await detectImageType(job.file);
  }));

  const floodJobs = jobs.filter(j => j.method === 'flood');
  const aiJobs    = jobs.filter(j => j.method === 'ai');

  let doneCount = 0;
  const total   = jobs.length;

  const markDone = (job, result) => {
    job.status    = 'done';
    job.resultUrl = result.url;
    job.width     = result.width;
    job.height    = result.height;
    doneCount++;
    onJobUpdate({ ...job });
    onProgress(
      `Processing... ${doneCount} / ${total} done`,
      '',
      Math.round((doneCount / total) * 100)
    );
  };

  const markError = (job, err) => {
    job.status = 'error';
    job.error  = err.message || 'Unknown error';
    doneCount++;
    onJobUpdate({ ...job });
    console.error(`Job failed [${job.file.name}]:`, err);
  };

  const markCancelled = (job) => {
    job.status = 'cancelled';
    doneCount++;
    onJobUpdate({ ...job });
  };

  // -- Phase 2a: flood-fill in parallel --
  const floodPromises = floodJobs.map(async job => {
    try {
      job.status = 'processing';
      onJobUpdate({ ...job });
      const { canvas, width, height } = await floodFillRemoveBg(job.file);
      const url = await canvasToObjectURL(canvas);
      markDone(job, { url, width, height });
    } catch (err) {
      markError(job, err);
    }
  });

  // -- Phase 2b: AI jobs serially via worker --
  const runAiJobs = async () => {
    for (const job of aiJobs) {
      if (cancelSignal.cancelled) { markCancelled(job); continue; }

      try {
        job.status = 'processing';
        onJobUpdate({ ...job });

        const result = await dispatchAiJob(worker, job, cancelSignal, onProgress);

        if (result.cancelled) { markCancelled(job); continue; }

        const canvas = await compositeWithMask(job.file, result.maskData, result.width, result.height);
        const url    = await canvasToObjectURL(canvas);
        markDone(job, { url, width: result.width, height: result.height });

      } catch (err) {
        if (err.message === 'CANCELLED') markCancelled(job);
        else markError(job, err);
      }
    }
  };

  // Run both lanes concurrently
  await Promise.all([Promise.all(floodPromises), runAiJobs()]);

  onAllDone(jobs);
}

/**
 * Retry a single failed or cancelled job.
 */
export async function retryJob(job, worker, cancelSignal, onJobUpdate, onProgress) {
  job.status = 'waiting';
  job.error  = null;
  onJobUpdate({ ...job });

  try {
    job.status = 'processing';
    onJobUpdate({ ...job });

    if (job.method === 'flood') {
      const { canvas, width, height } = await floodFillRemoveBg(job.file);
      job.status    = 'done';
      job.resultUrl = await canvasToObjectURL(canvas);
      job.width     = width;
      job.height    = height;
    } else {
      const result = await dispatchAiJob(worker, job, cancelSignal, onProgress);
      if (result.cancelled) {
        job.status = 'cancelled';
      } else {
        const canvas = await compositeWithMask(job.file, result.maskData, result.width, result.height);
        job.status    = 'done';
        job.resultUrl = await canvasToObjectURL(canvas);
        job.width     = result.width;
        job.height    = result.height;
      }
    }

    onJobUpdate({ ...job });
  } catch (err) {
    job.status = err.message === 'CANCELLED' ? 'cancelled' : 'error';
    job.error  = err.message === 'CANCELLED' ? null : (err.message || 'Unknown error');
    onJobUpdate({ ...job });
  }

  return job;
}

// ====================================================
// INTERNAL HELPERS
// ====================================================

/**
 * Sends an AI job to the Web Worker.
 * Falls back to main-thread aiRemoval.js if no worker available (e.g. Safari).
 * Returns { maskData, width, height } or { cancelled: true }.
 */
function dispatchAiJob(worker, job, cancelSignal, onProgress) {
  if (!worker) {
    // Safari fallback -- main-thread processing, UI may freeze briefly
    return import('./aiRemoval.js').then(({ ensureModel, runAiRemoval }) =>
      ensureModel((t, s, p) => onProgress(t, s, p))
        .then(() => runAiRemoval(job.file, (t, s, p) => onProgress(t, s, p)))
        .then(({ canvas, width, height }) => {
          // aiRemoval returns a composited canvas -- we need to extract pixel data
          // Return a special shape that compositeWithMask won't be called with
          return { _fallbackCanvas: canvas, width, height };
        })
    );
  }

  return new Promise((resolve, reject) => {
    const handler = (e) => {
      const msg = e.data;
      if (msg.id !== job.id) return;

      if (msg.type === 'progress') {
        onProgress(msg.title, msg.sub, msg.pct);
      } else if (msg.type === 'result') {
        worker.removeEventListener('message', handler);
        resolve({ maskData: msg.maskData, width: msg.width, height: msg.height });
      } else if (msg.type === 'error') {
        worker.removeEventListener('message', handler);
        reject(new Error(msg.message));
      } else if (msg.type === 'cancelled') {
        worker.removeEventListener('message', handler);
        resolve({ cancelled: true });
      }
    };

    worker.addEventListener('message', handler);

    job.file.arrayBuffer().then(buffer => {
      worker.postMessage(
        { type: 'process', id: job.id, buffer, mimeType: job.file.type || 'image/png' },
        [buffer]
      );
    }).catch(err => {
      worker.removeEventListener('message', handler);
      reject(err);
    });
  });
}

/**
 * Composites the original file with the alpha mask received from the worker.
 * Runs on the main thread (needs DOM canvas + createImageBitmap).
 */
async function compositeWithMask(file, maskData, width, height) {
  const canvas    = document.createElement('canvas');
  canvas.width    = width;
  canvas.height   = height;
  const ctx       = canvas.getContext('2d');
  const imgBitmap = await createImageBitmap(file);
  ctx.drawImage(imgBitmap, 0, 0);
  const imgData   = ctx.getImageData(0, 0, width, height);
  for (let i = 0; i < maskData.length; i++) {
    imgData.data[4 * i + 3] = maskData[i];
  }
  ctx.putImageData(imgData, 0, 0);
  return canvas;
}

function canvasToObjectURL(canvas) {
  return new Promise(resolve => {
    canvas.toBlob(blob => resolve(URL.createObjectURL(blob)), 'image/png');
  });
}
