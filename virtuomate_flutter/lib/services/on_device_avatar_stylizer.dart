import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:virtuomate_flutter/services/cartoon_filter_fallback.dart';

/// Result of on-device photo → cartoon avatar (Layer 1, Option A).
class OnDeviceStylizeResult {
  const OnDeviceStylizeResult({
    required this.file,
    required this.engine,
    this.faceDetected = false,
    this.displayPathOrUrl = '',
  });

  final File file;
  final String engine;
  final bool faceDetected;
  final String displayPathOrUrl;
}

/// Free on-device pipeline: ML Kit face crop → TFLite (if model present) → CPU cartoon.
class OnDeviceAvatarStylizer {
  OnDeviceAvatarStylizer._();
  static final OnDeviceAvatarStylizer instance = OnDeviceAvatarStylizer._();

  static const _modelAsset = 'assets/models/avatar_cartoon.tflite';

  Interpreter? _interpreter;
  bool _loadAttempted = false;
  FaceDetector? _faceDetector;

  Future<FaceDetector> _detector() async {
    _faceDetector ??= FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.12,
      ),
    );
    return _faceDetector!;
  }

  Future<Interpreter?> _loadInterpreter() async {
    if (_loadAttempted) return _interpreter;
    _loadAttempted = true;
    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      debugPrint('OnDeviceAvatarStylizer: TFLite model loaded');
    } catch (e) {
      debugPrint('OnDeviceAvatarStylizer: no TFLite model ($e), using CPU cartoon');
      _interpreter = null;
    }
    return _interpreter;
  }

  /// Stylize [source] and write a PNG under app temp directory.
  Future<OnDeviceStylizeResult> stylize(File source) async {
    final bytes = await source.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Could not read image. Use JPG or PNG.');
    }

    final faceRect = await _detectLargestFace(source.path);
    final cropped = faceRect != null
        ? cropPortraitBust(decoded, faceRect: faceRect)
        : img.copyResize(
            decoded,
            width: decoded.width > decoded.height ? 512 : null,
            height: decoded.height >= decoded.width ? 512 : null,
          );

    final interpreter = await _loadInterpreter();
    img.Image output;
    String engine;

    if (interpreter != null) {
      try {
        output = await _runTflite(interpreter, cropped);
        engine = 'tflite';
      } catch (e) {
        debugPrint('OnDeviceAvatarStylizer: TFLite failed ($e), CPU fallback');
        output = applyCartoonFilter(cropped);
        engine = 'cpu_cartoon';
      }
    } else {
      output = applyCartoonFilter(cropped);
      engine = 'cpu_cartoon';
    }

    final png = Uint8List.fromList(img.encodePng(output));
    final docs = await getApplicationDocumentsDirectory();
    final out = File(
      '${docs.path}/avatar-stylized-${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await out.writeAsBytes(png, flush: true);

    return OnDeviceStylizeResult(
      file: out,
      engine: engine,
      faceDetected: faceRect != null,
    );
  }

  Future<math.Rectangle<int>?> _detectLargestFace(String path) async {
    try {
      final input = InputImage.fromFilePath(path);
      final faces = await (await _detector()).processImage(input);
      if (faces.isEmpty) return null;

      Face? best;
      var bestArea = 0;
      for (final f in faces) {
        final box = f.boundingBox;
        final area = (box.width * box.height).round();
        if (area > bestArea) {
          bestArea = area;
          best = f;
        }
      }
      if (best == null) return null;
      final b = best.boundingBox;
      return math.Rectangle<int>(
        b.left.round(),
        b.top.round(),
        b.width.round(),
        b.height.round(),
      );
    } catch (e) {
      debugPrint('OnDeviceAvatarStylizer: face detection skipped ($e)');
      return null;
    }
  }

  Future<img.Image> _runTflite(Interpreter interpreter, img.Image input) async {
    final inTensor = interpreter.getInputTensor(0);
    final outTensor = interpreter.getOutputTensor(0);
    final inShape = inTensor.shape;
    if (inShape.length < 4) {
      throw Exception('Unexpected TFLite input rank');
    }

    final height = inShape[1];
    final width = inShape[2];
    final channels = inShape[3];
    if (channels != 3) {
      throw Exception('Model must use RGB input (channels=3)');
    }

    final resized = img.copyResize(
      input,
      width: width,
      height: height,
      interpolation: img.Interpolation.linear,
    );

    final inputType = inTensor.type;
    final useFloat = inputType == TensorType.float32;

    if (useFloat) {
      final inputBuffer = _imageToFloat32Nhwc(resized, normalizeMinusOneToOne: true);
      final outputBuffer = _allocateOutput(outTensor.shape, float32: true);
      interpreter.run(inputBuffer, outputBuffer);
      return _floatOutputToImage(outputBuffer, outTensor.shape, denormalizeMinusOneToOne: true);
    }

    final inputBuffer = _imageToUint8Nhwc(resized);
    final outputBuffer = _allocateOutput(outTensor.shape, float32: false);
    interpreter.run(inputBuffer, outputBuffer);
    return _uint8OutputToImage(outputBuffer, outTensor.shape);
  }

  List<List<List<List<double>>>> _imageToFloat32Nhwc(
    img.Image image, {
    required bool normalizeMinusOneToOne,
  }) {
    final h = image.height;
    final w = image.width;
    final batch = List.generate(1, (_) => List.generate(h, (y) {
      return List.generate(w, (x) {
        final p = image.getPixel(x, y);
        if (normalizeMinusOneToOne) {
          return [
            (p.r / 127.5) - 1.0,
            (p.g / 127.5) - 1.0,
            (p.b / 127.5) - 1.0,
          ];
        }
        return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
      });
    }));
    return batch;
  }

  List<List<List<List<int>>>> _imageToUint8Nhwc(img.Image image) {
    final h = image.height;
    final w = image.width;
    return [
      List.generate(h, (y) {
        return List.generate(w, (x) {
          final p = image.getPixel(x, y);
          return [p.r.toInt(), p.g.toInt(), p.b.toInt()];
        });
      }),
    ];
  }

  dynamic _allocateOutput(List<int> shape, {required bool float32}) {
    if (shape.length < 4) throw Exception('Unexpected output rank');
    final h = shape[1];
    final w = shape[2];
    final c = shape[3];
    if (float32) {
      return List.generate(
        1,
        (_) => List.generate(
          h,
          (_) => List.generate(w, (_) => List.filled(c, 0.0)),
        ),
      );
    }
    return List.generate(
      1,
      (_) => List.generate(
        h,
        (_) => List.generate(w, (_) => List.filled(c, 0)),
      ),
    );
  }

  img.Image _floatOutputToImage(
    List<List<List<List<double>>>> output,
    List<int> shape, {
    required bool denormalizeMinusOneToOne,
  }) {
    final h = shape[1];
    final w = shape[2];
    final out = img.Image(width: w, height: h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final px = output[0][y][x];
        int r;
        int g;
        int b;
        if (denormalizeMinusOneToOne) {
          r = (((px[0] + 1.0) * 127.5)).round().clamp(0, 255);
          g = (((px[1] + 1.0) * 127.5)).round().clamp(0, 255);
          b = (((px[2] + 1.0) * 127.5)).round().clamp(0, 255);
        } else {
          r = (px[0] * 255).round().clamp(0, 255);
          g = (px[1] * 255).round().clamp(0, 255);
          b = (px[2] * 255).round().clamp(0, 255);
        }
        out.setPixelRgba(x, y, r, g, b, 255);
      }
    }
    return out;
  }

  img.Image _uint8OutputToImage(List<List<List<List<int>>>> output, List<int> shape) {
    final h = shape[1];
    final w = shape[2];
    final out = img.Image(width: w, height: h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final px = output[0][y][x];
        out.setPixelRgba(
          x,
          y,
          px[0].clamp(0, 255),
          px[1].clamp(0, 255),
          px[2].clamp(0, 255),
          255,
        );
      }
    }
    return out;
  }

  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    await _faceDetector?.close();
    _faceDetector = null;
    _loadAttempted = false;
  }
}
