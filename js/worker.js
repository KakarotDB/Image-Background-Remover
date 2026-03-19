/**
 * worker.js
 * Runs RMBG-1.4 AI inference in a Web Worker so the main thread stays responsive.
 *
 * Message protocol (main -> worker):
 *   { type: 'process', id, buffer: ArrayBuffer, mimeType: string }
 *   { type: 'cancel' }
 *
 * Message protocol (worker -> main):
 *   { type: 'progress', id, title, sub, pct }
 *   { type: 'result',   id, maskData: Uint8Array, width, height }
 *   { type: 'error',    id, message }
 *   { type: 'cancelled', id }
 */
import { AutoModel, AutoProcessor, env, RawImage }
  from 'https://cdn.jsdelivr.net/npm/@xenova/transformers@2.17.2/dist/transformers.min.js';

env.allowLocalModels = false;
env.useBrowserCache  = true;

let model       = null;
let processor   = null;
let cancelled   = false;
let currentId   = null;

self.onmessage = async (e) => {
  const msg = e.data;

  if (msg.type === 'cancel') {
    cancelled = true;
    return;
  }

  if (msg.type === 'process') {
    cancelled  = false;
    currentId  = msg.id;

    try {
      // -- Load model (no-op if already loaded) --
      await ensureModel(msg.id);
      if (cancelled) { self.postMessage({ type: 'cancelled', id: msg.id }); return; }

      // -- Decode image from transferred ArrayBuffer --
      const blob  = new Blob([msg.buffer], { type: msg.mimeType });
      const url   = URL.createObjectURL(blob);
      const image = await RawImage.fromURL(url);
      URL.revokeObjectURL(url);

      if (cancelled) { self.postMessage({ type: 'cancelled', id: msg.id }); return; }

      progress(msg.id, 'Running AI inference...', 'Segmenting foreground from background', 72);

      // -- Inference --
      const { pixel_values } = await processor(image);
      const { output }       = await model({ input: pixel_values });

      if (cancelled) { self.postMessage({ type: 'cancelled', id: msg.id }); return; }

      progress(msg.id, 'Compositing...', 'Upscaling mask to original resolution', 94);

      // -- Build mask at original resolution --
      const mask     = await RawImage.fromTensor(output[0].mul(255).to('uint8'))
                                     .resize(image.width, image.height);
      // Copy to independent buffer before transferring (avoids detaching shared memory)
      const maskCopy = new Uint8Array(mask.data);

      self.postMessage(
        { type: 'result', id: msg.id, maskData: maskCopy, width: image.width, height: image.height },
        [maskCopy.buffer]
      );

    } catch (err) {
      self.postMessage({ type: 'error', id: msg.id, message: err.message || 'Unknown error' });
    }
  }
};

async function ensureModel(id) {
  if (model && processor) return;

  progress(id, 'Downloading AI model...', 'First run only - ~175MB cached locally for future use', 5);

  model = await AutoModel.from_pretrained('briaai/RMBG-1.4', {
    config: { model_type: 'custom' }
  });

  progress(id, 'Loading processor...', 'Almost ready', 50);

  processor = await AutoProcessor.from_pretrained('briaai/RMBG-1.4', {
    config: {
      do_normalize:           true,
      do_pad:                 false,
      do_rescale:             true,
      do_resize:              true,
      image_mean:             [0.5, 0.5, 0.5],
      feature_extractor_type: 'ImageFeatureExtractor',
      image_std:              [1, 1, 1],
      resample:               2,
      rescale_factor:         0.00392156862745098,
      size:                   { width: 1024, height: 1024 },
    }
  });

  progress(id, 'Model ready', '', 65);
}

function progress(id, title, sub, pct) {
  self.postMessage({ type: 'progress', id, title, sub, pct });
}
