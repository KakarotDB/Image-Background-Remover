# ✂️ Annihilate-BG — Free AI Background Remover

A fully free, no-paywall, no-signup background remover that runs **entirely in your browser**. No images are ever sent to a server. Full resolution output. No watermarks.

> Built as a better, free alternative to remove.bg — powered by open-source AI.

---

## ✨ Features

- **100% Free** — no subscriptions, no paywalls, no watermarks, ever
- **Full Resolution Output** — exported PNG matches the exact pixel dimensions of your input
- **Private by Design** — all processing happens locally in your browser; your images never leave your device
- **Smart Detection** — automatically uses instant flood-fill for logos and flat graphics, and the AI model for photos
- **Batch Processing** — upload multiple images at once with a live queue showing each image's status
- **Non-blocking UI** — AI inference runs in a Web Worker so the page stays responsive during processing
- **Cancel Anytime** — stop a batch mid-way; completed images are sorted to the top automatically
- **Download All as ZIP** — get all processed images in one click
- **Multiple Export Formats** — save results as PNG, JPG, or WEBP
- **Drag & Drop + Paste** — drop files, paste from clipboard (Ctrl+V), or use the file picker
- **Model Caching** — the AI model (~175MB) downloads once and is cached locally; subsequent runs are near-instant
- **PWA Support** — installable as a home screen app on mobile and desktop
- **Up to 100MB** per file, up to 20 images per batch (soft warning at 11+)

---

## 🧠 How It Works

Annihilate-BG uses two processing paths, chosen automatically per image:

### Path 1 — Flood Fill (logos, flat graphics, screenshots)

Detects solid-colour backgrounds using corner sampling and removes them with a BFS flood fill. Runs in milliseconds. No model download required.

```
User uploads image
       ↓
Heuristic analysis on a 120x120 downscale
(corner consistency + background coverage + colour variance)
       ↓
Flood-fill BFS seeded from all 4 corners
       ↓
Background pixels made transparent
       ↓
Full-resolution transparent PNG ready to download
```

### Path 2 — AI Segmentation (photos, complex images)

Uses **[RMBG-1.4](https://huggingface.co/briaai/RMBG-1.4)** by BRIA AI running via **[Transformers.js](https://github.com/xenova/transformers.js)** (ONNX Runtime / WebAssembly). Inference runs in a Web Worker so the UI never freezes.

```
User uploads image
       ↓
Image transferred to Web Worker as ArrayBuffer
       ↓
RMBG-1.4 runs inference at 1024x1024 internally
       ↓
Mask data transferred back to main thread
       ↓
Mask upscaled to original resolution + composited on Canvas
       ↓
Full-resolution transparent PNG ready to download
```

### Why no resolution is lost

The AI model processes a 1024x1024 version of your image internally, but the resulting mask is upscaled back to your original pixel dimensions before compositing. A 4000x3000px photo stays 4000x3000px in the output.

---

## 🗂️ Project Structure

```
/
├── index.html              # Markup only — no inline JS, no inline CSS
├── manifest.json           # PWA manifest (home screen install, theme colour)
├── css/
│   └── styles.css          # All styles
├── js/
│   ├── main.js             # Entry point — UI events, job cards, ZIP, cancel, modal
│   ├── queue.js            # Batch queue — parallel flood-fill, serial AI via worker
│   ├── worker.js           # Web Worker — runs RMBG-1.4 inference off the main thread
│   ├── detect.js           # Image type heuristics (flood vs AI)
│   ├── floodFill.js        # BFS flood-fill algorithm
│   └── aiRemoval.js        # RMBG-1.4 fallback for browsers without module worker support
└── icons/
    ├── icon-192.png        # PWA icon
    └── icon-512.png        # PWA icon (large)
```

---

## 🖥️ Running Locally

Since the JS files use ES modules (`import`/`export`), they must be served over HTTP — opening `index.html` by double-clicking won't work.

```bash
npx serve .
```

Then open `http://localhost:3000` in your browser.

> Safari may have issues with large WASM files and module Web Workers. Chrome, Edge, Firefox, or Vivaldi are recommended.

---

## 🔢 Batch Limits

| Images selected | Behaviour |
|---|---|
| 1 – 10 | Processed silently |
| 11 – 20 | Yellow warning banner shown, processing continues |
| 21+ | Confirmation modal asks if you want to proceed |

Flat graphics (flood-fill) are essentially free and run in parallel regardless of count. The limits exist to protect users on slower or mobile devices from accidentally queueing dozens of AI photo jobs.

---

## 🛠️ Tech Stack

| Component | Technology |
|---|---|
| AI Model | [RMBG-1.4](https://huggingface.co/briaai/RMBG-1.4) by BRIA AI |
| ML Runtime | [Transformers.js](https://github.com/xenova/transformers.js) v2.17 |
| Inference Engine | ONNX Runtime (WebAssembly) |
| Threading | Web Workers (module type) |
| Flood Fill | Custom BFS canvas algorithm |
| ZIP Export | [JSZip](https://stuk.github.io/jszip/) v3.10 |
| Image Compositing | HTML5 Canvas API |
| Fonts | Unbounded + DM Mono (Google Fonts) |
| Hosting | Static files — Vercel, Netlify, GitHub Pages, anywhere |

---

## 📄 License

The application code in this repository is MIT licensed — free to use, modify, and deploy.

The RMBG-1.4 model is provided by BRIA AI under their own [model license](https://huggingface.co/briaai/RMBG-1.4). It is free for non-commercial use. Please review their terms before using in a commercial product.

---

## 🙋 FAQ

**Does this work offline?**
After the first run (which downloads and caches the AI model), photos work fully offline. Logos and flat graphics always work offline since they use no model.

**Is my image uploaded anywhere?**
No. Everything runs in your browser tab. No network requests are made with your image data at any point during processing.

**Why is the first load slow for photos?**
The RMBG-1.4 model is ~175MB and needs to download once. After that it is cached in your browser and future runs are near-instant. Logos and flat graphics are always instant regardless.

**What is the difference between Instant mode and AI mode?**
Instant mode uses flood-fill — it detects the background colour from the image corners and removes it in milliseconds. AI mode uses the RMBG-1.4 neural network and is better for photos with complex backgrounds.

**Why does the UI stay responsive during processing?**
AI inference runs in a Web Worker — a separate thread — so the main thread (which handles the UI) is never blocked. The spinner animates, cards update, and the cancel button stays clickable throughout.

**Can I cancel a batch?**
Yes. Click the Cancel button during processing. The current image finishes, then the queue stops. Completed images move to the top of the queue automatically.

**What browsers are supported?**
Chrome, Edge, Firefox, and Vivaldi. Safari may work but has known issues with large WASM files and module Web Workers — Chrome is recommended for best results.

**Can I use this commercially?**
The app code is MIT. However, the RMBG-1.4 model has a non-commercial clause — check BRIA AI's license before using in a paid product.
