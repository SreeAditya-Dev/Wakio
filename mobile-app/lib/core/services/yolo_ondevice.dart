import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class YoloResult {
  const YoloResult({
    required this.targetPresent,
    required this.confidence,
    required this.labels,
    this.error = false,
  });

  final bool targetPresent;
  final double confidence;
  final List<String> labels;
  final bool error;

  static const failure =
      YoloResult(targetPresent: false, confidence: 0, labels: [], error: true);
}

/// Minimal on-device YOLOv11n runner for the "is the target object visible?"
/// question. Expects a float32 TFLite export with input [1,S,S,3] (0..1) and
/// output [1, 4+numClasses, N] (Ultralytics default). Designed to fail soft:
/// any shape mismatch returns [YoloResult.failure] so the caller can fall back
/// to server-side detection.
class OnDeviceYolo {
  OnDeviceYolo._(this._interpreter, this._labels, this._inputSize);

  final Interpreter _interpreter;
  final List<String> _labels;
  final int _inputSize;

  static Future<OnDeviceYolo> load(String asset, List<String> labels) async {
    final interpreter = await Interpreter.fromAsset(asset);
    final inShape = interpreter.getInputTensor(0).shape; // [1, S, S, 3]
    final size = inShape.length == 4 ? inShape[1] : 320;
    return OnDeviceYolo._(interpreter, labels, size);
  }

  YoloResult detect(Uint8List jpegBytes, String target,
      {double minConfidence = 0.45}) {
    try {
      final decoded = img.decodeImage(jpegBytes);
      if (decoded == null) return YoloResult.failure;

      final resized =
          img.copyResize(decoded, width: _inputSize, height: _inputSize);

      // [1, S, S, 3] normalized float input.
      final input = List.generate(
        1,
        (_) => List.generate(
          _inputSize,
          (y) => List.generate(_inputSize, (x) {
            final px = resized.getPixel(x, y);
            return [px.r / 255.0, px.g / 255.0, px.b / 255.0];
          }),
        ),
      );

      final outShape = _interpreter.getOutputTensor(0).shape; // [1, 4+nc, N]
      final output = _emptyNested(outShape);
      _interpreter.run(input, output);

      return _postprocess(output, outShape, target, minConfidence);
    } catch (_) {
      return YoloResult.failure;
    }
  }

  YoloResult _postprocess(
    dynamic output,
    List<int> shape,
    String target,
    double minConfidence,
  ) {
    if (shape.length != 3) return YoloResult.failure;
    final channels = shape[1]; // 4 + numClasses
    final boxes = shape[2];
    final numClasses = channels - 4;
    final targetIdx = _labels.indexOf(target.toLowerCase());

    final out = output[0] as List; // [channels][boxes]
    final present = <String>{};
    double bestTarget = 0;

    for (var b = 0; b < boxes; b++) {
      var bestScore = 0.0;
      var bestClass = -1;
      for (var c = 0; c < numClasses; c++) {
        final score = (out[4 + c][b] as num).toDouble();
        if (score > bestScore) {
          bestScore = score;
          bestClass = c;
        }
      }
      if (bestScore >= minConfidence && bestClass >= 0 &&
          bestClass < _labels.length) {
        present.add(_labels[bestClass]);
        if (bestClass == targetIdx) {
          bestTarget = math.max(bestTarget, bestScore);
        }
      }
    }

    return YoloResult(
      targetPresent: bestTarget >= minConfidence,
      confidence: bestTarget,
      labels: present.toList(),
    );
  }

  dynamic _emptyNested(List<int> shape) {
    dynamic build(int dim) {
      if (dim == shape.length - 1) {
        return List<double>.filled(shape[dim], 0.0);
      }
      return List.generate(shape[dim], (_) => build(dim + 1));
    }

    return build(0);
  }

  void close() => _interpreter.close();
}
