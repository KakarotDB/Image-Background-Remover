/**
 * floodFill.js
 * Removes solid-colour backgrounds using a BFS flood fill seeded from all 4 corners.
 * No model required â€” runs in milliseconds even on large images.
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

  // BFS â€” make each matched pixel transparent
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
