// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AlarmsTable extends Alarms with TableInfo<$AlarmsTable, Alarm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlarmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Alarm'),
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatDaysMeta = const VerificationMeta(
    'repeatDays',
  );
  @override
  late final GeneratedColumn<String> repeatDays = GeneratedColumn<String>(
    'repeat_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _challengeTypeMeta = const VerificationMeta(
    'challengeType',
  );
  @override
  late final GeneratedColumn<String> challengeType = GeneratedColumn<String>(
    'challenge_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('object_scan'),
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<int> volume = GeneratedColumn<int>(
    'volume',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _snoozeMinutesMeta = const VerificationMeta(
    'snoozeMinutes',
  );
  @override
  late final GeneratedColumn<int> snoozeMinutes = GeneratedColumn<int>(
    'snooze_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _vibrateMeta = const VerificationMeta(
    'vibrate',
  );
  @override
  late final GeneratedColumn<bool> vibrate = GeneratedColumn<bool>(
    'vibrate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibrate" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _soundPathMeta = const VerificationMeta(
    'soundPath',
  );
  @override
  late final GeneratedColumn<String> soundPath = GeneratedColumn<String>(
    'sound_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soundNameMeta = const VerificationMeta(
    'soundName',
  );
  @override
  late final GeneratedColumn<String> soundName = GeneratedColumn<String>(
    'sound_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _scheduledIdMeta = const VerificationMeta(
    'scheduledId',
  );
  @override
  late final GeneratedColumn<int> scheduledId = GeneratedColumn<int>(
    'scheduled_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    hour,
    minute,
    repeatDays,
    challengeType,
    volume,
    snoozeMinutes,
    vibrate,
    soundPath,
    soundName,
    enabled,
    scheduledId,
    updatedAt,
    synced,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alarms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Alarm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    if (data.containsKey('repeat_days')) {
      context.handle(
        _repeatDaysMeta,
        repeatDays.isAcceptableOrUnknown(data['repeat_days']!, _repeatDaysMeta),
      );
    }
    if (data.containsKey('challenge_type')) {
      context.handle(
        _challengeTypeMeta,
        challengeType.isAcceptableOrUnknown(
          data['challenge_type']!,
          _challengeTypeMeta,
        ),
      );
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    if (data.containsKey('snooze_minutes')) {
      context.handle(
        _snoozeMinutesMeta,
        snoozeMinutes.isAcceptableOrUnknown(
          data['snooze_minutes']!,
          _snoozeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('vibrate')) {
      context.handle(
        _vibrateMeta,
        vibrate.isAcceptableOrUnknown(data['vibrate']!, _vibrateMeta),
      );
    }
    if (data.containsKey('sound_path')) {
      context.handle(
        _soundPathMeta,
        soundPath.isAcceptableOrUnknown(data['sound_path']!, _soundPathMeta),
      );
    }
    if (data.containsKey('sound_name')) {
      context.handle(
        _soundNameMeta,
        soundName.isAcceptableOrUnknown(data['sound_name']!, _soundNameMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('scheduled_id')) {
      context.handle(
        _scheduledIdMeta,
        scheduledId.isAcceptableOrUnknown(
          data['scheduled_id']!,
          _scheduledIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Alarm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Alarm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
      repeatDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_days'],
      )!,
      challengeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}challenge_type'],
      )!,
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume'],
      )!,
      snoozeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_minutes'],
      )!,
      vibrate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibrate'],
      )!,
      soundPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_path'],
      ),
      soundName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_name'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      scheduledId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $AlarmsTable createAlias(String alias) {
    return $AlarmsTable(attachedDatabase, alias);
  }
}

class Alarm extends DataClass implements Insertable<Alarm> {
  final String id;
  final String label;
  final int hour;
  final int minute;
  final String repeatDays;
  final String challengeType;
  final int volume;
  final int snoozeMinutes;
  final bool vibrate;
  final String? soundPath;
  final String? soundName;
  final bool enabled;
  final int scheduledId;
  final DateTime updatedAt;
  final bool synced;
  final bool deleted;
  const Alarm({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    required this.repeatDays,
    required this.challengeType,
    required this.volume,
    required this.snoozeMinutes,
    required this.vibrate,
    this.soundPath,
    this.soundName,
    required this.enabled,
    required this.scheduledId,
    required this.updatedAt,
    required this.synced,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    map['repeat_days'] = Variable<String>(repeatDays);
    map['challenge_type'] = Variable<String>(challengeType);
    map['volume'] = Variable<int>(volume);
    map['snooze_minutes'] = Variable<int>(snoozeMinutes);
    map['vibrate'] = Variable<bool>(vibrate);
    if (!nullToAbsent || soundPath != null) {
      map['sound_path'] = Variable<String>(soundPath);
    }
    if (!nullToAbsent || soundName != null) {
      map['sound_name'] = Variable<String>(soundName);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['scheduled_id'] = Variable<int>(scheduledId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  AlarmsCompanion toCompanion(bool nullToAbsent) {
    return AlarmsCompanion(
      id: Value(id),
      label: Value(label),
      hour: Value(hour),
      minute: Value(minute),
      repeatDays: Value(repeatDays),
      challengeType: Value(challengeType),
      volume: Value(volume),
      snoozeMinutes: Value(snoozeMinutes),
      vibrate: Value(vibrate),
      soundPath: soundPath == null && nullToAbsent
          ? const Value.absent()
          : Value(soundPath),
      soundName: soundName == null && nullToAbsent
          ? const Value.absent()
          : Value(soundName),
      enabled: Value(enabled),
      scheduledId: Value(scheduledId),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      deleted: Value(deleted),
    );
  }

  factory Alarm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Alarm(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
      repeatDays: serializer.fromJson<String>(json['repeatDays']),
      challengeType: serializer.fromJson<String>(json['challengeType']),
      volume: serializer.fromJson<int>(json['volume']),
      snoozeMinutes: serializer.fromJson<int>(json['snoozeMinutes']),
      vibrate: serializer.fromJson<bool>(json['vibrate']),
      soundPath: serializer.fromJson<String?>(json['soundPath']),
      soundName: serializer.fromJson<String?>(json['soundName']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      scheduledId: serializer.fromJson<int>(json['scheduledId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
      'repeatDays': serializer.toJson<String>(repeatDays),
      'challengeType': serializer.toJson<String>(challengeType),
      'volume': serializer.toJson<int>(volume),
      'snoozeMinutes': serializer.toJson<int>(snoozeMinutes),
      'vibrate': serializer.toJson<bool>(vibrate),
      'soundPath': serializer.toJson<String?>(soundPath),
      'soundName': serializer.toJson<String?>(soundName),
      'enabled': serializer.toJson<bool>(enabled),
      'scheduledId': serializer.toJson<int>(scheduledId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  Alarm copyWith({
    String? id,
    String? label,
    int? hour,
    int? minute,
    String? repeatDays,
    String? challengeType,
    int? volume,
    int? snoozeMinutes,
    bool? vibrate,
    Value<String?> soundPath = const Value.absent(),
    Value<String?> soundName = const Value.absent(),
    bool? enabled,
    int? scheduledId,
    DateTime? updatedAt,
    bool? synced,
    bool? deleted,
  }) => Alarm(
    id: id ?? this.id,
    label: label ?? this.label,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    repeatDays: repeatDays ?? this.repeatDays,
    challengeType: challengeType ?? this.challengeType,
    volume: volume ?? this.volume,
    snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    vibrate: vibrate ?? this.vibrate,
    soundPath: soundPath.present ? soundPath.value : this.soundPath,
    soundName: soundName.present ? soundName.value : this.soundName,
    enabled: enabled ?? this.enabled,
    scheduledId: scheduledId ?? this.scheduledId,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
    deleted: deleted ?? this.deleted,
  );
  Alarm copyWithCompanion(AlarmsCompanion data) {
    return Alarm(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
      repeatDays: data.repeatDays.present
          ? data.repeatDays.value
          : this.repeatDays,
      challengeType: data.challengeType.present
          ? data.challengeType.value
          : this.challengeType,
      volume: data.volume.present ? data.volume.value : this.volume,
      snoozeMinutes: data.snoozeMinutes.present
          ? data.snoozeMinutes.value
          : this.snoozeMinutes,
      vibrate: data.vibrate.present ? data.vibrate.value : this.vibrate,
      soundPath: data.soundPath.present ? data.soundPath.value : this.soundPath,
      soundName: data.soundName.present ? data.soundName.value : this.soundName,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      scheduledId: data.scheduledId.present
          ? data.scheduledId.value
          : this.scheduledId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Alarm(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('challengeType: $challengeType, ')
          ..write('volume: $volume, ')
          ..write('snoozeMinutes: $snoozeMinutes, ')
          ..write('vibrate: $vibrate, ')
          ..write('soundPath: $soundPath, ')
          ..write('soundName: $soundName, ')
          ..write('enabled: $enabled, ')
          ..write('scheduledId: $scheduledId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    hour,
    minute,
    repeatDays,
    challengeType,
    volume,
    snoozeMinutes,
    vibrate,
    soundPath,
    soundName,
    enabled,
    scheduledId,
    updatedAt,
    synced,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Alarm &&
          other.id == this.id &&
          other.label == this.label &&
          other.hour == this.hour &&
          other.minute == this.minute &&
          other.repeatDays == this.repeatDays &&
          other.challengeType == this.challengeType &&
          other.volume == this.volume &&
          other.snoozeMinutes == this.snoozeMinutes &&
          other.vibrate == this.vibrate &&
          other.soundPath == this.soundPath &&
          other.soundName == this.soundName &&
          other.enabled == this.enabled &&
          other.scheduledId == this.scheduledId &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.deleted == this.deleted);
}

class AlarmsCompanion extends UpdateCompanion<Alarm> {
  final Value<String> id;
  final Value<String> label;
  final Value<int> hour;
  final Value<int> minute;
  final Value<String> repeatDays;
  final Value<String> challengeType;
  final Value<int> volume;
  final Value<int> snoozeMinutes;
  final Value<bool> vibrate;
  final Value<String?> soundPath;
  final Value<String?> soundName;
  final Value<bool> enabled;
  final Value<int> scheduledId;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<bool> deleted;
  final Value<int> rowid;
  const AlarmsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.challengeType = const Value.absent(),
    this.volume = const Value.absent(),
    this.snoozeMinutes = const Value.absent(),
    this.vibrate = const Value.absent(),
    this.soundPath = const Value.absent(),
    this.soundName = const Value.absent(),
    this.enabled = const Value.absent(),
    this.scheduledId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlarmsCompanion.insert({
    required String id,
    this.label = const Value.absent(),
    required int hour,
    required int minute,
    this.repeatDays = const Value.absent(),
    this.challengeType = const Value.absent(),
    this.volume = const Value.absent(),
    this.snoozeMinutes = const Value.absent(),
    this.vibrate = const Value.absent(),
    this.soundPath = const Value.absent(),
    this.soundName = const Value.absent(),
    this.enabled = const Value.absent(),
    required int scheduledId,
    required DateTime updatedAt,
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hour = Value(hour),
       minute = Value(minute),
       scheduledId = Value(scheduledId),
       updatedAt = Value(updatedAt);
  static Insertable<Alarm> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<String>? repeatDays,
    Expression<String>? challengeType,
    Expression<int>? volume,
    Expression<int>? snoozeMinutes,
    Expression<bool>? vibrate,
    Expression<String>? soundPath,
    Expression<String>? soundName,
    Expression<bool>? enabled,
    Expression<int>? scheduledId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<bool>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (challengeType != null) 'challenge_type': challengeType,
      if (volume != null) 'volume': volume,
      if (snoozeMinutes != null) 'snooze_minutes': snoozeMinutes,
      if (vibrate != null) 'vibrate': vibrate,
      if (soundPath != null) 'sound_path': soundPath,
      if (soundName != null) 'sound_name': soundName,
      if (enabled != null) 'enabled': enabled,
      if (scheduledId != null) 'scheduled_id': scheduledId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlarmsCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<int>? hour,
    Value<int>? minute,
    Value<String>? repeatDays,
    Value<String>? challengeType,
    Value<int>? volume,
    Value<int>? snoozeMinutes,
    Value<bool>? vibrate,
    Value<String?>? soundPath,
    Value<String?>? soundName,
    Value<bool>? enabled,
    Value<int>? scheduledId,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<bool>? deleted,
    Value<int>? rowid,
  }) {
    return AlarmsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatDays: repeatDays ?? this.repeatDays,
      challengeType: challengeType ?? this.challengeType,
      volume: volume ?? this.volume,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      vibrate: vibrate ?? this.vibrate,
      soundPath: soundPath ?? this.soundPath,
      soundName: soundName ?? this.soundName,
      enabled: enabled ?? this.enabled,
      scheduledId: scheduledId ?? this.scheduledId,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (repeatDays.present) {
      map['repeat_days'] = Variable<String>(repeatDays.value);
    }
    if (challengeType.present) {
      map['challenge_type'] = Variable<String>(challengeType.value);
    }
    if (volume.present) {
      map['volume'] = Variable<int>(volume.value);
    }
    if (snoozeMinutes.present) {
      map['snooze_minutes'] = Variable<int>(snoozeMinutes.value);
    }
    if (vibrate.present) {
      map['vibrate'] = Variable<bool>(vibrate.value);
    }
    if (soundPath.present) {
      map['sound_path'] = Variable<String>(soundPath.value);
    }
    if (soundName.present) {
      map['sound_name'] = Variable<String>(soundName.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (scheduledId.present) {
      map['scheduled_id'] = Variable<int>(scheduledId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlarmsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('challengeType: $challengeType, ')
          ..write('volume: $volume, ')
          ..write('snoozeMinutes: $snoozeMinutes, ')
          ..write('vibrate: $vibrate, ')
          ..write('soundPath: $soundPath, ')
          ..write('soundName: $soundName, ')
          ..write('enabled: $enabled, ')
          ..write('scheduledId: $scheduledId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryTable extends History with TableInfo<$HistoryTable, HistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alarmIdMeta = const VerificationMeta(
    'alarmId',
  );
  @override
  late final GeneratedColumn<String> alarmId = GeneratedColumn<String>(
    'alarm_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firedAtMeta = const VerificationMeta(
    'firedAt',
  );
  @override
  late final GeneratedColumn<DateTime> firedAt = GeneratedColumn<DateTime>(
    'fired_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _challengeObjectMeta = const VerificationMeta(
    'challengeObject',
  );
  @override
  late final GeneratedColumn<String> challengeObject = GeneratedColumn<String>(
    'challenge_object',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wakeTimeMeta = const VerificationMeta(
    'wakeTime',
  );
  @override
  late final GeneratedColumn<DateTime> wakeTime = GeneratedColumn<DateTime>(
    'wake_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recheckStatusMeta = const VerificationMeta(
    'recheckStatus',
  );
  @override
  late final GeneratedColumn<String> recheckStatus = GeneratedColumn<String>(
    'recheck_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _recheckAtMeta = const VerificationMeta(
    'recheckAt',
  );
  @override
  late final GeneratedColumn<DateTime> recheckAt = GeneratedColumn<DateTime>(
    'recheck_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    alarmId,
    firedAt,
    challengeObject,
    completed,
    wakeTime,
    points,
    synced,
    recheckStatus,
    recheckAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('alarm_id')) {
      context.handle(
        _alarmIdMeta,
        alarmId.isAcceptableOrUnknown(data['alarm_id']!, _alarmIdMeta),
      );
    }
    if (data.containsKey('fired_at')) {
      context.handle(
        _firedAtMeta,
        firedAt.isAcceptableOrUnknown(data['fired_at']!, _firedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_firedAtMeta);
    }
    if (data.containsKey('challenge_object')) {
      context.handle(
        _challengeObjectMeta,
        challengeObject.isAcceptableOrUnknown(
          data['challenge_object']!,
          _challengeObjectMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('wake_time')) {
      context.handle(
        _wakeTimeMeta,
        wakeTime.isAcceptableOrUnknown(data['wake_time']!, _wakeTimeMeta),
      );
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('recheck_status')) {
      context.handle(
        _recheckStatusMeta,
        recheckStatus.isAcceptableOrUnknown(
          data['recheck_status']!,
          _recheckStatusMeta,
        ),
      );
    }
    if (data.containsKey('recheck_at')) {
      context.handle(
        _recheckAtMeta,
        recheckAt.isAcceptableOrUnknown(data['recheck_at']!, _recheckAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      alarmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alarm_id'],
      ),
      firedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fired_at'],
      )!,
      challengeObject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}challenge_object'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      wakeTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}wake_time'],
      ),
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      recheckStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recheck_status'],
      )!,
      recheckAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recheck_at'],
      ),
    );
  }

  @override
  $HistoryTable createAlias(String alias) {
    return $HistoryTable(attachedDatabase, alias);
  }
}

class HistoryData extends DataClass implements Insertable<HistoryData> {
  final String id;
  final String? alarmId;
  final DateTime firedAt;
  final String? challengeObject;
  final bool completed;
  final DateTime? wakeTime;
  final int points;
  final bool synced;
  final String recheckStatus;
  final DateTime? recheckAt;
  const HistoryData({
    required this.id,
    this.alarmId,
    required this.firedAt,
    this.challengeObject,
    required this.completed,
    this.wakeTime,
    required this.points,
    required this.synced,
    required this.recheckStatus,
    this.recheckAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || alarmId != null) {
      map['alarm_id'] = Variable<String>(alarmId);
    }
    map['fired_at'] = Variable<DateTime>(firedAt);
    if (!nullToAbsent || challengeObject != null) {
      map['challenge_object'] = Variable<String>(challengeObject);
    }
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || wakeTime != null) {
      map['wake_time'] = Variable<DateTime>(wakeTime);
    }
    map['points'] = Variable<int>(points);
    map['synced'] = Variable<bool>(synced);
    map['recheck_status'] = Variable<String>(recheckStatus);
    if (!nullToAbsent || recheckAt != null) {
      map['recheck_at'] = Variable<DateTime>(recheckAt);
    }
    return map;
  }

  HistoryCompanion toCompanion(bool nullToAbsent) {
    return HistoryCompanion(
      id: Value(id),
      alarmId: alarmId == null && nullToAbsent
          ? const Value.absent()
          : Value(alarmId),
      firedAt: Value(firedAt),
      challengeObject: challengeObject == null && nullToAbsent
          ? const Value.absent()
          : Value(challengeObject),
      completed: Value(completed),
      wakeTime: wakeTime == null && nullToAbsent
          ? const Value.absent()
          : Value(wakeTime),
      points: Value(points),
      synced: Value(synced),
      recheckStatus: Value(recheckStatus),
      recheckAt: recheckAt == null && nullToAbsent
          ? const Value.absent()
          : Value(recheckAt),
    );
  }

  factory HistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryData(
      id: serializer.fromJson<String>(json['id']),
      alarmId: serializer.fromJson<String?>(json['alarmId']),
      firedAt: serializer.fromJson<DateTime>(json['firedAt']),
      challengeObject: serializer.fromJson<String?>(json['challengeObject']),
      completed: serializer.fromJson<bool>(json['completed']),
      wakeTime: serializer.fromJson<DateTime?>(json['wakeTime']),
      points: serializer.fromJson<int>(json['points']),
      synced: serializer.fromJson<bool>(json['synced']),
      recheckStatus: serializer.fromJson<String>(json['recheckStatus']),
      recheckAt: serializer.fromJson<DateTime?>(json['recheckAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'alarmId': serializer.toJson<String?>(alarmId),
      'firedAt': serializer.toJson<DateTime>(firedAt),
      'challengeObject': serializer.toJson<String?>(challengeObject),
      'completed': serializer.toJson<bool>(completed),
      'wakeTime': serializer.toJson<DateTime?>(wakeTime),
      'points': serializer.toJson<int>(points),
      'synced': serializer.toJson<bool>(synced),
      'recheckStatus': serializer.toJson<String>(recheckStatus),
      'recheckAt': serializer.toJson<DateTime?>(recheckAt),
    };
  }

  HistoryData copyWith({
    String? id,
    Value<String?> alarmId = const Value.absent(),
    DateTime? firedAt,
    Value<String?> challengeObject = const Value.absent(),
    bool? completed,
    Value<DateTime?> wakeTime = const Value.absent(),
    int? points,
    bool? synced,
    String? recheckStatus,
    Value<DateTime?> recheckAt = const Value.absent(),
  }) => HistoryData(
    id: id ?? this.id,
    alarmId: alarmId.present ? alarmId.value : this.alarmId,
    firedAt: firedAt ?? this.firedAt,
    challengeObject: challengeObject.present
        ? challengeObject.value
        : this.challengeObject,
    completed: completed ?? this.completed,
    wakeTime: wakeTime.present ? wakeTime.value : this.wakeTime,
    points: points ?? this.points,
    synced: synced ?? this.synced,
    recheckStatus: recheckStatus ?? this.recheckStatus,
    recheckAt: recheckAt.present ? recheckAt.value : this.recheckAt,
  );
  HistoryData copyWithCompanion(HistoryCompanion data) {
    return HistoryData(
      id: data.id.present ? data.id.value : this.id,
      alarmId: data.alarmId.present ? data.alarmId.value : this.alarmId,
      firedAt: data.firedAt.present ? data.firedAt.value : this.firedAt,
      challengeObject: data.challengeObject.present
          ? data.challengeObject.value
          : this.challengeObject,
      completed: data.completed.present ? data.completed.value : this.completed,
      wakeTime: data.wakeTime.present ? data.wakeTime.value : this.wakeTime,
      points: data.points.present ? data.points.value : this.points,
      synced: data.synced.present ? data.synced.value : this.synced,
      recheckStatus: data.recheckStatus.present
          ? data.recheckStatus.value
          : this.recheckStatus,
      recheckAt: data.recheckAt.present ? data.recheckAt.value : this.recheckAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryData(')
          ..write('id: $id, ')
          ..write('alarmId: $alarmId, ')
          ..write('firedAt: $firedAt, ')
          ..write('challengeObject: $challengeObject, ')
          ..write('completed: $completed, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('points: $points, ')
          ..write('synced: $synced, ')
          ..write('recheckStatus: $recheckStatus, ')
          ..write('recheckAt: $recheckAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    alarmId,
    firedAt,
    challengeObject,
    completed,
    wakeTime,
    points,
    synced,
    recheckStatus,
    recheckAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryData &&
          other.id == this.id &&
          other.alarmId == this.alarmId &&
          other.firedAt == this.firedAt &&
          other.challengeObject == this.challengeObject &&
          other.completed == this.completed &&
          other.wakeTime == this.wakeTime &&
          other.points == this.points &&
          other.synced == this.synced &&
          other.recheckStatus == this.recheckStatus &&
          other.recheckAt == this.recheckAt);
}

class HistoryCompanion extends UpdateCompanion<HistoryData> {
  final Value<String> id;
  final Value<String?> alarmId;
  final Value<DateTime> firedAt;
  final Value<String?> challengeObject;
  final Value<bool> completed;
  final Value<DateTime?> wakeTime;
  final Value<int> points;
  final Value<bool> synced;
  final Value<String> recheckStatus;
  final Value<DateTime?> recheckAt;
  final Value<int> rowid;
  const HistoryCompanion({
    this.id = const Value.absent(),
    this.alarmId = const Value.absent(),
    this.firedAt = const Value.absent(),
    this.challengeObject = const Value.absent(),
    this.completed = const Value.absent(),
    this.wakeTime = const Value.absent(),
    this.points = const Value.absent(),
    this.synced = const Value.absent(),
    this.recheckStatus = const Value.absent(),
    this.recheckAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HistoryCompanion.insert({
    required String id,
    this.alarmId = const Value.absent(),
    required DateTime firedAt,
    this.challengeObject = const Value.absent(),
    this.completed = const Value.absent(),
    this.wakeTime = const Value.absent(),
    this.points = const Value.absent(),
    this.synced = const Value.absent(),
    this.recheckStatus = const Value.absent(),
    this.recheckAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       firedAt = Value(firedAt);
  static Insertable<HistoryData> custom({
    Expression<String>? id,
    Expression<String>? alarmId,
    Expression<DateTime>? firedAt,
    Expression<String>? challengeObject,
    Expression<bool>? completed,
    Expression<DateTime>? wakeTime,
    Expression<int>? points,
    Expression<bool>? synced,
    Expression<String>? recheckStatus,
    Expression<DateTime>? recheckAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alarmId != null) 'alarm_id': alarmId,
      if (firedAt != null) 'fired_at': firedAt,
      if (challengeObject != null) 'challenge_object': challengeObject,
      if (completed != null) 'completed': completed,
      if (wakeTime != null) 'wake_time': wakeTime,
      if (points != null) 'points': points,
      if (synced != null) 'synced': synced,
      if (recheckStatus != null) 'recheck_status': recheckStatus,
      if (recheckAt != null) 'recheck_at': recheckAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistoryCompanion copyWith({
    Value<String>? id,
    Value<String?>? alarmId,
    Value<DateTime>? firedAt,
    Value<String?>? challengeObject,
    Value<bool>? completed,
    Value<DateTime?>? wakeTime,
    Value<int>? points,
    Value<bool>? synced,
    Value<String>? recheckStatus,
    Value<DateTime?>? recheckAt,
    Value<int>? rowid,
  }) {
    return HistoryCompanion(
      id: id ?? this.id,
      alarmId: alarmId ?? this.alarmId,
      firedAt: firedAt ?? this.firedAt,
      challengeObject: challengeObject ?? this.challengeObject,
      completed: completed ?? this.completed,
      wakeTime: wakeTime ?? this.wakeTime,
      points: points ?? this.points,
      synced: synced ?? this.synced,
      recheckStatus: recheckStatus ?? this.recheckStatus,
      recheckAt: recheckAt ?? this.recheckAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (alarmId.present) {
      map['alarm_id'] = Variable<String>(alarmId.value);
    }
    if (firedAt.present) {
      map['fired_at'] = Variable<DateTime>(firedAt.value);
    }
    if (challengeObject.present) {
      map['challenge_object'] = Variable<String>(challengeObject.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (wakeTime.present) {
      map['wake_time'] = Variable<DateTime>(wakeTime.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (recheckStatus.present) {
      map['recheck_status'] = Variable<String>(recheckStatus.value);
    }
    if (recheckAt.present) {
      map['recheck_at'] = Variable<DateTime>(recheckAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryCompanion(')
          ..write('id: $id, ')
          ..write('alarmId: $alarmId, ')
          ..write('firedAt: $firedAt, ')
          ..write('challengeObject: $challengeObject, ')
          ..write('completed: $completed, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('points: $points, ')
          ..write('synced: $synced, ')
          ..write('recheckStatus: $recheckStatus, ')
          ..write('recheckAt: $recheckAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AlarmsTable alarms = $AlarmsTable(this);
  late final $HistoryTable history = $HistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [alarms, history];
}

typedef $$AlarmsTableCreateCompanionBuilder =
    AlarmsCompanion Function({
      required String id,
      Value<String> label,
      required int hour,
      required int minute,
      Value<String> repeatDays,
      Value<String> challengeType,
      Value<int> volume,
      Value<int> snoozeMinutes,
      Value<bool> vibrate,
      Value<String?> soundPath,
      Value<String?> soundName,
      Value<bool> enabled,
      required int scheduledId,
      required DateTime updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      Value<int> rowid,
    });
typedef $$AlarmsTableUpdateCompanionBuilder =
    AlarmsCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<int> hour,
      Value<int> minute,
      Value<String> repeatDays,
      Value<String> challengeType,
      Value<int> volume,
      Value<int> snoozeMinutes,
      Value<bool> vibrate,
      Value<String?> soundPath,
      Value<String?> soundName,
      Value<bool> enabled,
      Value<int> scheduledId,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      Value<int> rowid,
    });

class $$AlarmsTableFilterComposer
    extends Composer<_$AppDatabase, $AlarmsTable> {
  $$AlarmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get challengeType => $composableBuilder(
    column: $table.challengeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundPath => $composableBuilder(
    column: $table.soundPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundName => $composableBuilder(
    column: $table.soundName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledId => $composableBuilder(
    column: $table.scheduledId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlarmsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlarmsTable> {
  $$AlarmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get challengeType => $composableBuilder(
    column: $table.challengeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundPath => $composableBuilder(
    column: $table.soundPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundName => $composableBuilder(
    column: $table.soundName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledId => $composableBuilder(
    column: $table.scheduledId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlarmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlarmsTable> {
  $$AlarmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get challengeType => $composableBuilder(
    column: $table.challengeType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vibrate =>
      $composableBuilder(column: $table.vibrate, builder: (column) => column);

  GeneratedColumn<String> get soundPath =>
      $composableBuilder(column: $table.soundPath, builder: (column) => column);

  GeneratedColumn<String> get soundName =>
      $composableBuilder(column: $table.soundName, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get scheduledId => $composableBuilder(
    column: $table.scheduledId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$AlarmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlarmsTable,
          Alarm,
          $$AlarmsTableFilterComposer,
          $$AlarmsTableOrderingComposer,
          $$AlarmsTableAnnotationComposer,
          $$AlarmsTableCreateCompanionBuilder,
          $$AlarmsTableUpdateCompanionBuilder,
          (Alarm, BaseReferences<_$AppDatabase, $AlarmsTable, Alarm>),
          Alarm,
          PrefetchHooks Function()
        > {
  $$AlarmsTableTableManager(_$AppDatabase db, $AlarmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<String> repeatDays = const Value.absent(),
                Value<String> challengeType = const Value.absent(),
                Value<int> volume = const Value.absent(),
                Value<int> snoozeMinutes = const Value.absent(),
                Value<bool> vibrate = const Value.absent(),
                Value<String?> soundPath = const Value.absent(),
                Value<String?> soundName = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> scheduledId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlarmsCompanion(
                id: id,
                label: label,
                hour: hour,
                minute: minute,
                repeatDays: repeatDays,
                challengeType: challengeType,
                volume: volume,
                snoozeMinutes: snoozeMinutes,
                vibrate: vibrate,
                soundPath: soundPath,
                soundName: soundName,
                enabled: enabled,
                scheduledId: scheduledId,
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> label = const Value.absent(),
                required int hour,
                required int minute,
                Value<String> repeatDays = const Value.absent(),
                Value<String> challengeType = const Value.absent(),
                Value<int> volume = const Value.absent(),
                Value<int> snoozeMinutes = const Value.absent(),
                Value<bool> vibrate = const Value.absent(),
                Value<String?> soundPath = const Value.absent(),
                Value<String?> soundName = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                required int scheduledId,
                required DateTime updatedAt,
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlarmsCompanion.insert(
                id: id,
                label: label,
                hour: hour,
                minute: minute,
                repeatDays: repeatDays,
                challengeType: challengeType,
                volume: volume,
                snoozeMinutes: snoozeMinutes,
                vibrate: vibrate,
                soundPath: soundPath,
                soundName: soundName,
                enabled: enabled,
                scheduledId: scheduledId,
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlarmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlarmsTable,
      Alarm,
      $$AlarmsTableFilterComposer,
      $$AlarmsTableOrderingComposer,
      $$AlarmsTableAnnotationComposer,
      $$AlarmsTableCreateCompanionBuilder,
      $$AlarmsTableUpdateCompanionBuilder,
      (Alarm, BaseReferences<_$AppDatabase, $AlarmsTable, Alarm>),
      Alarm,
      PrefetchHooks Function()
    >;
typedef $$HistoryTableCreateCompanionBuilder =
    HistoryCompanion Function({
      required String id,
      Value<String?> alarmId,
      required DateTime firedAt,
      Value<String?> challengeObject,
      Value<bool> completed,
      Value<DateTime?> wakeTime,
      Value<int> points,
      Value<bool> synced,
      Value<String> recheckStatus,
      Value<DateTime?> recheckAt,
      Value<int> rowid,
    });
typedef $$HistoryTableUpdateCompanionBuilder =
    HistoryCompanion Function({
      Value<String> id,
      Value<String?> alarmId,
      Value<DateTime> firedAt,
      Value<String?> challengeObject,
      Value<bool> completed,
      Value<DateTime?> wakeTime,
      Value<int> points,
      Value<bool> synced,
      Value<String> recheckStatus,
      Value<DateTime?> recheckAt,
      Value<int> rowid,
    });

class $$HistoryTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alarmId => $composableBuilder(
    column: $table.alarmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firedAt => $composableBuilder(
    column: $table.firedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get challengeObject => $composableBuilder(
    column: $table.challengeObject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get wakeTime => $composableBuilder(
    column: $table.wakeTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recheckStatus => $composableBuilder(
    column: $table.recheckStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recheckAt => $composableBuilder(
    column: $table.recheckAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alarmId => $composableBuilder(
    column: $table.alarmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firedAt => $composableBuilder(
    column: $table.firedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get challengeObject => $composableBuilder(
    column: $table.challengeObject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get wakeTime => $composableBuilder(
    column: $table.wakeTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recheckStatus => $composableBuilder(
    column: $table.recheckStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recheckAt => $composableBuilder(
    column: $table.recheckAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get alarmId =>
      $composableBuilder(column: $table.alarmId, builder: (column) => column);

  GeneratedColumn<DateTime> get firedAt =>
      $composableBuilder(column: $table.firedAt, builder: (column) => column);

  GeneratedColumn<String> get challengeObject => $composableBuilder(
    column: $table.challengeObject,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get wakeTime =>
      $composableBuilder(column: $table.wakeTime, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get recheckStatus => $composableBuilder(
    column: $table.recheckStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recheckAt =>
      $composableBuilder(column: $table.recheckAt, builder: (column) => column);
}

class $$HistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryTable,
          HistoryData,
          $$HistoryTableFilterComposer,
          $$HistoryTableOrderingComposer,
          $$HistoryTableAnnotationComposer,
          $$HistoryTableCreateCompanionBuilder,
          $$HistoryTableUpdateCompanionBuilder,
          (
            HistoryData,
            BaseReferences<_$AppDatabase, $HistoryTable, HistoryData>,
          ),
          HistoryData,
          PrefetchHooks Function()
        > {
  $$HistoryTableTableManager(_$AppDatabase db, $HistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> alarmId = const Value.absent(),
                Value<DateTime> firedAt = const Value.absent(),
                Value<String?> challengeObject = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> wakeTime = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String> recheckStatus = const Value.absent(),
                Value<DateTime?> recheckAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistoryCompanion(
                id: id,
                alarmId: alarmId,
                firedAt: firedAt,
                challengeObject: challengeObject,
                completed: completed,
                wakeTime: wakeTime,
                points: points,
                synced: synced,
                recheckStatus: recheckStatus,
                recheckAt: recheckAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> alarmId = const Value.absent(),
                required DateTime firedAt,
                Value<String?> challengeObject = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> wakeTime = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String> recheckStatus = const Value.absent(),
                Value<DateTime?> recheckAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistoryCompanion.insert(
                id: id,
                alarmId: alarmId,
                firedAt: firedAt,
                challengeObject: challengeObject,
                completed: completed,
                wakeTime: wakeTime,
                points: points,
                synced: synced,
                recheckStatus: recheckStatus,
                recheckAt: recheckAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryTable,
      HistoryData,
      $$HistoryTableFilterComposer,
      $$HistoryTableOrderingComposer,
      $$HistoryTableAnnotationComposer,
      $$HistoryTableCreateCompanionBuilder,
      $$HistoryTableUpdateCompanionBuilder,
      (HistoryData, BaseReferences<_$AppDatabase, $HistoryTable, HistoryData>),
      HistoryData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AlarmsTableTableManager get alarms =>
      $$AlarmsTableTableManager(_db, _db.alarms);
  $$HistoryTableTableManager get history =>
      $$HistoryTableTableManager(_db, _db.history);
}
