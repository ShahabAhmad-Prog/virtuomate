import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:virtuomate_flutter/services/cartoon_filter_fallback.dart';

void main() {
  test('applyCartoonFilter returns same dimensions', () {
    final src = img.Image(width: 120, height: 160);
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        src.setPixelRgba(x, y, (x * 2) % 255, (y * 3) % 255, 128, 255);
      }
    }
    final out = applyCartoonFilter(src);
    expect(out.width, greaterThan(0));
    expect(out.height, greaterThan(0));
  });

  test('cropPortraitBust produces square crop', () {
    final src = img.Image(width: 400, height: 600);
    final face = math.Rectangle<int>(140, 180, 120, 140);
    final crop = cropPortraitBust(src, faceRect: face);
    expect(crop.width, crop.height);
    expect(crop.width, greaterThan(0));
  });
}
