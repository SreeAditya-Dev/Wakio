import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../repositories/alarm_repository.dart';
import '../repositories/auth_repository.dart';

/// Auth state used by the router's redirect logic.
sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);
  final AppUser user;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repo = ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    _restore();
    return const AuthLoading();
  }

  Future<void> _restore() async {
    final user = await _repo.currentUser();
    state = user != null ? Authenticated(user) : const Unauthenticated();
  }

  Future<void> login(String email, String password) async {
    final user = await _repo.login(email, password);
    state = Authenticated(user);
    await _restoreAlarms();
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await _repo.signup(name: name, email: email, password: password);
    state = Authenticated(user);
    await _restoreAlarms();
  }

  Future<void> loginWithGoogle(String idToken) async {
    final user = await _repo.loginWithGoogle(idToken);
    state = Authenticated(user);
    await _restoreAlarms();
  }

  /// Pull alarms from the backend and re-arm them. Run after every successful
  /// login/signup so alarms survive an app uninstall/reinstall.
  Future<void> _restoreAlarms() async {
    final alarms = ref.read(alarmRepositoryProvider);
    await alarms.pullFromServer();
    await alarms.rescheduleAll();
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const Unauthenticated();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
