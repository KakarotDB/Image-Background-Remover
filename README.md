# ✂️ Annihilate BG - Free AI Background Remover

A fully free, no-paywall, no-signup background remover that runs **entirely in your browser**. No images are ever sent to a server. Full resolution output. No watermarks.

> Built as a better, free alternative to remove.bg — powered by open-source AI.

---

## ✨ Features

- **100% Free** — no subscriptions, no paywalls, no watermarks, ever
- **Full Resolution Output** — exported PNG matches the exact pixel dimensions of your input
- **Private by Design** — all processing happens locally in your browser; your images never leave your device
- **No Install Required** — just open the HTML file in any modern browser
- **Model Caching** — the AI model (~175MB) downloads once on first use and is cached locally; subsequent runs are near-instant
- **Drag & Drop** — drop an image or use the file picker
- **Side-by-side Comparison** — view original vs. result before downloading
- **Up to 100MB** file size support

---

## 🧠 How It Works

CutOut uses **[RMBG-1.4](https://huggingface.co/briaai/RMBG-1.4)** — a state-of-the-art image segmentation model by BRIA AI — running locally via **[Transformers.js](https://github.com/xenova/transformers.js)** (HuggingFace's WebAssembly/ONNX browser runtime).

### Processing Pipeline

```
User uploads image
       ↓
Image is read as RawImage (never uploaded anywhere)
       ↓
RMBG-1.4 model runs inference at 1024×1024 internally
       ↓
Output mask is upscaled back to original image resolution
       ↓
Mask is applied as alpha channel on an HTML5 Canvas
       ↓
Full-resolution transparent PNG is ready to download
```

### Why no resolution is lost

The AI model processes a 1024×1024 version of your image internally (standard for segmentation models), but the resulting **mask is upscaled back to your original image's full pixel dimensions** before being applied. The final compositing is done directly on a canvas at native resolution — so a 4000×3000px photo stays 4000×3000px in the output.

---

## 🗂️ Project Structure

```
/
├── index.html       # The entire app — one self-contained HTML file
└── README.md        # This file
```

No dependencies to install, no build steps, no Node.js required. It's a single HTML file.

---

## 🖥️ Running Locally

1. Download `index.html`
2. Double-click it to open in Chrome, Firefox, Vivaldi, or Edge
3. On first use, it will fetch the AI model (~175MB) from HuggingFace — **internet required for first run only**
4. After that, it works fully offline

> ⚠️ Safari may have issues with large WASM files due to stricter memory limits. Chrome or Vivaldi is recommended.

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| AI Model | [RMBG-1.4](https://huggingface.co/briaai/RMBG-1.4) by BRIA AI |
| ML Runtime | [Transformers.js](https://github.com/xenova/transformers.js) v2.17 |
| Inference Engine | ONNX Runtime (WebAssembly) |
| Image Compositing | HTML5 Canvas API |
| Fonts | Unbounded + DM Mono (Google Fonts) |
| Hosting | Static HTML — works anywhere |

---

## 📄 License

The application code in this repository is MIT licensed — free to use, modify, and deploy.

The RMBG-1.4 model is provided by BRIA AI under their own [model license](https://huggingface.co/briaai/RMBG-1.4). It is free for non-commercial use. Please review their terms before using this in a commercial product.

---

## 🙋 FAQ

**Does this work offline?**
Yes — after the first run (which downloads and caches the model), it works fully offline.

**Is my image uploaded anywhere?**
No. Everything runs in your browser tab. No network requests are made with your image data.

**Why is the first load slow?**
The RMBG-1.4 model is ~175MB and needs to be downloaded once. After that it's cached by your browser.

**What browsers are supported?**
Chrome, Edge, Firefox, and Vivaldi. Safari may work but has stricter WASM memory limits.

**Can I use this commercially?**
The app code is MIT. However, the RMBG-1.4 model has a non-commercial clause — check BRIA AI's license before using in a paid product.
