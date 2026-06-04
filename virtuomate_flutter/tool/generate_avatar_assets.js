'use strict';

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

/** Writes minimal solid-color PNGs for offline avatar templates. */
function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let k = 0; k < 8; k++) {
      c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    }
  }
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const t = Buffer.from(type);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([t, data])), 0);
  return Buffer.concat([len, t, data, crc]);
}

function solidPng(width, height, r, g, b) {
  const row = Buffer.alloc(1 + width * 3);
  const raw = Buffer.alloc((1 + width * 3) * height);
  for (let y = 0; y < height; y++) {
    const start = y * row.length;
    raw[start] = 0;
    for (let x = 0; x < width; x++) {
      const i = start + 1 + x * 3;
      raw[i] = r;
      raw[i + 1] = g;
      raw[i + 2] = b;
    }
  }
  const compressed = zlib.deflateSync(raw);
  const sig = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 2;
  return Buffer.concat([
    sig,
    chunk('IHDR', ihdr),
    chunk('IDAT', compressed),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

const palette = {
  neutral: [0x3b, 0xe7, 0xff],
  happy: [0x3c, 0xff, 0xb2],
  thinking: [0x8b, 0x5c, 0xff],
  confident: [0x4a, 0x7d, 0xff],
  nervous: [0xff, 0xd1, 0x66],
  encouraging: [0xd0, 0x5c, 0xff],
  speaking: [0xff, 0x5c, 0x7c],
};

const outDir = path.join(__dirname, '..', 'assets', 'avatars');
fs.mkdirSync(outDir, { recursive: true });

for (const [name, rgb] of Object.entries(palette)) {
  const file = path.join(outDir, `${name}.png`);
  fs.writeFileSync(file, solidPng(256, 256, rgb[0], rgb[1], rgb[2]));
  console.log('wrote', file);
}
