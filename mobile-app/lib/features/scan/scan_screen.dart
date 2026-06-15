import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/router/app_router.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/detection_service.dart';
import '../../core/services/haptics_service.dart';
import '../../core/theme/app_colors.dart';
import 'scan_success_screen.dart';

class ScanArgs {
  const ScanArgs({
    required this.alarmId,
    required this.scheduledId,
    required this.challengeObject,
    required this.displayName,
  });

  final String alarmId;
  final int scheduledId;
  final String challengeObject;
  final String displayName;
}

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key, required this.args});
  final ScanArgs args;

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _controller;
  Timer? _loop;
  bool _busy = false;
  bool _done = false;
  bool _success = false;
  String _status = 'Point your camera at the object';
  String? _lastDetected;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final granted = await Permission.camera.request();
    if (!granted.isGranted) {
      setState(() => _status = 'Camera permission is required to scan.');
      return;
    }
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() => _controller = controller);
      _loop = Timer.periodic(
          const Duration(milliseconds: 1300), (_) => _scanOnce());
    } catch (e) {
      setState(() => _status = 'Could not start the camera.');
    }
  }

  Future<void> _scanOnce() async {
    final controller = _controller;
    if (controller == null || _busy || _done || !controller.value.isInitialized) {
      return;
    }
    _busy = true;
    try {
      final shot = await controller.takePicture();
      final bytes = await shot.readAsBytes();
      final result = await ref
          .read(detectionServiceProvider)
          .detect(bytes, widget.args.challengeObject);

      if (!mounted) return;
      if (result.targetPresent) {
        await _onSuccess();
      } else {
        setState(() {
          _lastDetected =
              result.detected.isNotEmpty ? result.detected.first : null;
          _status = _lastDetected != null
              ? 'Seeing: $_lastDetected — keep looking for ${widget.args.displayName}'
              : 'Searching for ${widget.args.displayName}…';
        });
      }
    } catch (_) {
      /* transient camera/inference error — try again next tick */
    } finally {
      _busy = false;
    }
  }

  Future<void> _onSuccess() async {
    _done = true;
    _loop?.cancel();
    await ref.read(hapticsProvider).success();
    // Stop the ringing alarm.
    await ref.read(alarmServiceProvider).cancel(widget.args.scheduledId);
    if (!mounted) return;
    // Show the animated tick before handing off to the success screen.
    setState(() => _success = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    context.pushReplacement(
      Routes.scanSuccess,
      extra: ScanSuccessArgs(
        alarmId: widget.args.alarmId,
        challengeObject: widget.args.challengeObject,
        displayName: widget.args.displayName,
      ),
    );
  }

  @override
  void dispose() {
    _loop?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return PopScope(
      canPop: false, // must scan to leave
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (controller != null && controller.value.isInitialized)
              CameraPreview(controller)
            else
              const Center(child: CircularProgressIndicator()),

            // Target reticle overlay.
            Center(
              child: Container(
                height: 260,
                width: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),

            // Top: what to scan.
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          const Text('FIND & SCAN',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  letterSpacing: 2)),
                          const SizedBox(height: 4),
                          Text(widget.args.displayName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom status pill.
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Flexible(
                        child: Text(_status,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Animated success tick — shown once the object is detected.
            if (_success) const _SuccessTick(),
          ],
        ),
      ),
    );
  }
}

/// Green circle with a checkmark that pops in with a bounce.
class _SuccessTick extends StatelessWidget {
  const _SuccessTick();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            height: 140,
            width: 140,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 90, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
