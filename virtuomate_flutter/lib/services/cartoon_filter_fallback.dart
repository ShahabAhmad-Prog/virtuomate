import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Clean flat 2D / cel-shaded look (offline fallback — not Gemini anime).
img.Image applyCartoonFilter(img.Image source) {
  const maxSide = 480;
  var work = img.copyResize(
    source,
    width: source.width > source.height ? maxSide : null,
    height: source.height >= source.width ? maxSide : null,
    interpolation: img.Interpolation.linear,
  );

  // Flat color regions: downscale → quantize → upscale (illustration cells).
  const cellW = 64;
  final cellH = math.max(
    48,
    (work.height * cellW / work.width).round(),
  );
  var cells = img.copyResize(
    work,
    width: cellW,
    height: cellH,
    interpolation: img.Interpolation.linear,
  );
  cells = img.gaussianBlur(cells, radius: 1);
  cells = _posterize(cells, levels: 14);
  work = img.copyResize(
    cells,
    width: work.width,
    height: work.height,
    interpolation: img.Interpolation.nearest,
  );

  work = _softCelOutline(work);
  work = img.adjustColor(
    work,
    saturation: 1.06,
    contrast: 1.04,
    brightness: 1.02,
  );
  return work;
}

img.Image _posterize(img.Image image, {required int levels}) {
  final step = (255 / levels).round().clamp(1, 255);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      final r = (p.r.toInt() ~/ step) * step;
      final g = (p.g.toInt() ~/ step) * step;
      final b = (p.b.toInt() ~/ step) * step;
      image.setPixelRgba(x, y, r, g, b, p.a.toInt());
    }
  }
  return image;
}

/// Thin outlines between flat color blocks (2D comic stroke).
img.Image _softCelOutline(img.Image image) {
  final w = image.width;
  final h = image.height;

  int lum(img.Pixel p) =>
      ((p.r * 0.299) + (p.g * 0.587) + (p.b * 0.114)).round();

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final base = image.getPixel(x, y);
      final l0 = lum(base);
      var edge = 0;
      if (x > 0) edge = math.max(edge, (l0 - lum(image.getPixel(x - 1, y))).abs());
      if (x < w - 1) edge = math.max(edge, (l0 - lum(image.getPixel(x + 1, y))).abs());
      if (y > 0) edge = math.max(edge, (l0 - lum(image.getPixel(x, y - 1))).abs());
      if (y < h - 1) edge = math.max(edge, (l0 - lum(image.getPixel(x, y + 1))).abs());
      if (edge < 22) continue;

      final mix = ((edge - 22) / 40.0).clamp(0.0, 0.42);
      final nr = (base.r * (1 - mix)).round();
      final ng = (base.g * (1 - mix)).round();
      final nb = (base.b * (1 - mix)).round();
      image.setPixelRgba(x, y, nr, ng, nb, base.a.toInt());
    }
  }
  return image;
}

/// Square bust crop around [faceRect] with padding (pixel coords).
img.Image cropPortraitBust(
  img.Image image, {
  required math.Rectangle<int> faceRect,
  double paddingFactor = 0.45,
}) {
  final padX = (faceRect.width * paddingFactor).round();
  final padY = (faceRect.height * paddingFactor).round();
  var left = faceRect.left - padX;
  var top = faceRect.top - (padY * 1.2).round();
  var right = faceRect.right + padX;
  var bottom = faceRect.bottom + (padY * 1.8).round();

  left = left.clamp(0, image.width - 1);
  top = top.clamp(0, image.height - 1);
  right = right.clamp(left + 1, image.width);
  bottom = bottom.clamp(top + 1, image.height);

  final cropW = right - left;
  final cropH = bottom - top;
  final side = math.max(cropW, cropH);
  final cx = (left + right) ~/ 2;
  final cy = (top + bottom) ~/ 2;

  var squareLeft = cx - side ~/ 2;
  var squareTop = cy - side ~/ 2;
  if (squareLeft < 0) squareLeft = 0;
  if (squareTop < 0) squareTop = 0;
  if (squareLeft + side > image.width) squareLeft = image.width - side;
  if (squareTop + side > image.height) squareTop = image.height - side;
  squareLeft = squareLeft.clamp(0, image.width - 1);
  squareTop = squareTop.clamp(0, image.height - 1);
  final safeSide = math.min(side, math.min(image.width - squareLeft, image.height - squareTop));

  return img.copyCrop(
    image,
    x: squareLeft,
    y: squareTop,
    width: safeSide,
    height: safeSide,
  );
}
