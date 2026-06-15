// Smoke tests for Wakio domain logic that don't require platform plugins
// (alarms/camera/db need a device). Widget-level tests live alongside features.

import 'package:flutter_test/flutter_test.dart';
import 'package:scan_alarm/data/models/challenge.dart';

void main() {
  group('Challenge.offlineFor', () {
    test('is deterministic for a given day', () {
      final day = DateTime(2026, 6, 14);
      expect(Challenge.offlineFor(day).objectClass,
          Challenge.offlineFor(day).objectClass);
    });

    test('display name is title-cased', () {
      final c = Challenge.offlineFor(DateTime(2026, 1, 1));
      expect(c.displayName[0], c.displayName[0].toUpperCase());
    });
  });
}
