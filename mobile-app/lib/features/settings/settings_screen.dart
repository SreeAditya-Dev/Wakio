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

  Future<void> _sendTestAlarm() async {
    await ref.read(alarmServiceProvider).scheduleTest();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Test alarm set. Lock or close the app now — it should ring in ~10s.',
        ),
        duration: Duration(seconds: 6),
      ),
    );
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
          onFix: () async {
            await service.requestExactAlarm();
            await _refresh();
          },
        ),
        _PermissionTile(
          title: 'Notifications',
          subtitle: 'Required to show the full-screen alarm over the lockscreen.',
          granted: perms?.notifications,
          onFix: () async {
            await service.requestNotifications();
            await _refresh();
          },
        ),
        _PermissionTile(
          title: 'Unrestricted battery',
          subtitle: 'Stops the system from killing the alarm in the background.',
          granted: perms?.batteryUnrestricted,
          onFix: () async {
            await service.requestBatteryExemption();
            await _refresh();
          },
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
  });

  final String title;
  final String subtitle;
  // null = still loading the status.
  final bool? granted;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final ok = granted == true;
    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
        color: granted == null
            ? Theme.of(context).disabledColor
            : (ok ? AppColors.success : AppColors.warning),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: granted == null || ok
          ? null
          : TextButton(
              onPressed: onFix,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Fix'),
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
