import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/auth_controller.dart';
import '../../features/alarms/alarm_list_screen.dart';
import '../../features/alarms/create_alarm_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/recheck/recheck_screen.dart';
import '../../features/ring/ring_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/scan/scan_success_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/stats/stats_screen.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const home = '/';
  static const alarms = '/alarms';
  static const createAlarm = '/alarms/create';
  static const stats = '/stats';
  static const profile = '/profile';
  static const settings = '/settings';
  static const ring = '/ring';
  static const scan = '/scan';
  static const scanSuccess = '/scan-success';
  static const recheck = '/recheck';
}

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      final onSplash = loc == Routes.splash;
      final onAuthFlow = {
        Routes.login,
        Routes.signup,
        Routes.forgotPassword,
        Routes.onboarding,
      }.contains(loc);

      switch (auth) {
        case AuthLoading():
          return onSplash ? null : Routes.splash;
        case Unauthenticated():
          return onAuthFlow ? null : Routes.login;
        case Authenticated():
          if (onSplash || onAuthFlow) return Routes.home;
          return null;
      }
    },
    refreshListenable: _AuthRefresh(ref),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: Routes.signup, builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // Bottom-nav shell.
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: Routes.home, builder: (_, __) => const HomeScreen()),
          GoRoute(path: Routes.alarms, builder: (_, __) => const AlarmListScreen()),
          GoRoute(path: Routes.stats, builder: (_, __) => const StatsScreen()),
          GoRoute(path: Routes.profile, builder: (_, __) => const ProfileScreen()),
        ],
      ),

      GoRoute(
        path: Routes.createAlarm,
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            CreateAlarmScreen(alarmId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.ring,
        parentNavigatorKey: _rootKey,
        builder: (_, state) {
          final p = state.extra as RingArgs?;
          return RingScreen(args: p);
        },
      ),
      GoRoute(
        path: Routes.scan,
        parentNavigatorKey: _rootKey,
        builder: (_, state) {
          final args = state.extra as ScanArgs;
          return ScanScreen(args: args);
        },
      ),
      GoRoute(
        path: Routes.scanSuccess,
        parentNavigatorKey: _rootKey,
        builder: (_, state) {
          final args = state.extra as ScanSuccessArgs;
          return ScanSuccessScreen(args: args);
        },
      ),
      GoRoute(
        path: Routes.recheck,
        parentNavigatorKey: _rootKey,
        builder: (_, state) {
          final args = state.extra as RecheckArgs;
          return RecheckScreen(args: args);
        },
      ),
    ],
  );
});

/// Bridges Riverpod auth state changes into go_router's redirect refresh.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}
