import 'package:flutter/material.dart';

import '../../core/storage/app_database.dart';

/// Display + scheduling + serialization helpers for the Drift [Alarm] row.
extension AlarmX on Alarm {
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  List<int> get repeatDayList => repeatDays.isEmpty
      ? const []
      : repeatDays.split(',').map(int.parse).toList();

  bool get isOneShot => repeatDayList.isEmpty;

  String formattedTime(BuildContext context) =>
      MaterialLocalizations.of(context).formatTimeOfDay(timeOfDay);

  String get repeatLabel {
    final days = repeatDayList;
    if (days.isEmpty) return 'Once';
    if (days.length == 7) return 'Every day';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return (days.toList()..sort()).map((d) => names[d]).join(' ');
  }

  /// Next DateTime this alarm should fire from [from].
  DateTime nextOccurrence(DateTime from) {
    final days = repeatDayList;
    var candidate =
        DateTime(from.year, from.month, from.day, hour, minute);
    if (days.isEmpty) {
      if (!candidate.isAfter(from)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return candidate;
    }
    for (var i = 0; i < 8; i++) {
      final c = candidate.add(Duration(days: i));
      // DateTime.weekday: Mon=1..Sun=7 -> our 0=Mon..6=Sun
      if (days.contains(c.weekday - 1) && c.isAfter(from)) return c;
    }
    return candidate; // unreachable in practice
  }

  /// Human "in 6h 32m" countdown to next ring.
  String countdownLabel(DateTime from) {
    final diff = nextOccurrence(from).difference(from);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h <= 0) return '${m}m remaining';
    return '${h}h ${m}m remaining';
  }

  Map<String, dynamic> toApiJson() => {
        'id': id,
        'label': label,
        'time':
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00',
        'repeat_days': repeatDayList,
        'challenge_type': challengeType,
        'volume': volume,
        'snooze_minutes': snoozeMinutes,
        'vibrate': vibrate,
        'enabled': enabled,
      };
}
