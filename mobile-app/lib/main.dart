import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/router/app_router.dart';
import 'core/services/alarm_service.dart';
import 'core/storage/local_prefs.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/theme_controller.dart';
import 'data/repositories/alarm_repository.dart';
import 'features/recheck/recheck_screen.dart';
import 'features/ring/ring_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  // Start the alarm engine; reschedules any alarms set before app death.
  await container.read(alarmServiceProvider).init();

  // Ask for the alarm-critical permissions ONCE, on first launch only, then
  // persist a flag. Re-prompting on every cold start (especially battery
  // optimization, which many OEMs never report as `granted`) was nagging the
  // user every time they opened the app. After this, re-granting is available
  // from the Settings screen instead.
  await _requestAlarmPermissionsOnce(container.read(localPrefsProvider));

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WakioApp(),
    ),
  );
}

/// Requests the permissions an alarm needs to fire reliably from the
/// background — notifications (Android 13+), exact alarms (Android 12+), and
/// battery-optimization exemption — but only the first time the app runs.
Future<void> _requestAlarmPermissionsOnce(LocalPrefs prefs) async {
  if (await prefs.permissionsOnboarded) return;

  // Android 13+: the ringing alarm's notification + full-screen intent.
  await Permission.notification.request();
  // Android 12+: setExactAndAllowWhileIdle() throws without this, so the alarm
  // silently never fires while backgrounded/killed.
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
  // Stops the OS from killing the alarm's foreground service / delaying wake-up.
  if (await Permission.ignoreBatteryOptimizations.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
  }

  await prefs.markPermissionsOnboarded();
}

class WakioApp extends ConsumerStatefulWidget {
  const WakioApp({super.key});

  @override
  ConsumerState<WakioApp> createState() => _WakioAppState();
}

class _WakioAppState extends ConsumerState<WakioApp> {
  StreamSubscription<List<RingingAlarm>>? _ringSub;
  bool _ringing = false;

  @override
  void initState() {
    super.initState();
    // IMPORTANT: Subscribe to the ringing stream BEFORE rescheduling alarms.
    // On a cold-start from a notification tap, the ringing event may fire
    // immediately after Alarm.init(); subscribing first ensures we don't
    // miss it and can navigate to the ring screen while the sound plays.
    _listenForRinging();

    // Re-arm alarms (covers app cold-start) + push pending changes to server.
    Future.microtask(() async {
      final repo = ref.read(alarmRepositoryProvider);
      await repo.rescheduleAll();
      await repo.syncPending();
    });
  }

  void _listenForRinging() {
    _ringSub =
        ref.read(alarmServiceProvider).ringingStream.listen((ringing) {
      if (ringing.isEmpty) {
        _ringing = false;
        return;
      }
      if (_ringing) return; // already showing the ring/recheck screen
      _ringing = true;
      final r = ringing.first;

      if (r.type == 'recheck') {
        ref.read(routerProvider).push(
              Routes.recheck,
              extra: RecheckArgs(
                alarmId: r.alarmId,
                historyId: r.historyId!,
                scheduledId: r.scheduledId,
                challengeObject: r.challengeObject,
              ),
            );
        return;
      }

      ref.read(routerProvider).push(
            Routes.ring,
            extra: RingArgs(
              alarmId: r.alarmId,
              scheduledId: r.scheduledId,
              challengeObject: r.challengeObject,
              displayName: _titleCase(r.challengeObject),
              historyId: r.historyId,
              isRelapse: r.type == 'relapse',
            ),
          );
    });
  }

  String _titleCase(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  void dispose() {
    _ringSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Wakio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
