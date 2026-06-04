'use strict';

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const root = path.join(__dirname, '..');

const defaultSrc = path.join(
  process.env.USERPROFILE || '',
  '.cursor',
  'projects',
  'd-Virtomate-Project-virtuomate-flutter',
  'assets',
  'c__Users_SHAHAB_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_image-73742e94-793e-436c-a984-47c43b92e2aa.png',
);

const src = process.env.LOGO_SRC || defaultSrc;

const targets = [
  path.join(root, 'assets', 'images', 'virtuomate_logo.png'),
  path.join(root, 'android', 'app', 'src', 'main', 'res', 'drawable', 'virtuomate_logo.png'),
];

function isPng(buf) {
  return buf.length >= 8 && buf.slice(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]));
}

function resolveFfmpeg() {
  const candidates = [
    process.env.FFMPEG_PATH,
    path.join(root, '..', 'virtuomate_backend_firebase', 'node_modules', 'ffmpeg-static', 'ffmpeg.exe'),
    path.join(root, '..', 'virtuomate_backend_firebase', 'node_modules', 'ffmpeg-static'),
  ].filter(Boolean);
  for (const candidate of candidates) {
    if (candidate && fs.existsSync(candidate)) return candidate;
  }
  return 'ffmpeg';
}

function toPngBuffer(inputPath) {
  const raw = fs.readFileSync(inputPath);
  if (isPng(raw)) return raw;

  const ffmpeg = resolveFfmpeg();
  const tmp = path.join(root, 'build', 'virtuomate_logo_tmp.png');
  fs.mkdirSync(path.dirname(tmp), { recursive: true });
  execFileSync(ffmpeg, ['-y', '-i', inputPath, tmp], { stdio: 'pipe' });
  const converted = fs.readFileSync(tmp);
  if (!isPng(converted)) {
    throw new Error(`Logo convert failed (not PNG): ${inputPath}`);
  }
  return converted;
}

if (!fs.existsSync(src)) {
  const assetsLogo = targets[0];
  if (fs.existsSync(assetsLogo) && isPng(fs.readFileSync(assetsLogo))) {
    console.log('using existing valid PNG', assetsLogo);
    for (const dest of targets.slice(1)) {
      fs.mkdirSync(path.dirname(dest), { recursive: true });
      fs.copyFileSync(assetsLogo, dest);
      console.log('copied', dest);
    }
    process.exit(0);
  }
  console.error('Logo source not found:', src);
  process.exit(1);
}

const png = toPngBuffer(src);
for (const dest of targets) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.writeFileSync(dest, png);
  console.log('wrote', dest, png.length);
}
