/**
 * detect.js
 * Analyses an image file and decides whether to use flood-fill or AI.
 *
 * Heuristics run on a 120Ã—120 downscale for speed:
 *  1. Corner consistency  â€” all 4 corners share a similar colour â†’ solid background
 *  2. Background coverage â€” >55% of pixels match the corner colour
 *  3. Colour variance     â€” stdDev < 60 â†’ flat graphic, not a photo
 *
 * All three must agree to return 'flood'. Otherwise returns 'ai'.
 */
export function detectImageType(file) {
  const SAMPLE      = 120;
  const CORNER_TOL  = 35;   // max RGB distance for corners to be "same colour"
  const BG_TOL      = 40;   // max RGB distance for a pixel to "match" background
  const BG_COVER    = 0.55; // fraction of pixels that must match background
  const VAR_THRESH  = 60;   // std-dev threshold â€” below = flat graphic

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

      // 1. Average 3Ã—3 patch at each corner
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

