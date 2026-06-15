import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/haptics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/alarm_x.dart';
import '../../data/repositories/alarm_repository.dart';

/// Create or edit an alarm. The challenge type is fixed to Object Scan for the
/// slice; other types are shown as "coming soon".
class CreateAlarmScreen extends ConsumerStatefulWidget {
  const CreateAlarmScreen({super.key, this.alarmId});
  final String? alarmId;

  @override
  ConsumerState<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends ConsumerState<CreateAlarmScreen> {
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  final Set<int> _repeatDays = {};
  int _volume = 100;
  int _snooze = 5;
  bool _vibrate = true;
  final _label = TextEditingController(text: 'Alarm');
  bool _loading = false;
  bool _loaded = false;

  static const _dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    if (widget.alarmId != null) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final db = ref.read(alarmRepositoryProvider);
    final list = await db.watch().first;
    final matches = list.where((a) => a.id == widget.alarmId);
    final existing = matches.isEmpty ? null : matches.first;
    if (existing != null && mounted) {
      setState(() {
        _time = existing.timeOfDay;
        _repeatDays.addAll(existing.repeatDayList);
        _volume = existing.volume;
        _snooze = existing.snoozeMinutes;
        _vibrate = existing.vibrate;
        _label.text = existing.label;
        _loaded = true;
      });
    }
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await ref.read(alarmRepositoryProvider).saveDraft(
            id: widget.alarmId,
            label: _label.text.trim().isEmpty ? 'Alarm' : _label.text.trim(),
            time: _time,
            repeatDays: _repeatDays.toList()..sort(),
            volume: _volume,
            snoozeMinutes: _snooze,
            vibrate: _vibrate,
          );
      ref.read(hapticsProvider).success();
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.alarmId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit alarm' : 'New alarm')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // Time picker
            AppCard(
              onTap: _pickTime,
              child: Center(
                child: Column(
                  children: [
                    Text(_time.format(context),
                        style: theme.textTheme.displayMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text('Tap to change',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Repeat'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final on = _repeatDays.contains(i);
                return GestureDetector(
                  onTap: () {
                    ref.read(hapticsProvider).selection();
                    setState(() =>
                        on ? _repeatDays.remove(i) : _repeatDays.add(i));
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        on ? AppColors.primary : theme.colorScheme.surface,
                    child: Text(_dayNames[i],
                        style: TextStyle(
                            color: on
                                ? AppColors.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            _SectionLabel('Challenge'),
            const SizedBox(height: 10),
            AppCard(
              border: Border.all(color: AppColors.primary, width: 1.4),
              child: Row(
                children: [
                  const Icon(Icons.center_focus_strong_rounded,
                      color: AppColors.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Object Scan',
                            style: theme.textTheme.titleMedium),
                        Text('Scan a random object to stop the alarm',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: const [
                _ComingSoonChip('Math'),
                _ComingSoonChip('Walk steps'),
                _ComingSoonChip('Selfie'),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel('Volume'),
            Slider(
              value: _volume.toDouble(),
              min: 10,
              max: 100,
              divisions: 9,
              label: '$_volume%',
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _volume = v.round()),
            ),
            Text(
              'Overrides silent & Do Not Disturb — rings at $_volume% on the alarm channel.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _SectionLabel('Snooze'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [5, 10, 15].map((m) {
                final on = _snooze == m;
                return ChoiceChip(
                  label: Text('$m min'),
                  selected: on,
                  onSelected: (_) => setState(() => _snooze = m),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: on
                          ? AppColors.onPrimary
                          : theme.colorScheme.onSurface),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _vibrate,
              onChanged: (v) => setState(() => _vibrate = v),
              title: const Text('Vibrate'),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: isEdit ? 'Save changes' : 'Create alarm',
              loading: _loading,
              onPressed: _save,
            ),
            if (isEdit && _loaded) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(fontWeight: FontWeight.w700));
}

class _ComingSoonChip extends StatelessWidget {
  const _ComingSoonChip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Chip(
        label: Text('$label · soon',
            style: Theme.of(context).textTheme.labelSmall),
        visualDensity: VisualDensity.compact,
      );
}
