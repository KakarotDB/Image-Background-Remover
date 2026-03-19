/**
 * queue.js
 * Manages batch processing of multiple images.
 *
 * Strategy:
 *  - Flood-fill jobs (logos/flat graphics): run in parallel â€” they're instant and CPU-light
 *  - AI jobs (photos): run serially â€” the model is single-threaded; parallelism would crash
 *
 * Each job emits status updates via the onJobUpdate callback.
 */
import { detectImageType }          from './detect.js';
import { floodFillRemoveBg }        from './floodFill.js';
import { ensureModel, runAiRemoval } from './aiRemoval.js';

/**
 * @typedef {Object} Job
 * @property {string}      id
 * @property {File}        file
 * @property {'waiting'|'processing'|'done'|'error'} status
 * @property {'flood'|'ai'|null} method
 * @property {string|null} resultUrl   â€” object URL of the processed canvas blob
 * @property {number}      width
 * @property {number}      height
 * @property {string|null} error
 */

/**
 * Creates and runs a processing queue for the given files.
 *
 * @param {File[]}   files
 * @param {function} onJobUpdate  - called with (job: Job) whenever a job changes state
 * @param {function} onProgress   - called with (title, subtitle, percent) for the global status panel
 * @param {function} onAllDone    - called when every job has finished (success or fail)
 */
export async function runQueue(files, onJobUpdate, onProgress, onAllDone) {
  // Build initial job list
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

  // Emit all jobs immediately so the UI can render the queue
  jobs.forEach(j => onJobUpdate({ ...j }));

  // â”€â”€ Phase 1: detect all image types in parallel (fast, just canvas reads) â”€â”€
  onProgress('Analysing imagesâ€¦', `Checking ${jobs.length} image${jobs.length > 1 ? 's' : ''}â€¦`, 5);
  await Promise.all(jobs.map(async job => {
    job.method = await detectImageType(job.file);
  }));

  // Split into two lanes
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
      `Processingâ€¦ ${doneCount} / ${total} done`,
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

  // â”€â”€ Phase 2a: flood-fill jobs in parallel â”€â”€
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

  // â”€â”€ Phase 2b: AI jobs serially â”€â”€
  const runAiJobs = async () => {
    for (const job of aiJobs) {
      try {
        job.status = 'processing';
        onJobUpdate({ ...job });

        // Load model (no-op after first time)
        await ensureModel((title, sub, pct) => onProgress(title, sub, pct));

        const { canvas, width, height } = await runAiRemoval(job.file, (title, sub, pct) =>
          onProgress(`[${job.file.name}] ${title}`, sub, pct)
        );
        const url = await canvasToObjectURL(canvas);
        markDone(job, { url, width, height });
      } catch (err) {
        markError(job, err);
      }
    }
  };

  // Run both lanes concurrently (flood finishes near-instantly, AI runs in background)
  await Promise.all([Promise.all(floodPromises), runAiJobs()]);

  onAllDone(jobs);
}

/**
 * Re-runs a single failed job.
 * @param {Job}      job
 * @param {function} onJobUpdate
 * @param {function} onProgress
 * @returns {Promise<Job>}
 */
export async function retryJob(job, onJobUpdate, onProgress) {
  job.status = 'waiting';
  job.error  = null;
  onJobUpdate({ ...job });

  try {
    job.status = 'processing';
    onJobUpdate({ ...job });

    let canvas, width, height;

    if (job.method === 'flood') {
      ({ canvas, width, height } = await floodFillRemoveBg(job.file));
    } else {
      await ensureModel((t, s, p) => onProgress(t, s, p));
      ({ canvas, width, height } = await runAiRemoval(job.file, (t, s, p) => onProgress(t, s, p)));
    }

    job.status    = 'done';
    job.resultUrl = await canvasToObjectURL(canvas);
    job.width     = width;
    job.height    = height;
    onJobUpdate({ ...job });
  } catch (err) {
    job.status = 'error';
    job.error  = err.message || 'Unknown error';
    onJobUpdate({ ...job });
  }

  return job;
}

// â”€â”€ Helper â”€â”€
function canvasToObjectURL(canvas) {
  return new Promise(resolve => {
    canvas.toBlob(blob => resolve(URL.createObjectURL(blob)), 'image/png');
  });
}

