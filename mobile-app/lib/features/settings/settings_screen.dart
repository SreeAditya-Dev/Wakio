import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/alarm_service.dart';
import '../../core/services/permissions_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader('Appearance'),
          RadioGroup<ThemeMode>(
            groupValue: mode,
            onChanged: (m) {
              if (m != null) ref.read(themeControllerProvider.notifier).set(m);
            },
            child: Column(
              children: const [
                _ThemeOption(mode: ThemeMode.dark, label: 'Dark'),
                _ThemeOption(mode: ThemeMode.light, label: 'Light'),
                _ThemeOption(mode: ThemeMode.system, label: 'System default'),
              ],
            ),
          ),
          const Divider(),
          _SectionHeader('Alarm'),
          const _InfoTile(
            icon: Icons.volume_up_rounded,
            title: 'Max volume override',
            subtitle:
                'Alarms ring on the alarm channel — louder than media and bypass silent mode.',
          ),
          const _InfoTile(
            icon: Icons.do_not_disturb_on_rounded,
            title: 'Do Not Disturb override',
            subtitle: 'Alarms sound even while DND is on.',
          ),
          const _InfoTile(
            icon: Icons.vibration_rounded,
            title: 'Haptics',
            subtitle: 'Tactile feedback on key interactions.',
          ),
          const Divider(),
          _SectionHeader('Background reliability'),
          const _ReliabilitySection(),
          const Divider(),
          _SectionHeader('Notifications'),
          const _InfoTile(
            icon: Icons.notifications_active_outlined,
            title: 'Push notifications',
            subtitle: 'Streak reminders and updates (requires FCM setup).',
          ),
          const Divider(),
          _SectionHeader('Accessibility'),
          const _InfoTile(
            icon: Icons.text_fields_rounded,
            title: 'Font size',
            subtitle: 'Follows your system text scale.',
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Wakio v1.0.0',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Text(text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w700)),
      );
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.mode, required this.label});
  final ThemeMode mode;
  final String label;
  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      value: mode,
      title: Text(label),
      activeColor: AppColors.primary,
    );
  }
}

/// Live status of the permissions that let an alarm ring while the app is
/// closed, with one-tap re-grant and a self-stopping test alarm so the user can
/// verify background ringing actually works on their device.
class _ReliabilitySection extends ConsumerStatefulWidget {
  const _ReliabilitySection();

  @override
  ConsumerState<_ReliabilitySection> createState() =>
      _ReliabilitySectionState();
}

class _ReliabilitySectionState extends ConsumerState<_ReliabilitySection>
    with WidgetsBindingObserver {
  AlarmPermissions? _perms;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check when the user returns from a system settings page.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final perms = await ref.read(permissionsServiceProvider).check();
    if (mounted) setState(() => _perms = perms);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  /// Runs a permission action, always refreshing afterwards and surfacing any
  /// failure as a toast instead of an unhandled error.
  Future<void> _runFix(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      _toast("Couldn't open that setting on this device. "
          'Open system Settings › Apps › Wakio to change it manually.');
    } finally {
      await _refresh();
    }
  }

  Future<void> _sendTestAlarm() async {
    try {
      await ref.read(alarmServiceProvider).scheduleTest();
      _toast('Test alarm set. Lock or close the app now — '
          'it should ring in ~10s.');
    } catch (_) {
      _toast("Couldn't schedule the test alarm.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final perms = _perms;
    final service = ref.read(permissionsServiceProvider);

    return Column(
      children: [
        _PermissionTile(
          title: 'Exact alarms',
          subtitle: 'Lets alarms fire on time even in Doze / when closed.',
          granted: perms?.exactAlarm,
          onFix: () => _runFix(() async {
            if (!await service.requestExactAlarm()) await service.openSettings();
          }),
        ),
        _PermissionTile(
          title: 'Notifications',
          subtitle: 'Required to show the full-screen alarm over the lockscreen.',
          granted: perms?.notifications,
          onFix: () => _runFix(() async {
            if (!await service.requestNotifications()) {
              await service.openSettings();
            }
          }),
        ),
        _PermissionTile(
          title: 'Unrestricted battery',
          subtitle: 'Recommended. Android often reports this as off even when '
              "it's on, so don't worry if it still shows unset after enabling.",
          granted: perms?.batteryUnrestricted,
          // Advisory, not critical: exact-alarm + notifications already cover
          // background ringing, and this flag's status is unreliable to read
          // back — so a not-granted state shows as neutral, not a warning.
          optional: true,
          // Can have no settings activity on some devices — fall back to the
          // app's system settings page.
          onFix: () => _runFix(() async {
            if (!await service.requestBatteryExemption()) {
              await service.openSettings();
            }
          }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _sendTestAlarm,
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Send test alarm (rings in 10s)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onFix,
    this.optional = false,
  });

  final String title;
  final String subtitle;
  // null = still loading the status.
  final bool? granted;
  final VoidCallback onFix;
  // Advisory permission: a not-granted state is shown neutrally (no warning),
  // since it isn't required and its status can read back incorrectly.
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final ok = granted == true;
    final loading = granted == null;

    final Color iconColor;
    final IconData icon;
    if (loading) {
      iconColor = Theme.of(context).disabledColor;
      icon = Icons.circle_outlined;
    } else if (ok) {
      iconColor = AppColors.success;
      icon = Icons.check_circle_rounded;
    } else if (optional) {
      // Neutral, not alarming.
      iconColor = Theme.of(context).disabledColor;
      icon = Icons.info_outline_rounded;
    } else {
      iconColor = AppColors.warning;
      icon = Icons.error_outline_rounded;
    }

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: loading || ok
          ? null
          : TextButton(
              onPressed: onFix,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: Text(optional ? 'Manage' : 'Fix'),
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
