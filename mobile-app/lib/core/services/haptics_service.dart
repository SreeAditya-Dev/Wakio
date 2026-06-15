import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

/// Centralized haptics so every primary interaction gives tactile feedback,
/// per the product requirement. Falls back to [HapticFeedback] when the device
/// has no custom vibrator amplitude support.
class HapticsService {
  bool? _hasVibrator;

  Future<bool> get _supported async =>
      _hasVibrator ??= (await Vibration.hasVibrator());

  Future<void> light() => HapticFeedback.lightImpact();
  Future<void> selection() => HapticFeedback.selectionClick();
  Future<void> medium() => HapticFeedback.mediumImpact();

  Future<void> success() async {
    if (await _supported) {
      await Vibration.vibrate(pattern: const [0, 60, 80, 120], intensities: const [0, 180, 0, 255]);
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  Future<void> error() async {
    if (await _supported) {
      await Vibration.vibrate(pattern: const [0, 200, 100, 200]);
    } else {
      await HapticFeedback.heavyImpact();
    }
  }
}

final hapticsProvider = Provider<HapticsService>((ref) => HapticsService());
