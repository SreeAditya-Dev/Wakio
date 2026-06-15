import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'app_database.g.dart';

/// Local alarms (offline-first source of truth). Mirrors the backend `alarms`
/// table; `synced` flags whether the row has been pushed to the server.
class Alarms extends Table {
  TextColumn get id => text()(); // uuid (client-generated for offline-first)
  TextColumn get label => text().withDefault(const Constant('Alarm'))();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  TextColumn get repeatDays => text().withDefault(const Constant(''))(); // "0,1,2"
  TextColumn get challengeType =>
      text().withDefault(const Constant('object_scan'))();
  IntColumn get volume => integer().withDefault(const Constant(100))();
  IntColumn get snoozeMinutes => integer().withDefault(const Constant(5))();
  BoolColumn get vibrate => boolean().withDefault(const Constant(true))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get scheduledId => integer()(); // stable int id for the OS alarm
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local record of each time an alarm fired and whether it was completed.
class History extends Table {
  TextColumn get id => text()();
  TextColumn get alarmId => text().nullable()();
  DateTimeColumn get firedAt => dateTime()();
  TextColumn get challengeObject => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get wakeTime => dateTime().nullable()();
  IntColumn get points => integer().withDefault(const Constant(0))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Alarms, History])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // --- Alarms ---
  Stream<List<Alarm>> watchAlarms() =>
      (select(alarms)..where((t) => t.deleted.equals(false))).watch();

  Future<List<Alarm>> activeAlarms() =>
      (select(alarms)..where((t) => t.deleted.equals(false) & t.enabled.equals(true)))
          .get();

  Future<void> upsertAlarm(AlarmsCompanion alarm) =>
      into(alarms).insertOnConflictUpdate(alarm);

  Future<Alarm?> alarmById(String id) =>
      (select(alarms)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> softDeleteAlarm(String id) =>
      (update(alarms)..where((t) => t.id.equals(id))).write(
        AlarmsCompanion(
          deleted: const Value(true),
          synced: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<List<Alarm>> unsyncedAlarms() =>
      (select(alarms)..where((t) => t.synced.equals(false))).get();

  Future<void> markAlarmSynced(String id) =>
      (update(alarms)..where((t) => t.id.equals(id)))
          .write(const AlarmsCompanion(synced: Value(true)));

  // --- History ---
  Future<void> insertHistory(HistoryCompanion h) =>
      into(history).insertOnConflictUpdate(h);

  Stream<List<HistoryData>> watchHistory() =>
      (select(history)..orderBy([(t) => OrderingTerm.desc(t.firedAt)])).watch();
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'scan_alarm.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
