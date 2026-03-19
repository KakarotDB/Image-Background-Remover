/**
 * aiRemoval.js
 * Loads and caches the RMBG-1.4 model, then runs AI background removal.
 * The model (~175MB) is downloaded once and cached in IndexedDB by Transformers.js.
 *
 * Best for: photographs, complex scenes, hair, animals, products.
 */
import { AutoModel, AutoProcessor, env, RawImage }
  from 'https://cdn.jsdelivr.net/npm/@xenova/transformers@2.17.2/dist/transformers.min.js';

env.allowLocalModels = false;
env.useBrowserCache  = true;

let model     = null;
let processor = null;

/**
 * Loads the model and processor if not already loaded.
 * Safe to call multiple times -- subsequent calls are instant.
 * @param {function} onProgress - called with (title, subtitle, percent)
 */
export async function ensureModel(onProgress) {
  if (model && processor) return;

  onProgress('Downloading AI model\u2026', 'First run only \u00B7 ~175MB cached locally for future use', 5);

  model = await AutoModel.from_pretrained('briaai/RMBG-1.4', {
    config: { model_type: 'custom' }
  });
  onProgress('Loading processor\u2026', 'Almost ready', 50);

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
  onProgress('Model ready', '', 65);
}

/**
 * Runs RMBG-1.4 inference on a file.
 * @param {File} file
 * @param {function} onProgress - called with (title, subtitle, percent)
 * @returns {{ canvas: HTMLCanvasElement, width: number, height: number }}
 */
export async function runAiRemoval(file, onProgress) {
  onProgress('Running AI inference\u2026', 'Segmenting foreground -- may take a moment on large images', 72);

  const image = await RawImage.fromURL(URL.createObjectURL(file));
  const { pixel_values } = await processor(image);
  const { output }       = await model({ input: pixel_values });

  onProgress('Compositing output\u2026', 'Applying transparency mask at full resolution', 94);

  const mask = await RawImage.fromTensor(output[0].mul(255).to('uint8'))
                             .resize(image.width, image.height);

  const canvas    = document.createElement('canvas');
  canvas.width    = image.width;
  canvas.height   = image.height;
  const ctx       = canvas.getContext('2d');
  const imgBitmap = await createImageBitmap(file);
  ctx.drawImage(imgBitmap, 0, 0);

  const imgData = ctx.getImageData(0, 0, image.width, image.height);
  for (let i = 0; i < mask.data.length; i++) {
    imgData.data[4 * i + 3] = mask.data[i];
  }
  ctx.putImageData(imgData, 0, 0);

  return { canvas, width: image.width, height: image.height };
}
