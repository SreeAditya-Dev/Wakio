import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
