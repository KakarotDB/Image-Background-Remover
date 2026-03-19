# =============================================================================
# Annihilate-BG — PowerShell setup script
# Run from the ROOT of your repository:
#   powershell -ExecutionPolicy Bypass -File setup.ps1
# After running successfully, delete this file before committing.
# =============================================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Annihilate-BG setup starting..." -ForegroundColor Yellow
Write-Host ""

# ── Create directories ────────────────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path ".\css"    | Out-Null
New-Item -ItemType Directory -Force -Path ".\js"     | Out-Null
New-Item -ItemType Directory -Force -Path ".\icons"  | Out-Null
Write-Host "  created: css/ js/ icons/" -ForegroundColor Green

# ── Remove old index.html ─────────────────────────────────────────────────────
if (Test-Path ".\index.html") {
    Remove-Item ".\index.html" -Force
    Write-Host "  removed: old index.html" -ForegroundColor Green
}

# ── Write icons (base64 decoded PNG) ─────────────────────────────────────────
$icon192 = "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"
$icon512 = "iVBORw0KGgoAAAANSUhEUgAAAgAAAAIACAYAAAD0eNT6AAAWgklEQVR4nO3d25EcuREFUIxi/aAV9N8AWkFLRh/cXjaH/aquBJBAnvMlKSRFT09V3luJIvejEebz5/fP2Z8BYGcf3358zP4Mu/BFHiTkAXJSDo7xZT0g7AHWpRA85su5IvAB9qUQ/Kn8lyH0AWqqXghK/vBCH4CLqkWg1A8t+AF4pFIZ2P4HFfoAvGP3MrDtDyf4AYiwaxHY7ocS/AD0sFsR2OaHEfwAjLBLEVj+hxD8AMywehFY9sMLfgAyWLUI/G/2B3iH8Acgi1UzaanWsuqXDEANK20Dlviggh+AVaxSAtJ/SOEPwIqyF4HU7wAIfwBWlT3DUraT7F8aAByRcRuQbgMg/AHYTcZsS1UAMn5BABAhW8alWElk+1IAoJcsxwHTP4TwB6Ci2UVg6hGA8AegqtkZOK0AzP7BAWC2mVk4pQAIfwD4ZVYmDi8Awh8A/jQjG4cWAOEPALeNzshhBUD4A8BjI7NySAEQ/gDwmlGZ2b0ACH/I6+Pbj9kfAbhhRHZ2/UsIhD/kdCv4P39+n/BJgEd6/mVB3TYAwh9yuvfUbxsA+fTM0n96/J8Kf8jnlYC//HdsA2B/XVYLCgDkcebJXhGAHHocBYT/Hwp/yCFypa8IwHzRJSD0HQDhDzlEn+d7PwDmi87YsDYh/GG+EUFtGwBzRW0CurwECIw18gndi4Kwh5AW4ekf5siwmlcEYLyILcDpdwCEP8yRIfxby/M5oJKI7D11BCD8YbyMgetYANZzaoWgAMA4GYP/HkUAxjhzFPD2/1D4wxgrBf81JQDGeLcEDPnHAQPvWTX8W/v12Vf+/LC7t1qDp3/oa8fgtBGAft7ZAhz+Hwh/6GfH4P9KEYA+jpYARwCQRIXwb63OzwnZHWoLnv4hXuVAtA2AWEe2AP4qYJikcvBf+PsDYJ6Xm4Knf4gh+O9TBOC8V7cA3gGAgYT/Y74fGOelluDpH84RbMfZBsD7XtkCeAcAOhL87/N+APT1tCF4+ofjBH8sJQCOe7YF8A4ABBP+8fy1whDvYTvw9A+vE1Dj2AjAax5tAbwDACcJ/vG8HwDnOQKAN1lLz+f7h/fdXQ1Y/8N9gicf2wC47d4xgCMAOEDw5+VYAI652Qo8/cOfBP9alAD4060tgA0APCD412QbAM95CRDuEP7r86Im3PfXSsD6n+oExr5sBKjs6zGADQD8y9Pi/vx+4TcFAJpgqETRg1/+WAdY/1ONIMCxAJVcHwP4UwCUJPi58CcGqMoRAKVY/3KP64JqFADKMOB5RkGkkv/OApz/sysDnXc5FmBHl/cAbADYlqc5znL9sDMvAbIdQ5tIXhJkVzYAbEX404uNEruxAWALBjOj2Aiwi4/WvADIugQ/MykBrOrj248PGwCWJPjJwDaAlXkHgOUIf7LxfgArsgFgGQYs2dkIsBIbANLzdMVqXK+sQAEgNYOUVSmuZOcIgJQMTnbhWICsPvwRQDIR/OxMCSATGwBSEPxUYBtAJt4BYDrhTzXeDyADGwCmMQCpzkaAmWwAGM7TD/zJ/cAMNgAMY8jBfbYBjGYDwBDCH15jQ8YoNgB0ZZDBe2wE6M0GgC48xUAM9xG92AAQyrCCeLYB9GADQBjhD33ZrBFJAeA0QwnGcr8RwREAbzOEYB7HApxlA8BbhD/kYAPHu2wAOMSggZxsBDjKBoCXeMqANbhPeZUNAA8ZJrAe2wBeYQPAXcIf1mZzxyM2APzFwIC92Ahwiw0A//G0AHtzf3PNBgBDAQqxDeDCBqA44Q812fihABTl5gda8xBQmSOAYtzswFeOBWpSAIoQ/MAzikAtjgAKEP7AEY4Ia1AANuYmBs4wP/bmCGBDblogimOBfdkAbEb4Az3YKO7HBmATbkxgBBuBfdgALE4rB2Ywd9ZnA7AoNx8wm23A2mwAFiT8gUxsItekACzETUY0T25EMp/W8vH58/vn7A/BY24qot0KftcZkZTL/BSAxAxkeng0mF1zRFME8lIAkjKIiXZkELv+iKYI5KMAJGPwEu3M4HU9EkkJyEUBSMKgJVrksHV9EkkRyEEBmMxgpYceA9a1SjRFYC4FYCIDlWgjBqrrlkhKwDwKwAQGKNFmDFHXMZEUgfEUgIEMTKLNHpquaaLNvqYrUQAGMCTpIdOgdI0TLdP1vSsFoDODkWiZB6PrnUiZr/UdKACdGIREW2kYuv6JtNK1vxIFIJjBRw8rDkD3AtFWvA8yUwACGXhE22HguS+ItsN9kYECEMCAI9qOA859QqQd75HRFIATDDSi7T7U3DNE2/2e6UkBeIMhRg+VBpl7iGiV7p8oCsBBBhfRKg8u9xORKt9L71AAXmRQEc2w+s39RST31msUgCcMJqIZTre514jmXntMAbjDMKIHA+k59x7R3He3KQA3GEBEM4COcx8SyT34NwXgioFDNEPnHPck0dyTvykAzZChD4MmjnuUaO7P4gXAUKEHg6Uf9yzRKt+vZQuAQUK0yoNkNPcvkareu+UKgMFBtKrDYzb3MtGq3cv/m/0BYGXVBkYmnz+/+/7hhH9mfwBYkeDJ4/K7sBGAY2wA4ABPnXn5vcAxNgDwAuGyBtsAeJ0NADwh/NdjUwPP2QDAHQJkfTYCcJ8NAHzh6XE/fp/wNwUArgiKfSl28CdHANAEfyWOBeAXGwBK81RYl9871dkAUJLhT2u2AdRmA0A5wp+vbIKoyAaAMgx4nrERoBIbALbn6Y6jXC9UYAPAtgxxzrANYHc2AGxJ+BPFBoldKQBsxbCmF9cVu3EEwBYMZ0ZwLMBOFACWJviZQRFgB44AWJbwZzZHTqxMAWA5hi7ZuB5ZkSMAlmHIkpljAVZjA8AShD+rsKFiFQoAqRmmrMp1S3aOAEjJ8GQHjgXITAEgFcHPjhQBMnIEQBrCn9050iITBYDpDEWqcb2TgSMApjEEqcyxALMpAAwn+OE3RYBZHAEwlPCH29wbjGYDwBCGGzxnG8BICgBdCX44ThFgBEcAdCP84Rx/QoaeFADCGVoQy/1ED44ACGNIQT+OBYimAHCa4IdxFAGiOALgFOEPc7j3OMsGgLcYPjCfbQBn2ABwiBf89iI49uC+5B02ALzEcNnLdfBf/rXf8fpsBDjCBoCnBMNe7oWD0NiHe5ZX2ABwlyGyl1cC3jZgH7YBPKMAwObeCQBFAPanAMCmIp78FAHYl3cAYEPRa19rZNiPDQBspGdQ2wbAXhQA2MDIJ3RFAPbgCAAW9vHtx7T1vGMBWJsCAIvKEMAzCwhwjiMAWEzGwHUsAOtRAGARGYP/K0UA1uEIAJJbcc2+2ueFihQASGzlIF2xuEAljgAgoZ2C07EA5KQAQCI7Bf9XigDk4ggAEqi0Lq/yc0J2CgBMVjEQKxUeyMoRAEwiAB0LwEw2ADCYp9+/+T5gPBsAGETIPWYbAGPZAMAAwv91NiQwhg0AdCTI3mcjAH3ZAEAHnmLj+B6hDxsACCSs+rANgHg2ABBE+PdnswJxFAA4SSiN5/uG8xwBwJuE0FyOBeAcBQAOEvy5KALwHkcAcIDwz8tRDByjAMALhMs6/J7gNY4A4AFhsibHAvCcAgA3CP49KAJwnyMA+EL478cRDvxNAYB/CYn9+f3Cb44AKE8o1OJYAH6xAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAghQAAChIAQCAgv6Z/QFgts+f31trrX18+zH5kzDC5fcN1dkAwL8+f34XDpvz+4XfFAD4QkjsR7mDvzkCgBscC+xB6MN9CgA8oAisSfDDc44A4AVWyOvwe4LXKABwgHDJS0mDYxwBwEGOBXIR+vAeBQDepAjMJfjhHEcAcJLV83i+bzhPAYAgQqk/ZQviOAKAQI4F+hD6EM8GADrwpBrH9wh92ABARzYC7xP80JcNAAwgzF5newJj2ADAILYBjwl9GMsGAAbzhPs33weMZwMAk9gICH6YyQYAJqsYgrYgMJ8CAAlUCsQqPydk5wgAEtn5WEDwQy4KACS0UxEQ/JCTIwBIbOXwrHSsAStSACC5FYN0tc8LFTkCgEWscCwg+GEdCgAsJmMREPywHkcAsKgMobvi8QTwiwIAC5sZwIIf1uYIADYw8lhA8MMeFADYSM8iIPhhL44AYEPRYS38YT82ALCpiG2A4Id9KQCwuXeKgOCH/SkA3HUJDGGwh1eKgN/1PjL9PRHk5B0AnjJI9nIv5IX/PtyzvMIGgJfYBuzlehvgd7oPwc8RCgCHKAJ78Xvcg+DnHQoAb1EEYD7BzxneAeAUAwjmcO9xlg0Ap9kGwDiCnygKAGEUAehH8BPNEQDhPr79MKwgkPuJHhQAujG04Bxlmp4cAdCVYwE4TugzggLAEIoAPCf4GckRAEMZcHCb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"
[IO.File]::WriteAllBytes((Resolve-Path ".").Path + "\icons\icon-192.png", [Convert]::FromBase64String($icon192))
Write-Host "  created: icons/icon-192.png" -ForegroundColor Green
[IO.File]::WriteAllBytes((Resolve-Path ".").Path + "\icons\icon-512.png", [Convert]::FromBase64String($icon512))
Write-Host "  created: icons/icon-512.png" -ForegroundColor Green

# ── index.html
$content = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Annihilate-BG — Free Background Remover</title>

  <!-- PWA -->
  <link rel="manifest" href="/manifest.json" />
  <meta name="theme-color" content="#ffe135" />
  <meta name="apple-mobile-web-app-capable" content="yes" />
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
  <meta name="apple-mobile-web-app-title" content="Annihilate-BG" />
  <link rel="apple-touch-icon" href="/icons/icon-192.png" />

  <!-- Favicon -->
  <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Crect width='64' height='64' rx='14' fill='%23ffe135'/%3E%3Cpolygon points='32,10 14,21 14,43 32,54 50,43 50,21' fill='%23000'/%3E%3Cpolygon points='32,20 22,26 22,38 32,44 42,38 42,26' fill='%23ffe135'/%3E%3Cpolygon points='32,27 27,30 27,35 32,38 37,35 37,30' fill='%23000'/%3E%3C/svg%3E" />

  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Unbounded:wght@400;700;900&family=DM+Mono:ital,wght@0,300;0,400;1,300&display=swap" rel="stylesheet" />

  <!-- Styles -->
  <link rel="stylesheet" href="/css/styles.css" />
</head>
<body>
<div class="wrapper">

  <!-- ── Header ── -->
  <header>
    <div class="logo">
      <div class="logo-mark">
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 3L3 8.5V15.5L12 21L21 15.5V8.5L12 3Z" fill="#000" stroke="#000" stroke-width="1.5"/>
          <path d="M12 8L8 10.5V13.5L12 16L16 13.5V10.5L12 8Z" fill="#FFE135"/>
        </svg>
      </div>
      <span class="logo-name">Annihilate<span>-BG</span></span>
    </div>
    <div class="badge">100% Free · No Signup</div>
  </header>

  <!-- ── Hero ── -->
  <div class="hero">
    <div class="hero-eyebrow">AI-Powered · Runs in your browser · Full resolution</div>
    <h1>Remove backgrounds<br /><em>instantly.</em></h1>
    <p>No paywalls. No subscriptions. No watermarks. Your images stay on your device — processed locally at full resolution using AI.</p>
  </div>

  <!-- ── Upload area ── -->
  <div class="upload-area" id="upload-area">
    <div class="dropzone" id="dropzone">
      <div class="dz-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
          <polyline points="17,8 12,3 7,8"/>
          <line x1="12" y1="3" x2="12" y2="15"/>
        </svg>
      </div>
      <div class="dz-title">Drop or paste your images here</div>
      <div class="dz-sub">drag & drop multiple files, Ctrl+V to paste, or click below</div>
      <button class="btn-upload" id="btn-choose" type="button">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
          <polyline points="17,8 12,3 7,8"/>
          <line x1="12" y1="3" x2="12" y2="15"/>
        </svg>
        Choose Images
      </button>
      <div class="formats">Supports · JPG · PNG · WEBP · Multiple files · up to 100MB each</div>
    </div>
    <input type="file" id="file-input" accept="image/png,image/jpeg,image/webp" multiple />
  </div>

  <!-- ── Error banner ── -->
  <div class="error-banner" id="error-banner">
    <div class="error-inner">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" style="flex-shrink:0;margin-top:2px">
        <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
      </svg>
      <div id="error-msg">Something went wrong.</div>
    </div>
  </div>

  <!-- ── Global status panel ── -->
  <div id="status-panel">
    <div class="status-card">
      <div class="status-header">
        <div class="spinner"></div>
        <div class="status-text">
          <strong id="status-title">Loading…</strong>
          <span id="status-sub">Please wait.</span>
        </div>
      </div>
      <div class="progress-bar-wrap">
        <div class="progress-bar" id="progress-bar"></div>
      </div>
    </div>
  </div>

  <!-- ── Queue panel ── -->
  <div id="queue-panel">
    <div class="queue-header">
      <div>
        <div class="queue-title">Processing Queue</div>
        <div class="queue-counter" id="queue-counter"><span>0</span> / 0 complete</div>
      </div>
      <div style="display:flex;gap:10px;align-items:center;flex-wrap:wrap;">
        <!-- Format picker + Download All -->
        <div class="download-group">
          <button class="btn-download-all" id="btn-download-all" disabled>
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
              <polyline points="7,10 12,15 17,10"/><line x1="12" y1="15" x2="12" y2="3"/>
            </svg>
            Download All as ZIP
          </button>
          <select class="fmt-select" id="fmt-select">
            <option value="png">PNG</option>
            <option value="jpg">JPG</option>
            <option value="webp">WEBP</option>
          </select>
        </div>
        <!-- New batch -->
        <button class="btn-action btn-new" id="btn-new-batch" type="button">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <path d="M3 2v6h6"/><path d="M3 13a9 9 0 1 0 3-7.7L3 8"/>
          </svg>
          New Batch
        </button>
      </div>
    </div>

    <!-- Job cards rendered here by main.js -->
    <div class="queue-grid" id="queue-grid"></div>
  </div>

  <!-- ── Feature cards ── -->
  <div class="features">
    <div class="feat-card">
      <div class="feat-icon">🔒</div>
      <div class="feat-title">100% Private</div>
      <div class="feat-desc">Your images never leave your device. All processing runs locally in your browser — no servers involved.</div>
    </div>
    <div class="feat-card">
      <div class="feat-icon">🧠</div>
      <div class="feat-title">Smart Detection</div>
      <div class="feat-desc">Logos and flat graphics use instant flood-fill. Photos use the RMBG-1.4 AI model. Automatically.</div>
    </div>
    <div class="feat-card">
      <div class="feat-icon">📦</div>
      <div class="feat-title">Batch + ZIP Download</div>
      <div class="feat-desc">Upload multiple images at once. Download all results in a single ZIP file when done.</div>
    </div>
  </div>

  <!-- ── Footer ── -->
  <footer>
    <span>Powered by <a href="https://huggingface.co/briaai/RMBG-1.4" target="_blank">RMBG-1.4</a> via <a href="https://github.com/xenova/transformers.js" target="_blank">Transformers.js</a> · Runs entirely in your browser</span>
    <span>No data sent to any server · Ever.</span>
  </footer>

</div>

<!-- Entry point — type="module" enables ES imports -->
<script type="module" src="/js/main.js"></script>
</body>
</html>

'@
Set-Content -Path ".\index.html" -Value $content -Encoding UTF8
Write-Host "  created: index.html"

# ── css/styles.css
$content = @'
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --bg: #06060a;
  --surface: #0f0f16;
  --border: #1e1e2e;
  --accent: #ffe135;
  --accent2: #ff6b35;
  --text: #f0f0f0;
  --muted: #5a5a7a;
  --success: #4fffb0;
  --font-head: 'Unbounded', sans-serif;
  --font-mono: 'DM Mono', monospace;
}

html { height: 100%; }
body { min-height: 100%; background: var(--bg); color: var(--text); font-family: var(--font-mono); overflow-x: hidden; }

/* Grain overlay */
body::before {
  content: ''; position: fixed; inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.04'/%3E%3C/svg%3E");
  background-size: 200px 200px; pointer-events: none; z-index: 9999; opacity: 0.5;
}

/* Grid background */
body::after {
  content: ''; position: fixed; inset: 0;
  background-image: linear-gradient(var(--border) 1px, transparent 1px), linear-gradient(90deg, var(--border) 1px, transparent 1px);
  background-size: 48px 48px; pointer-events: none; z-index: 0; opacity: 0.4;
}

.wrapper { position: relative; z-index: 1; min-height: 100vh; display: flex; flex-direction: column; }

/* ── Header ── */
header { padding: 28px 48px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid var(--border); }
.logo { display: flex; align-items: center; gap: 12px; }
.logo-mark { width: 36px; height: 36px; background: var(--accent); border-radius: 8px; display: grid; place-items: center; flex-shrink: 0; }
.logo-name { font-family: var(--font-head); font-size: 1.1rem; font-weight: 900; letter-spacing: -0.02em; }
.logo-name span { color: var(--accent); }
.badge { font-size: 0.65rem; letter-spacing: 0.12em; text-transform: uppercase; color: var(--success); border: 1px solid var(--success); padding: 4px 10px; border-radius: 100px; opacity: 0.85; }

/* ── Hero ── */
.hero { padding: 72px 48px 48px; text-align: center; max-width: 860px; margin: 0 auto; width: 100%; }
.hero-eyebrow { font-size: 0.7rem; letter-spacing: 0.2em; text-transform: uppercase; color: var(--muted); margin-bottom: 20px; }
.hero h1 { font-family: var(--font-head); font-size: clamp(2.4rem, 5vw, 4.2rem); font-weight: 900; line-height: 1.05; letter-spacing: -0.03em; margin-bottom: 20px; }
.hero h1 em { font-style: normal; color: var(--accent); }
.hero p { color: var(--muted); font-size: 0.95rem; line-height: 1.7; max-width: 500px; margin: 0 auto 48px; }

/* ── Upload area ── */
.upload-area { max-width: 760px; margin: 0 auto; width: 100%; padding: 0 48px 48px; }
.dropzone { border: 2px dashed var(--border); border-radius: 20px; padding: 64px 32px; text-align: center; cursor: pointer; transition: all 0.25s ease; background: var(--surface); position: relative; overflow: hidden; }
.dropzone::before { content: ''; position: absolute; inset: 0; background: radial-gradient(ellipse 60% 40% at 50% 100%, rgba(255,225,53,0.06), transparent); pointer-events: none; }
.dropzone:hover, .dropzone.dragover { border-color: var(--accent); background: #12120e; }
.dropzone.dragover { transform: scale(1.01); }
.dz-icon { width: 64px; height: 64px; margin: 0 auto 20px; background: rgba(255,225,53,0.1); border-radius: 16px; display: grid; place-items: center; border: 1px solid rgba(255,225,53,0.2); }
.dz-icon svg { width: 28px; height: 28px; stroke: var(--accent); }
.dz-title { font-family: var(--font-head); font-size: 1.1rem; font-weight: 700; margin-bottom: 8px; letter-spacing: -0.02em; }
.dz-sub { color: var(--muted); font-size: 0.8rem; margin-bottom: 28px; }
.btn-upload { display: inline-flex; align-items: center; gap: 8px; background: var(--accent); color: #000; font-family: var(--font-head); font-weight: 700; font-size: 0.85rem; letter-spacing: 0.02em; padding: 14px 28px; border-radius: 12px; border: none; cursor: pointer; transition: all 0.2s ease; text-transform: uppercase; }
.btn-upload:hover { background: #fff; transform: translateY(-2px); box-shadow: 0 8px 32px rgba(255,225,53,0.25); }
.formats { margin-top: 20px; font-size: 0.7rem; color: var(--muted); letter-spacing: 0.08em; text-transform: uppercase; }

/* ── Status panel ── */
#status-panel { display: none; max-width: 760px; margin: 0 auto 32px; padding: 0 48px; }
.status-card { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 32px; }
.status-header { display: flex; align-items: center; gap: 14px; margin-bottom: 20px; }
.spinner { width: 28px; height: 28px; border: 2px solid var(--border); border-top-color: var(--accent); border-radius: 50%; animation: spin 0.8s linear infinite; flex-shrink: 0; }
@keyframes spin { to { transform: rotate(360deg); } }
.status-text strong { display: block; font-family: var(--font-head); font-size: 0.95rem; letter-spacing: -0.01em; margin-bottom: 2px; }
.status-text span { color: var(--muted); font-size: 0.78rem; }
.progress-bar-wrap { height: 4px; background: var(--border); border-radius: 100px; overflow: hidden; margin-top: 8px; }
.progress-bar { height: 100%; background: linear-gradient(90deg, var(--accent), var(--accent2)); border-radius: 100px; width: 0%; transition: width 0.4s ease; }

/* ── Queue panel ── */
#queue-panel { display: none; max-width: 1100px; margin: 0 auto 32px; padding: 0 48px; width: 100%; }
.queue-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; flex-wrap: wrap; gap: 12px; }
.queue-title { font-family: var(--font-head); font-size: 0.9rem; font-weight: 700; letter-spacing: -0.01em; }
.queue-counter { font-size: 0.75rem; color: var(--muted); }
.queue-counter span { color: var(--accent); font-weight: 700; }
.btn-download-all { display: inline-flex; align-items: center; gap: 8px; background: var(--accent); color: #000; font-family: var(--font-head); font-weight: 700; font-size: 0.78rem; letter-spacing: 0.02em; padding: 10px 20px; border-radius: 10px; border: none; cursor: pointer; transition: all 0.2s ease; text-transform: uppercase; }
.btn-download-all:hover { background: #fff; }
.btn-download-all:disabled { opacity: 0.4; cursor: not-allowed; }

/* ── Queue grid ── */
.queue-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 16px; }
.queue-item { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; overflow: hidden; transition: border-color 0.2s; }
.queue-item.done  { border-color: rgba(79,255,176,0.25); }
.queue-item.error { border-color: rgba(255,60,60,0.25); }
.queue-item-header { padding: 12px 16px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid var(--border); gap: 8px; }
.queue-item-name { font-size: 0.72rem; color: var(--text); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1; }
.queue-item-status { font-size: 0.62rem; letter-spacing: 0.1em; text-transform: uppercase; padding: 3px 8px; border-radius: 100px; font-family: var(--font-mono); flex-shrink: 0; }
.status-waiting    { color: var(--muted);   border: 1px solid var(--border); }
.status-processing { color: var(--accent);  border: 1px solid rgba(255,225,53,0.3); background: rgba(255,225,53,0.05); }
.status-done       { color: var(--success); border: 1px solid rgba(79,255,176,0.3); background: rgba(79,255,176,0.05); }
.status-error      { color: #ff6b6b;        border: 1px solid rgba(255,60,60,0.3);  background: rgba(255,60,60,0.05); }
.queue-item-images { display: grid; grid-template-columns: 1fr 1fr; gap: 1px; background: var(--border); min-height: 140px; }
.queue-img-wrap { background: var(--surface); display: flex; align-items: center; justify-content: center; position: relative; overflow: hidden; }
.queue-img-wrap img,
.queue-img-wrap canvas { width: 100%; height: 140px; object-fit: contain; display: block; }
.queue-img-wrap canvas { background: repeating-conic-gradient(#1a1a24 0% 25%, #141420 0% 50%) 0 0 / 16px 16px; }
.queue-img-placeholder { width: 100%; height: 140px; display: flex; align-items: center; justify-content: center; }
.queue-img-placeholder svg { opacity: 0.15; }
.queue-item-footer { padding: 10px 16px; display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.queue-item-meta { font-size: 0.65rem; color: var(--muted); }
.queue-item-meta span { color: var(--success); margin-left: 4px; }
.btn-item-download { display: inline-flex; align-items: center; gap: 6px; background: transparent; color: var(--accent); border: 1px solid rgba(255,225,53,0.3); font-family: var(--font-head); font-size: 0.65rem; font-weight: 700; letter-spacing: 0.04em; text-transform: uppercase; padding: 6px 12px; border-radius: 8px; cursor: pointer; transition: all 0.2s; }
.btn-item-download:hover { background: rgba(255,225,53,0.1); }
.btn-item-retry { display: inline-flex; align-items: center; gap: 6px; background: transparent; color: #ff6b6b; border: 1px solid rgba(255,60,60,0.3); font-family: var(--font-head); font-size: 0.65rem; font-weight: 700; letter-spacing: 0.04em; text-transform: uppercase; padding: 6px 12px; border-radius: 8px; cursor: pointer; transition: all 0.2s; }
.btn-item-retry:hover { background: rgba(255,60,60,0.08); }
.method-badge { font-size: 0.58rem; letter-spacing: 0.08em; text-transform: uppercase; padding: 2px 7px; border-radius: 100px; font-family: var(--font-mono); }
.method-badge.flood { color: #4fffb0; border: 1px solid rgba(79,255,176,0.35); background: rgba(79,255,176,0.06); }
.method-badge.ai    { color: #b48fff; border: 1px solid rgba(180,143,255,0.35); background: rgba(180,143,255,0.06); }

/* ── Format select (in queue header) ── */
.download-group { display: flex; align-items: stretch; border-radius: 10px; overflow: hidden; box-shadow: 0 0 0 1px rgba(255,225,53,0.35); }
.download-group:hover { box-shadow: 0 0 0 1px rgba(255,255,255,0.5); }
.fmt-select { appearance: none; -webkit-appearance: none; background: #1c1c10; color: var(--accent); border: none; border-left: 1px solid rgba(255,225,53,0.25); padding: 0 26px 0 10px; font-family: var(--font-head); font-size: 0.72rem; font-weight: 700; letter-spacing: 0.04em; cursor: pointer; outline: none; text-transform: uppercase; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6' viewBox='0 0 10 6'%3E%3Cpath d='M1 1l4 4 4-4' stroke='%23ffe135' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 8px center; transition: background-color 0.2s; }
.fmt-select:hover { background-color: #26260f; }
.fmt-select option { background: #0f0f16; color: var(--text); }

/* ── Buttons ── */
.btn-action { display: inline-flex; align-items: center; gap: 8px; padding: 11px 20px; border-radius: 10px; font-family: var(--font-head); font-size: 0.78rem; font-weight: 700; letter-spacing: 0.02em; text-transform: uppercase; cursor: pointer; border: none; transition: all 0.2s ease; }
.btn-new { background: transparent; color: var(--text); border: 1px solid var(--border); }
.btn-new:hover { border-color: var(--text); background: rgba(255,255,255,0.05); }

/* ── Error ── */
.error-banner { display: none; max-width: 760px; margin: 0 auto 24px; padding: 0 48px; }
.error-inner { background: rgba(255,60,60,0.08); border: 1px solid rgba(255,60,60,0.25); border-radius: 12px; padding: 16px 20px; font-size: 0.82rem; color: #ff6b6b; display: flex; align-items: flex-start; gap: 12px; line-height: 1.5; }
.error-steps { margin-top: 8px; padding-left: 4px; }
.error-steps li { margin-top: 4px; list-style: none; padding-left: 0; }
.error-steps li::before { content: '→ '; opacity: 0.6; }

/* ── Features ── */
.features { max-width: 900px; margin: 0 auto 80px; padding: 0 48px; display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
.feat-card { background: var(--surface); border: 1px solid var(--border); border-radius: 14px; padding: 24px; position: relative; overflow: hidden; }
.feat-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 2px; background: linear-gradient(90deg, var(--accent), transparent); opacity: 0; transition: opacity 0.3s; }
.feat-card:hover::before { opacity: 1; }
.feat-icon { font-size: 1.6rem; margin-bottom: 12px; }
.feat-title { font-family: var(--font-head); font-size: 0.82rem; font-weight: 700; margin-bottom: 8px; letter-spacing: -0.01em; }
.feat-desc { font-size: 0.75rem; color: var(--muted); line-height: 1.6; }

/* ── Footer ── */
footer { border-top: 1px solid var(--border); padding: 24px 48px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
footer span { font-size: 0.72rem; color: var(--muted); }
footer a { color: var(--accent); text-decoration: none; }

/* ── Hidden ── */
#file-input { display: none; }

/* ── Responsive ── */
@media (max-width: 720px) {
  header { padding: 20px 24px; }
  .hero { padding: 48px 24px 32px; }
  .upload-area, #status-panel, #queue-panel { padding: 0 24px; }
  .features { grid-template-columns: 1fr; padding: 0 24px; }
  .queue-grid { grid-template-columns: 1fr; }
}

'@
Set-Content -Path ".\css\styles.css" -Value $content -Encoding UTF8
Write-Host "  created: css/styles.css"

# ── js/main.js
$content = @'
/**
 * main.js
 * Entry point — wires DOM events to the processing queue and updates the UI.
 * Contains zero processing logic — that all lives in the other modules.
 */
import { runQueue, retryJob } from './queue.js';

// ── CDN import for ZIP downloads ──
import JSZip from 'https://cdn.jsdelivr.net/npm/jszip@3.10.1/+esm';

// ── DOM refs ──
const uploadArea   = document.getElementById('upload-area');
const dropzone     = document.getElementById('dropzone');
const fileInput    = document.getElementById('file-input');
const btnChoose    = document.getElementById('btn-choose');
const statusPanel  = document.getElementById('status-panel');
const statusTitle  = document.getElementById('status-title');
const statusSub    = document.getElementById('status-sub');
const progressBar  = document.getElementById('progress-bar');
const queuePanel   = document.getElementById('queue-panel');
const queueGrid    = document.getElementById('queue-grid');
const queueCounter = document.getElementById('queue-counter');
const btnNewBatch  = document.getElementById('btn-new-batch');
const btnDlAll     = document.getElementById('btn-download-all');
const fmtSelect    = document.getElementById('fmt-select');
const errorBanner  = document.getElementById('error-banner');
const errorMsg     = document.getElementById('error-msg');

// ── State ──
let currentJobs = [];
let isProcessing = false;

// ════════════════════════════════════════════════════
// FILE INPUT EVENTS
// ════════════════════════════════════════════════════

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

// Drag & drop
dropzone.addEventListener('dragover', e => { e.preventDefault(); dropzone.classList.add('dragover'); });
dropzone.addEventListener('dragleave', () => dropzone.classList.remove('dragover'));
dropzone.addEventListener('drop', e => {
  e.preventDefault(); dropzone.classList.remove('dragover');
  const files = Array.from(e.dataTransfer.files).filter(f => f.type.startsWith('image/'));
  if (files.length) startBatch(files);
  else showError('Please drop valid image files (JPG, PNG, WEBP).');
});

// Paste
document.addEventListener('paste', e => {
  if (uploadArea.style.display === 'none') return;
  const items = e.clipboardData?.items;
  if (!items) return;
  const files = [];
  for (const item of items) {
    if (item.type.startsWith('image/')) {
      const f = item.getAsFile();
      if (f) files.push(f);
    }
  }
  if (files.length) startBatch(files);
  else showError('No image found in clipboard. Copy an image first, then paste.');
});

// ── New batch button ──
btnNewBatch.addEventListener('click', resetUI);

// ── Download All as ZIP ──
btnDlAll.addEventListener('click', async () => {
  const donJobs = currentJobs.filter(j => j.status === 'done' && j.resultUrl);
  if (!donJobs.length) return;

  btnDlAll.disabled = true;
  btnDlAll.textContent = 'Zipping…';

  const fmt     = fmtSelect.value;
  const mimeMap = { png: 'image/png', jpg: 'image/jpeg', webp: 'image/webp' };
  const mime    = mimeMap[fmt] || 'image/png';
  const zip     = new JSZip();

  await Promise.all(donJobs.map(async job => {
    // Re-encode from the stored PNG object URL to the chosen format
    const blob    = await reencodeBlob(job.resultUrl, mime, fmt === 'jpg' ? 0.95 : undefined);
    const name    = job.file.name.replace(/\.[^.]+$/, '') + '_cutout.' + fmt;
    zip.file(name, blob);
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

// ════════════════════════════════════════════════════
// BATCH START
// ════════════════════════════════════════════════════

async function startBatch(files) {
  if (isProcessing) return;

  const validFiles = files.filter(f => {
    if (f.size > 100 * 1024 * 1024) {
      showError(`"${f.name}" exceeds 100MB and was skipped.`);
      return false;
    }
    return true;
  });

  if (!validFiles.length) return;

  isProcessing = true;
  hideError();
  currentJobs = [];

  uploadArea.style.display  = 'none';
  queuePanel.style.display  = 'block';
  statusPanel.style.display = 'block';
  btnDlAll.disabled         = true;
  queueGrid.innerHTML       = '';

  await runQueue(
    validFiles,
    onJobUpdate,
    onProgress,
    onAllDone
  );
}

// ════════════════════════════════════════════════════
// JOB UPDATE — called by queue.js for each state change
// ════════════════════════════════════════════════════

function onJobUpdate(job) {
  // Update or insert in currentJobs
  const idx = currentJobs.findIndex(j => j.id === job.id);
  if (idx === -1) currentJobs.push(job);
  else currentJobs[idx] = job;

  renderJobCard(job);
  updateCounter();
}

function onProgress(title, sub, pct) {
  statusTitle.textContent  = title;
  statusSub.textContent    = sub;
  progressBar.style.width  = pct + '%';
}

function onAllDone(jobs) {
  isProcessing             = false;
  statusPanel.style.display = 'none';
  progressBar.style.width  = '0%';

  const doneCount = jobs.filter(j => j.status === 'done').length;
  if (doneCount > 0) btnDlAll.disabled = false;
  updateCounter();
}

// ════════════════════════════════════════════════════
// RENDER JOB CARD
// ════════════════════════════════════════════════════

function renderJobCard(job) {
  const existing = document.getElementById(`card-${job.id}`);

  const card = existing || document.createElement('div');
  card.id        = `card-${job.id}`;
  card.className = `queue-item ${job.status}`;

  const statusLabels = {
    waiting:    'Waiting',
    processing: 'Processing…',
    done:       job.method === 'flood' ? '⚡ Done' : '🧠 Done',
    error:      'Failed',
  };

  const methodBadge = job.method
    ? `<span class="method-badge ${job.method}">${job.method === 'flood' ? '⚡ Instant' : '🧠 AI'}</span>`
    : '';

  const resultImgHTML = job.status === 'done' && job.resultUrl
    ? `<div class="queue-img-wrap"><img src="${job.resultUrl}" alt="Result" style="background:repeating-conic-gradient(#1a1a24 0% 25%,#141420 0% 50%) 0 0/16px 16px"/></div>`
    : `<div class="queue-img-wrap queue-img-placeholder">
        <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
          <rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/>
          <polyline points="21,15 16,10 5,21"/>
        </svg>
       </div>`;

  const footerHTML = (() => {
    if (job.status === 'done') {
      return `
        <div class="queue-item-meta">${job.width} × ${job.height}px</div>
        <div style="display:flex;gap:6px;align-items:center">
          ${methodBadge}
          <button class="btn-item-download" data-id="${job.id}">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7,10 12,15 17,10"/>
              <line x1="12" y1="15" x2="12" y2="3"/>
            </svg>
            Save
          </button>
        </div>`;
    }
    if (job.status === 'error') {
      return `
        <div class="queue-item-meta" style="color:#ff6b6b">${job.error || 'Unknown error'}</div>
        <button class="btn-item-retry" data-id="${job.id}">↺ Retry</button>`;
    }
    return `<div class="queue-item-meta">${formatSize(job.file.size)}</div><div>${methodBadge}</div>`;
  })();

  card.innerHTML = `
    <div class="queue-item-header">
      <span class="queue-item-name" title="${job.file.name}">${job.file.name}</span>
      <span class="queue-item-status status-${job.status}">${statusLabels[job.status]}</span>
    </div>
    <div class="queue-item-images">
      <div class="queue-img-wrap">
        <img src="${URL.createObjectURL(job.file)}" alt="Original" />
      </div>
      ${resultImgHTML}
    </div>
    <div class="queue-item-footer">${footerHTML}</div>`;

  // Wire up buttons
  const dlBtn    = card.querySelector('.btn-item-download');
  const retryBtn = card.querySelector('.btn-item-retry');

  if (dlBtn) {
    dlBtn.addEventListener('click', () => downloadSingle(job));
  }
  if (retryBtn) {
    retryBtn.addEventListener('click', async () => {
      await retryJob(job, onJobUpdate, onProgress);
      const doneCount = currentJobs.filter(j => j.status === 'done').length;
      btnDlAll.disabled = doneCount === 0;
    });
  }

  if (!existing) queueGrid.appendChild(card);
}

// ════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════

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
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  });
}

// Re-encode a PNG object URL to the chosen format via canvas
function reencodeBlob(objectUrl, mime, quality) {
  return new Promise(resolve => {
    const img = new Image();
    img.onload = () => {
      const c = document.createElement('canvas');
      c.width = img.naturalWidth; c.height = img.naturalHeight;
      const ctx = c.getContext('2d');
      if (mime !== 'image/png') {
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, c.width, c.height);
      }
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
  progressBar.style.width   = '0%';
  btnDlAll.disabled         = true;
  hideError();
}

function showError(m)  { errorMsg.innerHTML = m; errorBanner.style.display = 'block'; }
function hideError()   { errorBanner.style.display = 'none'; errorMsg.innerHTML = ''; }
function formatSize(b) {
  if (b < 1024)    return b + ' B';
  if (b < 1048576) return (b/1024).toFixed(1) + ' KB';
  return (b/1048576).toFixed(1) + ' MB';
}

'@
Set-Content -Path ".\js\main.js" -Value $content -Encoding UTF8
Write-Host "  created: js/main.js"

# ── js/queue.js
$content = @'
/**
 * queue.js
 * Manages batch processing of multiple images.
 *
 * Strategy:
 *  - Flood-fill jobs (logos/flat graphics): run in parallel — they're instant and CPU-light
 *  - AI jobs (photos): run serially — the model is single-threaded; parallelism would crash
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
 * @property {string|null} resultUrl   — object URL of the processed canvas blob
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

  // ── Phase 1: detect all image types in parallel (fast, just canvas reads) ──
  onProgress('Analysing images…', `Checking ${jobs.length} image${jobs.length > 1 ? 's' : ''}…`, 5);
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
      `Processing… ${doneCount} / ${total} done`,
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

  // ── Phase 2a: flood-fill jobs in parallel ──
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

  // ── Phase 2b: AI jobs serially ──
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

// ── Helper ──
function canvasToObjectURL(canvas) {
  return new Promise(resolve => {
    canvas.toBlob(blob => resolve(URL.createObjectURL(blob)), 'image/png');
  });
}

'@
Set-Content -Path ".\js\queue.js" -Value $content -Encoding UTF8
Write-Host "  created: js/queue.js"

# ── js/detect.js
$content = @'
/**
 * detect.js
 * Analyses an image file and decides whether to use flood-fill or AI.
 *
 * Heuristics run on a 120×120 downscale for speed:
 *  1. Corner consistency  — all 4 corners share a similar colour → solid background
 *  2. Background coverage — >55% of pixels match the corner colour
 *  3. Colour variance     — stdDev < 60 → flat graphic, not a photo
 *
 * All three must agree to return 'flood'. Otherwise returns 'ai'.
 */
export function detectImageType(file) {
  const SAMPLE      = 120;
  const CORNER_TOL  = 35;   // max RGB distance for corners to be "same colour"
  const BG_TOL      = 40;   // max RGB distance for a pixel to "match" background
  const BG_COVER    = 0.55; // fraction of pixels that must match background
  const VAR_THRESH  = 60;   // std-dev threshold — below = flat graphic

  return new Promise(resolve => {
    const img = new Image();

    img.onload = () => {
      const c = document.createElement('canvas');
      c.width = SAMPLE; c.height = SAMPLE;
      const ctx = c.getContext('2d');
      ctx.drawImage(img, 0, 0, SAMPLE, SAMPLE);
      const d = ctx.getImageData(0, 0, SAMPLE, SAMPLE).data;

      const px   = (x, y) => { const i=(y*SAMPLE+x)*4; return [d[i],d[i+1],d[i+2]]; };
      const dist = (a, b)  => Math.sqrt((a[0]-b[0])**2+(a[1]-b[1])**2+(a[2]-b[2])**2);

      // 1. Average 3×3 patch at each corner
      const cornerAvg = (cx, cy) => {
        let r=0,g=0,b=0,n=0;
        for (let dy=-1; dy<=1; dy++) for (let dx=-1; dx<=1; dx++) {
          const [pr,pg,pb] = px(
            Math.min(Math.max(cx+dx,0), SAMPLE-1),
            Math.min(Math.max(cy+dy,0), SAMPLE-1)
          );
          r+=pr; g+=pg; b+=pb; n++;
        }
        return [r/n, g/n, b/n];
      };

      const corners = [
        cornerAvg(0,0), cornerAvg(SAMPLE-1,0),
        cornerAvg(0,SAMPLE-1), cornerAvg(SAMPLE-1,SAMPLE-1)
      ];
      const bgColor          = corners[0];
      const cornersConsistent = corners.every(c => dist(c, bgColor) < CORNER_TOL);

      // 2. Background coverage
      const total = SAMPLE * SAMPLE;
      let bgPixels = 0;
      for (let i=0; i<total; i++) {
        const pi = i*4;
        if (dist([d[pi],d[pi+1],d[pi+2]], bgColor) < BG_TOL) bgPixels++;
      }
      const bgRatio = bgPixels / total;

      // 3. Colour variance
      let sumR=0, sumG=0, sumB=0;
      for (let i=0; i<total; i++) { sumR+=d[i*4]; sumG+=d[i*4+1]; sumB+=d[i*4+2]; }
      const mR=sumR/total, mG=sumG/total, mB=sumB/total;
      let varSum=0;
      for (let i=0; i<total; i++) {
        varSum += (d[i*4]-mR)**2 + (d[i*4+1]-mG)**2 + (d[i*4+2]-mB)**2;
      }
      const stdDev = Math.sqrt(varSum / (total*3));

      const isFlat = cornersConsistent && bgRatio > BG_COVER && stdDev < VAR_THRESH;
      resolve(isFlat ? 'flood' : 'ai');
    };

    img.onerror = () => resolve('ai');
    img.src = URL.createObjectURL(file);
  });
}

'@
Set-Content -Path ".\js\detect.js" -Value $content -Encoding UTF8
Write-Host "  created: js/detect.js"

# ── js/floodFill.js
$content = @'
/**
 * floodFill.js
 * Removes solid-colour backgrounds using a BFS flood fill seeded from all 4 corners.
 * No model required — runs in milliseconds even on large images.
 *
 * Best for: logos, screenshots, illustrations, flat graphics.
 * tolerance: max colour distance a pixel can differ from the seed and still be removed.
 */
export async function floodFillRemoveBg(file, tolerance = 40) {
  const bitmap       = await createImageBitmap(file);
  const { width: W, height: H } = bitmap;

  const c   = document.createElement('canvas');
  c.width   = W; c.height = H;
  const ctx = c.getContext('2d');
  ctx.drawImage(bitmap, 0, 0);

  const imgData = ctx.getImageData(0, 0, W, H);
  const d       = imgData.data;

  const idx  = (x, y)  => (y * W + x) * 4;
  const getC = (x, y)  => { const i=idx(x,y); return [d[i],d[i+1],d[i+2],d[i+3]]; };
  const dist = (a, b)  => Math.sqrt((a[0]-b[0])**2+(a[1]-b[1])**2+(a[2]-b[2])**2);

  // Seed colour = average of the 4 corner pixels
  const corners = [getC(0,0), getC(W-1,0), getC(0,H-1), getC(W-1,H-1)];
  const seed    = corners
    .reduce((acc, c) => [acc[0]+c[0], acc[1]+c[1], acc[2]+c[2]], [0,0,0])
    .map(v => v / 4);

  const visited = new Uint8Array(W * H);
  const queue   = [];

  const enqueue = (x, y) => {
    if (x < 0 || x >= W || y < 0 || y >= H) return;
    const i = y * W + x;
    if (visited[i]) return;
    visited[i] = 1;
    const [r, g, b, a] = getC(x, y);
    if (a === 0 || dist([r,g,b], seed) <= tolerance) queue.push(x, y);
  };

  // Seed from all 4 corners simultaneously
  enqueue(0,   0);
  enqueue(W-1, 0);
  enqueue(0,   H-1);
  enqueue(W-1, H-1);

  // BFS — make each matched pixel transparent
  while (queue.length > 0) {
    const y = queue.pop();
    const x = queue.pop();
    d[idx(x, y) + 3] = 0;
    enqueue(x+1, y); enqueue(x-1, y);
    enqueue(x, y+1); enqueue(x, y-1);
  }

  ctx.putImageData(imgData, 0, 0);
  return { canvas: c, width: W, height: H };
}

'@
Set-Content -Path ".\js\floodFill.js" -Value $content -Encoding UTF8
Write-Host "  created: js/floodFill.js"

# ── js/aiRemoval.js
$content = @'
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
 * Safe to call multiple times — subsequent calls are instant.
 * @param {function} onProgress - called with (title, subtitle, percent)
 */
export async function ensureModel(onProgress) {
  if (model && processor) return;

  onProgress('Downloading AI model…', 'First run only · ~175MB cached locally for future use', 5);

  model = await AutoModel.from_pretrained('briaai/RMBG-1.4', {
    config: { model_type: 'custom' }
  });
  onProgress('Loading processor…', 'Almost ready', 50);

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
  onProgress('Running AI inference…', 'Segmenting foreground — may take a moment on large images', 72);

  const image = await RawImage.fromURL(URL.createObjectURL(file));
  const { pixel_values } = await processor(image);
  const { output }       = await model({ input: pixel_values });

  onProgress('Compositing output…', 'Applying transparency mask at full resolution', 94);

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

'@
Set-Content -Path ".\js\aiRemoval.js" -Value $content -Encoding UTF8
Write-Host "  created: js/aiRemoval.js"

# ── manifest.json
$content = @'
{
  "name": "Annihilate-BG",
  "short_name": "Annihilate-BG",
  "description": "Free AI-powered background remover. Runs entirely in your browser. No signup, no watermarks, full resolution.",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#06060a",
  "theme_color": "#ffe135",
  "orientation": "any",
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}

'@
Set-Content -Path ".\manifest.json" -Value $content -Encoding UTF8
Write-Host "  created: manifest.json"

Write-Host ""
Write-Host "All done! Your project structure:" -ForegroundColor Yellow
Get-ChildItem -Recurse -File | Where-Object { $_.FullName -notmatch "\\.git\\" } | ForEach-Object { Write-Host "  $($_.FullName.Replace((Get-Location).Path + '\\', ''))" }
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. git add ."
Write-Host "  2. git commit -m 'refactor: modular structure + batch processing + PWA'"
Write-Host "  3. git push"
Write-Host "  4. Delete setup.ps1 from your repo after pushing"
Write-Host ""
Write-Host "To test locally before pushing: npx serve ." -ForegroundColor Cyan
