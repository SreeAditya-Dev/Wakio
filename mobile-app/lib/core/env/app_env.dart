/// Build-time configuration, supplied via `--dart-define`.
///
/// Example:
///   flutter run \
///     --dart-define=API_BASE_URL=http://10.0.2.2:8011/api/v1 \
///     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=...
///
/// Note: 10.0.2.2 is the Android emulator's alias for the host machine.
/// The default below points at the dev machine's LAN IP so `flutter run`
/// works on a physical device on the same Wi-Fi network out of the box.
abstract final class AppEnv {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.29.25:8011/api/v1',
  );

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: '');

  /// True when Supabase realtime/storage is configured.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
