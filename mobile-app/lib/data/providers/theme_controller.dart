import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Light / dark / system theme. Defaults to dark per spec.
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void set(ThemeMode mode) => state = mode;

  void cycle() {
    state = switch (state) {
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
      ThemeMode.system => ThemeMode.dark,
    };
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
