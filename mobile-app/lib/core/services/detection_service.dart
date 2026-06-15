import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';
import 'yolo_ondevice.dart';

class DetectionOutcome {
  const DetectionOutcome({
    required this.targetPresent,
    required this.confidence,
    required this.detected,
    required this.source,
  });

  final bool targetPresent;
  final double confidence;
  final List<String> detected;
  final String source; // 'on-device' | 'server'
}

/// Hybrid object detection: on-device YOLOv11n TFLite is primary (works offline,
/// instant). Falls back to the FastAPI `/detection/verify` endpoint when the
/// on-device model is unavailable or unsure.
class DetectionService {
  DetectionService(this._dio);
  final Dio _dio;

  OnDeviceYolo? _yolo;
  bool _triedLoad = false;

  static const _modelAsset = 'assets/models/yolo11n.tflite';
  static const _labelsAsset = 'assets/models/labels.txt';
  static const _minConfidence = 0.45;

  Future<bool> _ensureOnDevice() async {
    if (_triedLoad) return _yolo != null;
    _triedLoad = true;
    try {
      // Will throw if the model asset hasn't been added yet.
      await rootBundle.load(_modelAsset);
      final labels = (await rootBundle.loadString(_labelsAsset))
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      _yolo = await OnDeviceYolo.load(_modelAsset, labels);
    } catch (_) {
      _yolo = null; // fall back to server
    }
    return _yolo != null;
  }

  /// Run detection on a captured JPEG frame for [target] (a COCO class name).
  Future<DetectionOutcome> detect(Uint8List jpegBytes, String target) async {
    if (await _ensureOnDevice()) {
      final r = _yolo!.detect(jpegBytes, target, minConfidence: _minConfidence);
      if (r.error) {
        return _serverDetect(jpegBytes, target); // shape mismatch -> server
      }
      if (r.targetPresent) {
        return DetectionOutcome(
          targetPresent: true,
          confidence: r.confidence,
          detected: r.labels,
          source: 'on-device',
        );
      }
      // On-device didn't find it — return the negative without a network call.
      return DetectionOutcome(
        targetPresent: false,
        confidence: r.confidence,
        detected: r.labels,
        source: 'on-device',
      );
    }
    return _serverDetect(jpegBytes, target);
  }

  Future<DetectionOutcome> _serverDetect(
      Uint8List jpegBytes, String target) async {
    try {
      final form = FormData.fromMap({
        'target': target,
        'image': MultipartFile.fromBytes(jpegBytes, filename: 'frame.jpg'),
      });
      final res = await _dio.post('/detection/verify', data: form);
      final data = res.data as Map<String, dynamic>;
      return DetectionOutcome(
        targetPresent: data['target_present'] as bool,
        confidence: (data['confidence'] as num).toDouble(),
        detected: (data['detected'] as List).cast<String>(),
        source: 'server',
      );
    } on DioException {
      return const DetectionOutcome(
        targetPresent: false,
        confidence: 0,
        detected: [],
        source: 'server',
      );
    }
  }
}

final detectionServiceProvider = Provider<DetectionService>((ref) {
  return DetectionService(ref.read(dioProvider));
});
