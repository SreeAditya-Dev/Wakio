import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.historyId,
    this.isRelapse = false,
  });

  final String alarmId;
  final int scheduledId;
  final String challengeObject;
  final String displayName;
  final String? historyId;
  final bool isRelapse;
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
  bool _showWrongMark = false;
  int _wrongMarkTick = 0;
  String _status = 'Point your camera at the object';
  String? _lastDetected;

  // Offline fallback: when detection can't run (no on-device model AND the
  // server is unreachable) the camera scan can never succeed, so we switch to
  // a fully-offline wake task instead of trapping the user on a ringing alarm.
  bool _onDeviceReady = true;
  int _unavailableTicks = 0;
  bool _fallbackMode = false;
  int _mathA = 0;
  int _mathB = 0;
  int _mathAttempts = 0;
  final _answerCtrl = TextEditingController();
  String? _mathError;

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
    // Knowing up front whether the on-device model is available lets us switch
    // to the offline challenge after a single failed server attempt (rather
    // than waiting for several timeouts) when we're offline with no model.
    _onDeviceReady =
        await ref.read(detectionServiceProvider).onDeviceReady();
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
      if (result.unavailable) {
        // Detection couldn't run (no on-device model + server unreachable).
        // With no model we know retrying won't help, so fall back after the
        // first miss; otherwise allow a couple of attempts for a flaky network.
        _unavailableTicks++;
        if (_unavailableTicks >= (_onDeviceReady ? 2 : 1)) {
          _enterFallback();
        } else {
          setState(() => _status = 'Checking…');
        }
        return;
      }
      _unavailableTicks = 0;
      if (result.targetPresent) {
        await _onSuccess();
      } else {
        final wrongItemSeen = result.detected.isNotEmpty;
        setState(() {
          _lastDetected = wrongItemSeen ? result.detected.first : null;
          _status = wrongItemSeen
              ? 'Seeing: $_lastDetected — keep looking for ${widget.args.displayName}'
              : 'Searching for ${widget.args.displayName}…';
          if (wrongItemSeen) {
            _wrongMarkTick++;
            _showWrongMark = true;
          }
        });
        if (wrongItemSeen) {
          Future.delayed(const Duration(milliseconds: 700), () {
            if (mounted) setState(() => _showWrongMark = false);
          });
        }
      }
    } catch (_) {
      /* transient camera/inference error — try again next tick */
    } finally {
      _busy = false;
    }
  }

  /// Switch from camera scanning to the offline wake task. Stops the camera
  /// loop and generates a fresh math problem the user must solve to dismiss.
  void _enterFallback() {
    if (_fallbackMode) return;
    _loop?.cancel();
    final rng = Random();
    setState(() {
      _fallbackMode = true;
      _mathA = 6 + rng.nextInt(8); // 6..13
      _mathB = 6 + rng.nextInt(8); // 6..13
      _answerCtrl.clear();
      _mathError = null;
    });
  }

  void _checkMath() {
    final guess = int.tryParse(_answerCtrl.text.trim());
    if (guess == _mathA * _mathB) {
      _onSuccess();
    } else {
      ref.read(hapticsProvider).error();
      final rng = Random();
      setState(() {
        _mathAttempts++;
        _mathError = 'Not quite — try this one.';
        _mathA = 6 + rng.nextInt(8);
        _mathB = 6 + rng.nextInt(8);
        _answerCtrl.clear();
      });
    }
  }

  Future<void> _onSuccess() async {
    if (_done) return;
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
        historyId: widget.args.historyId,
        isRelapse: widget.args.isRelapse,
      ),
    );
  }

  @override
  void dispose() {
    _loop?.cancel();
    _controller?.dispose();
    _answerCtrl.dispose();
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
            if (!_fallbackMode)
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
            if (!_fallbackMode)
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

            // Offline fallback: a wake task shown when the scan can't be
            // verified (no on-device model and the server is unreachable).
            if (_fallbackMode && !_success)
              _OfflineChallenge(
                a: _mathA,
                b: _mathB,
                attempt: _mathAttempts,
                controller: _answerCtrl,
                error: _mathError,
                onSubmit: _checkMath,
              ),

            // Animated cross — shown briefly when the wrong object is seen.
            if (_showWrongMark) _WrongMarkTick(key: ValueKey(_wrongMarkTick)),

            // Animated success tick — shown once the object is detected.
            if (_success) const _SuccessTick(),
          ],
        ),
      ),
    );
  }
}

/// Full-screen offline wake task. Shown only when the camera scan can't be
/// verified (no on-device model AND the server is unreachable) so the user is
/// never trapped on a ringing alarm with no way to dismiss it. Still demands an
/// effortful action — solving a small multiplication — to keep the wake honest.
///
/// Animates in (fade + rise) and shakes the answer field on a wrong guess so
/// the offline path feels as intentional as the rest of the flow.
class _OfflineChallenge extends StatefulWidget {
  const _OfflineChallenge({
    required this.a,
    required this.b,
    required this.attempt,
    required this.controller,
    required this.error,
    required this.onSubmit,
  });

  final int a;
  final int b;
  final int attempt;
  final TextEditingController controller;
  final String? error;
  final VoidCallback onSubmit;

  @override
  State<_OfflineChallenge> createState() => _OfflineChallengeState();
}

class _OfflineChallengeState extends State<_OfflineChallenge>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..forward();

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(_OfflineChallenge old) {
    super.didUpdateWidget(old);
    // New wrong attempt -> shake the prompt.
    if (widget.attempt != old.attempt) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);

    return FadeTransition(
      opacity: fade,
      child: Container(
        color: AppColors.darkBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(fade),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  // Soft-glow badge, echoing the ring screen's alarm orb.
                  Center(
                    child: Container(
                      height: 84,
                      width: 84,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          AppColors.primary,
                          AppColors.primaryHover,
                        ]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.45),
                            blurRadius: 36,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.wifi_off_rounded,
                          color: AppColors.onPrimary, size: 40),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Can't verify the scan offline",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.25,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Solve this quick problem to stop the alarm.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  // The problem card — shakes on a wrong answer.
                  AnimatedBuilder(
                    animation: _shake,
                    builder: (context, child) {
                      final dx = sin(_shake.value * pi * 4) *
                          12 *
                          (1 - _shake.value);
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '${widget.a} × ${widget.b}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: widget.controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700),
                    onSubmitted: (_) => widget.onSubmit(),
                    decoration: InputDecoration(
                      hintText: 'Your answer',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: AppColors.darkSurface,
                      errorText: widget.error,
                      errorStyle: const TextStyle(color: AppColors.warning),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 62,
                    child: FilledButton.icon(
                      onPressed: widget.onSubmit,
                      icon: const Icon(Icons.alarm_off_rounded),
                      label: const Text('Stop alarm',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

/// Red circle with a cross that pops in with a bounce — shown briefly when
/// the camera sees an object that isn't the target.
class _WrongMarkTick extends StatelessWidget {
  const _WrongMarkTick({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 350),
          curve: Curves.elasticOut,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.close_rounded,
                size: 70, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
