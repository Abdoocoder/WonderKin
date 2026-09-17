// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childNameMeta =
      const VerificationMeta('childName');
  @override
  late final GeneratedColumn<String> childName = GeneratedColumn<String>(
      'child_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _totalStarsMeta =
      const VerificationMeta('totalStars');
  @override
  late final GeneratedColumn<int> totalStars = GeneratedColumn<int>(
      'total_stars', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, childName, totalStars, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_name')) {
      context.handle(_childNameMeta,
          childName.isAcceptableOrUnknown(data['child_name']!, _childNameMeta));
    } else if (isInserting) {
      context.missing(_childNameMeta);
    }
    if (data.containsKey('total_stars')) {
      context.handle(
          _totalStarsMeta,
          totalStars.isAcceptableOrUnknown(
              data['total_stars']!, _totalStarsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_name'])!,
      totalStars: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_stars'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String childName;
  final int totalStars;
  final int createdAt;
  final int updatedAt;
  const Profile(
      {required this.id,
      required this.childName,
      required this.totalStars,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_name'] = Variable<String>(childName);
    map['total_stars'] = Variable<int>(totalStars);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      childName: Value(childName),
      totalStars: Value(totalStars),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      childName: serializer.fromJson<String>(json['childName']),
      totalStars: serializer.fromJson<int>(json['totalStars']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childName': serializer.toJson<String>(childName),
      'totalStars': serializer.toJson<int>(totalStars),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Profile copyWith(
          {String? id,
          String? childName,
          int? totalStars,
          int? createdAt,
          int? updatedAt}) =>
      Profile(
        id: id ?? this.id,
        childName: childName ?? this.childName,
        totalStars: totalStars ?? this.totalStars,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      childName: data.childName.present ? data.childName.value : this.childName,
      totalStars:
          data.totalStars.present ? data.totalStars.value : this.totalStars,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('childName: $childName, ')
          ..write('totalStars: $totalStars, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, childName, totalStars, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.childName == this.childName &&
          other.totalStars == this.totalStars &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String> childName;
  final Value<int> totalStars;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.childName = const Value.absent(),
    this.totalStars = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required String childName,
    this.totalStars = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childName = Value(childName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? childName,
    Expression<int>? totalStars,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childName != null) 'child_name': childName,
      if (totalStars != null) 'total_stars': totalStars,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? childName,
      Value<int>? totalStars,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return ProfilesCompanion(
      id: id ?? this.id,
      childName: childName ?? this.childName,
      totalStars: totalStars ?? this.totalStars,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childName.present) {
      map['child_name'] = Variable<String>(childName.value);
    }
    if (totalStars.present) {
      map['total_stars'] = Variable<int>(totalStars.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('childName: $childName, ')
          ..write('totalStars: $totalStars, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dailyLimitMinutesMeta =
      const VerificationMeta('dailyLimitMinutes');
  @override
  late final GeneratedColumn<int> dailyLimitMinutes = GeneratedColumn<int>(
      'daily_limit_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _soundVolumeMeta =
      const VerificationMeta('soundVolume');
  @override
  late final GeneratedColumn<double> soundVolume = GeneratedColumn<double>(
      'sound_volume', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _musicVolumeMeta =
      const VerificationMeta('musicVolume');
  @override
  late final GeneratedColumn<double> musicVolume = GeneratedColumn<double>(
      'music_volume', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.7));
  static const VerificationMeta _parentalGateEnabledMeta =
      const VerificationMeta('parentalGateEnabled');
  @override
  late final GeneratedColumn<bool> parentalGateEnabled = GeneratedColumn<bool>(
      'parental_gate_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("parental_gate_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastResetDateMeta =
      const VerificationMeta('lastResetDate');
  @override
  late final GeneratedColumn<int> lastResetDate = GeneratedColumn<int>(
      'last_reset_date', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dailyLimitMinutes,
        soundVolume,
        musicVolume,
        parentalGateEnabled,
        lastResetDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_limit_minutes')) {
      context.handle(
          _dailyLimitMinutesMeta,
          dailyLimitMinutes.isAcceptableOrUnknown(
              data['daily_limit_minutes']!, _dailyLimitMinutesMeta));
    }
    if (data.containsKey('sound_volume')) {
      context.handle(
          _soundVolumeMeta,
          soundVolume.isAcceptableOrUnknown(
              data['sound_volume']!, _soundVolumeMeta));
    }
    if (data.containsKey('music_volume')) {
      context.handle(
          _musicVolumeMeta,
          musicVolume.isAcceptableOrUnknown(
              data['music_volume']!, _musicVolumeMeta));
    }
    if (data.containsKey('parental_gate_enabled')) {
      context.handle(
          _parentalGateEnabledMeta,
          parentalGateEnabled.isAcceptableOrUnknown(
              data['parental_gate_enabled']!, _parentalGateEnabledMeta));
    }
    if (data.containsKey('last_reset_date')) {
      context.handle(
          _lastResetDateMeta,
          lastResetDate.isAcceptableOrUnknown(
              data['last_reset_date']!, _lastResetDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dailyLimitMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}daily_limit_minutes'])!,
      soundVolume: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sound_volume'])!,
      musicVolume: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}music_volume'])!,
      parentalGateEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}parental_gate_enabled'])!,
      lastResetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_reset_date']),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final int dailyLimitMinutes;
  final double soundVolume;
  final double musicVolume;
  final bool parentalGateEnabled;
  final int? lastResetDate;
  const Setting(
      {required this.id,
      required this.dailyLimitMinutes,
      required this.soundVolume,
      required this.musicVolume,
      required this.parentalGateEnabled,
      this.lastResetDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_limit_minutes'] = Variable<int>(dailyLimitMinutes);
    map['sound_volume'] = Variable<double>(soundVolume);
    map['music_volume'] = Variable<double>(musicVolume);
    map['parental_gate_enabled'] = Variable<bool>(parentalGateEnabled);
    if (!nullToAbsent || lastResetDate != null) {
      map['last_reset_date'] = Variable<int>(lastResetDate);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      dailyLimitMinutes: Value(dailyLimitMinutes),
      soundVolume: Value(soundVolume),
      musicVolume: Value(musicVolume),
      parentalGateEnabled: Value(parentalGateEnabled),
      lastResetDate: lastResetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastResetDate),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      dailyLimitMinutes: serializer.fromJson<int>(json['dailyLimitMinutes']),
      soundVolume: serializer.fromJson<double>(json['soundVolume']),
      musicVolume: serializer.fromJson<double>(json['musicVolume']),
      parentalGateEnabled:
          serializer.fromJson<bool>(json['parentalGateEnabled']),
      lastResetDate: serializer.fromJson<int?>(json['lastResetDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailyLimitMinutes': serializer.toJson<int>(dailyLimitMinutes),
      'soundVolume': serializer.toJson<double>(soundVolume),
      'musicVolume': serializer.toJson<double>(musicVolume),
      'parentalGateEnabled': serializer.toJson<bool>(parentalGateEnabled),
      'lastResetDate': serializer.toJson<int?>(lastResetDate),
    };
  }

  Setting copyWith(
          {int? id,
          int? dailyLimitMinutes,
          double? soundVolume,
          double? musicVolume,
          bool? parentalGateEnabled,
          Value<int?> lastResetDate = const Value.absent()}) =>
      Setting(
        id: id ?? this.id,
        dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
        soundVolume: soundVolume ?? this.soundVolume,
        musicVolume: musicVolume ?? this.musicVolume,
        parentalGateEnabled: parentalGateEnabled ?? this.parentalGateEnabled,
        lastResetDate:
            lastResetDate.present ? lastResetDate.value : this.lastResetDate,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      dailyLimitMinutes: data.dailyLimitMinutes.present
          ? data.dailyLimitMinutes.value
          : this.dailyLimitMinutes,
      soundVolume:
          data.soundVolume.present ? data.soundVolume.value : this.soundVolume,
      musicVolume:
          data.musicVolume.present ? data.musicVolume.value : this.musicVolume,
      parentalGateEnabled: data.parentalGateEnabled.present
          ? data.parentalGateEnabled.value
          : this.parentalGateEnabled,
      lastResetDate: data.lastResetDate.present
          ? data.lastResetDate.value
          : this.lastResetDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('dailyLimitMinutes: $dailyLimitMinutes, ')
          ..write('soundVolume: $soundVolume, ')
          ..write('musicVolume: $musicVolume, ')
          ..write('parentalGateEnabled: $parentalGateEnabled, ')
          ..write('lastResetDate: $lastResetDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dailyLimitMinutes, soundVolume,
      musicVolume, parentalGateEnabled, lastResetDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.dailyLimitMinutes == this.dailyLimitMinutes &&
          other.soundVolume == this.soundVolume &&
          other.musicVolume == this.musicVolume &&
          other.parentalGateEnabled == this.parentalGateEnabled &&
          other.lastResetDate == this.lastResetDate);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<int> dailyLimitMinutes;
  final Value<double> soundVolume;
  final Value<double> musicVolume;
  final Value<bool> parentalGateEnabled;
  final Value<int?> lastResetDate;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.dailyLimitMinutes = const Value.absent(),
    this.soundVolume = const Value.absent(),
    this.musicVolume = const Value.absent(),
    this.parentalGateEnabled = const Value.absent(),
    this.lastResetDate = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.dailyLimitMinutes = const Value.absent(),
    this.soundVolume = const Value.absent(),
    this.musicVolume = const Value.absent(),
    this.parentalGateEnabled = const Value.absent(),
    this.lastResetDate = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<int>? dailyLimitMinutes,
    Expression<double>? soundVolume,
    Expression<double>? musicVolume,
    Expression<bool>? parentalGateEnabled,
    Expression<int>? lastResetDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyLimitMinutes != null) 'daily_limit_minutes': dailyLimitMinutes,
      if (soundVolume != null) 'sound_volume': soundVolume,
      if (musicVolume != null) 'music_volume': musicVolume,
      if (parentalGateEnabled != null)
        'parental_gate_enabled': parentalGateEnabled,
      if (lastResetDate != null) 'last_reset_date': lastResetDate,
    });
  }

  SettingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? dailyLimitMinutes,
      Value<double>? soundVolume,
      Value<double>? musicVolume,
      Value<bool>? parentalGateEnabled,
      Value<int?>? lastResetDate}) {
    return SettingsCompanion(
      id: id ?? this.id,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      soundVolume: soundVolume ?? this.soundVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      parentalGateEnabled: parentalGateEnabled ?? this.parentalGateEnabled,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailyLimitMinutes.present) {
      map['daily_limit_minutes'] = Variable<int>(dailyLimitMinutes.value);
    }
    if (soundVolume.present) {
      map['sound_volume'] = Variable<double>(soundVolume.value);
    }
    if (musicVolume.present) {
      map['music_volume'] = Variable<double>(musicVolume.value);
    }
    if (parentalGateEnabled.present) {
      map['parental_gate_enabled'] = Variable<bool>(parentalGateEnabled.value);
    }
    if (lastResetDate.present) {
      map['last_reset_date'] = Variable<int>(lastResetDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('dailyLimitMinutes: $dailyLimitMinutes, ')
          ..write('soundVolume: $soundVolume, ')
          ..write('musicVolume: $musicVolume, ')
          ..write('parentalGateEnabled: $parentalGateEnabled, ')
          ..write('lastResetDate: $lastResetDate')
          ..write(')'))
        .toString();
  }
}

class $LevelProgressTable extends LevelProgress
    with TableInfo<$LevelProgressTable, LevelProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LevelProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _levelIdMeta =
      const VerificationMeta('levelId');
  @override
  late final GeneratedColumn<String> levelId = GeneratedColumn<String>(
      'level_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _starsEarnedMeta =
      const VerificationMeta('starsEarned');
  @override
  late final GeneratedColumn<int> starsEarned = GeneratedColumn<int>(
      'stars_earned', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _bestTimeMsMeta =
      const VerificationMeta('bestTimeMs');
  @override
  late final GeneratedColumn<int> bestTimeMs = GeneratedColumn<int>(
      'best_time_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        levelId,
        starsEarned,
        isCompleted,
        completedAt,
        attempts,
        bestTimeMs
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'level_progress';
  @override
  VerificationContext validateIntegrity(Insertable<LevelProgressData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('level_id')) {
      context.handle(_levelIdMeta,
          levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta));
    } else if (isInserting) {
      context.missing(_levelIdMeta);
    }
    if (data.containsKey('stars_earned')) {
      context.handle(
          _starsEarnedMeta,
          starsEarned.isAcceptableOrUnknown(
              data['stars_earned']!, _starsEarnedMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('best_time_ms')) {
      context.handle(
          _bestTimeMsMeta,
          bestTimeMs.isAcceptableOrUnknown(
              data['best_time_ms']!, _bestTimeMsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {levelId},
      ];
  @override
  LevelProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LevelProgressData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      levelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level_id'])!,
      starsEarned: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stars_earned'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_at']),
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      bestTimeMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}best_time_ms']),
    );
  }

  @override
  $LevelProgressTable createAlias(String alias) {
    return $LevelProgressTable(attachedDatabase, alias);
  }
}

class LevelProgressData extends DataClass
    implements Insertable<LevelProgressData> {
  final String id;
  final String levelId;
  final int starsEarned;
  final bool isCompleted;
  final int? completedAt;
  final int attempts;
  final int? bestTimeMs;
  const LevelProgressData(
      {required this.id,
      required this.levelId,
      required this.starsEarned,
      required this.isCompleted,
      this.completedAt,
      required this.attempts,
      this.bestTimeMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['level_id'] = Variable<String>(levelId);
    map['stars_earned'] = Variable<int>(starsEarned);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || bestTimeMs != null) {
      map['best_time_ms'] = Variable<int>(bestTimeMs);
    }
    return map;
  }

  LevelProgressCompanion toCompanion(bool nullToAbsent) {
    return LevelProgressCompanion(
      id: Value(id),
      levelId: Value(levelId),
      starsEarned: Value(starsEarned),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      attempts: Value(attempts),
      bestTimeMs: bestTimeMs == null && nullToAbsent
          ? const Value.absent()
          : Value(bestTimeMs),
    );
  }

  factory LevelProgressData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LevelProgressData(
      id: serializer.fromJson<String>(json['id']),
      levelId: serializer.fromJson<String>(json['levelId']),
      starsEarned: serializer.fromJson<int>(json['starsEarned']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      bestTimeMs: serializer.fromJson<int?>(json['bestTimeMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'levelId': serializer.toJson<String>(levelId),
      'starsEarned': serializer.toJson<int>(starsEarned),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<int?>(completedAt),
      'attempts': serializer.toJson<int>(attempts),
      'bestTimeMs': serializer.toJson<int?>(bestTimeMs),
    };
  }

  LevelProgressData copyWith(
          {String? id,
          String? levelId,
          int? starsEarned,
          bool? isCompleted,
          Value<int?> completedAt = const Value.absent(),
          int? attempts,
          Value<int?> bestTimeMs = const Value.absent()}) =>
      LevelProgressData(
        id: id ?? this.id,
        levelId: levelId ?? this.levelId,
        starsEarned: starsEarned ?? this.starsEarned,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        attempts: attempts ?? this.attempts,
        bestTimeMs: bestTimeMs.present ? bestTimeMs.value : this.bestTimeMs,
      );
  LevelProgressData copyWithCompanion(LevelProgressCompanion data) {
    return LevelProgressData(
      id: data.id.present ? data.id.value : this.id,
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      starsEarned:
          data.starsEarned.present ? data.starsEarned.value : this.starsEarned,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      bestTimeMs:
          data.bestTimeMs.present ? data.bestTimeMs.value : this.bestTimeMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LevelProgressData(')
          ..write('id: $id, ')
          ..write('levelId: $levelId, ')
          ..write('starsEarned: $starsEarned, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('attempts: $attempts, ')
          ..write('bestTimeMs: $bestTimeMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, levelId, starsEarned, isCompleted, completedAt, attempts, bestTimeMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LevelProgressData &&
          other.id == this.id &&
          other.levelId == this.levelId &&
          other.starsEarned == this.starsEarned &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.attempts == this.attempts &&
          other.bestTimeMs == this.bestTimeMs);
}

class LevelProgressCompanion extends UpdateCompanion<LevelProgressData> {
  final Value<String> id;
  final Value<String> levelId;
  final Value<int> starsEarned;
  final Value<bool> isCompleted;
  final Value<int?> completedAt;
  final Value<int> attempts;
  final Value<int?> bestTimeMs;
  final Value<int> rowid;
  const LevelProgressCompanion({
    this.id = const Value.absent(),
    this.levelId = const Value.absent(),
    this.starsEarned = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.bestTimeMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LevelProgressCompanion.insert({
    required String id,
    required String levelId,
    this.starsEarned = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.bestTimeMs = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        levelId = Value(levelId);
  static Insertable<LevelProgressData> custom({
    Expression<String>? id,
    Expression<String>? levelId,
    Expression<int>? starsEarned,
    Expression<bool>? isCompleted,
    Expression<int>? completedAt,
    Expression<int>? attempts,
    Expression<int>? bestTimeMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (levelId != null) 'level_id': levelId,
      if (starsEarned != null) 'stars_earned': starsEarned,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (attempts != null) 'attempts': attempts,
      if (bestTimeMs != null) 'best_time_ms': bestTimeMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LevelProgressCompanion copyWith(
      {Value<String>? id,
      Value<String>? levelId,
      Value<int>? starsEarned,
      Value<bool>? isCompleted,
      Value<int?>? completedAt,
      Value<int>? attempts,
      Value<int?>? bestTimeMs,
      Value<int>? rowid}) {
    return LevelProgressCompanion(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      starsEarned: starsEarned ?? this.starsEarned,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      attempts: attempts ?? this.attempts,
      bestTimeMs: bestTimeMs ?? this.bestTimeMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (levelId.present) {
      map['level_id'] = Variable<String>(levelId.value);
    }
    if (starsEarned.present) {
      map['stars_earned'] = Variable<int>(starsEarned.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (bestTimeMs.present) {
      map['best_time_ms'] = Variable<int>(bestTimeMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LevelProgressCompanion(')
          ..write('id: $id, ')
          ..write('levelId: $levelId, ')
          ..write('starsEarned: $starsEarned, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('attempts: $attempts, ')
          ..write('bestTimeMs: $bestTimeMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StickerCollectionTable extends StickerCollection
    with TableInfo<$StickerCollectionTable, StickerCollectionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StickerCollectionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stickerIdMeta =
      const VerificationMeta('stickerId');
  @override
  late final GeneratedColumn<String> stickerId = GeneratedColumn<String>(
      'sticker_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unlockedAtMeta =
      const VerificationMeta('unlockedAt');
  @override
  late final GeneratedColumn<int> unlockedAt = GeneratedColumn<int>(
      'unlocked_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, stickerId, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sticker_collection';
  @override
  VerificationContext validateIntegrity(
      Insertable<StickerCollectionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sticker_id')) {
      context.handle(_stickerIdMeta,
          stickerId.isAcceptableOrUnknown(data['sticker_id']!, _stickerIdMeta));
    } else if (isInserting) {
      context.missing(_stickerIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
          _unlockedAtMeta,
          unlockedAt.isAcceptableOrUnknown(
              data['unlocked_at']!, _unlockedAtMeta));
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {stickerId},
      ];
  @override
  StickerCollectionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StickerCollectionData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      stickerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sticker_id'])!,
      unlockedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unlocked_at'])!,
    );
  }

  @override
  $StickerCollectionTable createAlias(String alias) {
    return $StickerCollectionTable(attachedDatabase, alias);
  }
}

class StickerCollectionData extends DataClass
    implements Insertable<StickerCollectionData> {
  final String id;
  final String stickerId;
  final int unlockedAt;
  const StickerCollectionData(
      {required this.id, required this.stickerId, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sticker_id'] = Variable<String>(stickerId);
    map['unlocked_at'] = Variable<int>(unlockedAt);
    return map;
  }

  StickerCollectionCompanion toCompanion(bool nullToAbsent) {
    return StickerCollectionCompanion(
      id: Value(id),
      stickerId: Value(stickerId),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory StickerCollectionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StickerCollectionData(
      id: serializer.fromJson<String>(json['id']),
      stickerId: serializer.fromJson<String>(json['stickerId']),
      unlockedAt: serializer.fromJson<int>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'stickerId': serializer.toJson<String>(stickerId),
      'unlockedAt': serializer.toJson<int>(unlockedAt),
    };
  }

  StickerCollectionData copyWith(
          {String? id, String? stickerId, int? unlockedAt}) =>
      StickerCollectionData(
        id: id ?? this.id,
        stickerId: stickerId ?? this.stickerId,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
  StickerCollectionData copyWithCompanion(StickerCollectionCompanion data) {
    return StickerCollectionData(
      id: data.id.present ? data.id.value : this.id,
      stickerId: data.stickerId.present ? data.stickerId.value : this.stickerId,
      unlockedAt:
          data.unlockedAt.present ? data.unlockedAt.value : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StickerCollectionData(')
          ..write('id: $id, ')
          ..write('stickerId: $stickerId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, stickerId, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StickerCollectionData &&
          other.id == this.id &&
          other.stickerId == this.stickerId &&
          other.unlockedAt == this.unlockedAt);
}

class StickerCollectionCompanion
    extends UpdateCompanion<StickerCollectionData> {
  final Value<String> id;
  final Value<String> stickerId;
  final Value<int> unlockedAt;
  final Value<int> rowid;
  const StickerCollectionCompanion({
    this.id = const Value.absent(),
    this.stickerId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StickerCollectionCompanion.insert({
    required String id,
    required String stickerId,
    required int unlockedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        stickerId = Value(stickerId),
        unlockedAt = Value(unlockedAt);
  static Insertable<StickerCollectionData> custom({
    Expression<String>? id,
    Expression<String>? stickerId,
    Expression<int>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stickerId != null) 'sticker_id': stickerId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StickerCollectionCompanion copyWith(
      {Value<String>? id,
      Value<String>? stickerId,
      Value<int>? unlockedAt,
      Value<int>? rowid}) {
    return StickerCollectionCompanion(
      id: id ?? this.id,
      stickerId: stickerId ?? this.stickerId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (stickerId.present) {
      map['sticker_id'] = Variable<String>(stickerId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<int>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StickerCollectionCompanion(')
          ..write('id: $id, ')
          ..write('stickerId: $stickerId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $LevelProgressTable levelProgress = $LevelProgressTable(this);
  late final $StickerCollectionTable stickerCollection =
      $StickerCollectionTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [profiles, settings, levelProgress, stickerCollection];
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String id,
  required String childName,
  Value<int> totalStars,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> id,
  Value<String> childName,
  Value<int> totalStars,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get childName => $composableBuilder(
      column: $table.childName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalStars => $composableBuilder(
      column: $table.totalStars, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get childName => $composableBuilder(
      column: $table.childName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalStars => $composableBuilder(
      column: $table.totalStars, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childName =>
      $composableBuilder(column: $table.childName, builder: (column) => column);

  GeneratedColumn<int> get totalStars => $composableBuilder(
      column: $table.totalStars, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
    Profile,
    PrefetchHooks Function()> {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childName = const Value.absent(),
            Value<int> totalStars = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion(
            id: id,
            childName: childName,
            totalStars: totalStars,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childName,
            Value<int> totalStars = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion.insert(
            id: id,
            childName: childName,
            totalStars: totalStars,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ProfilesTable, Profile>(table),
                    BaseReferences<_$AppDatabase, $ProfilesTable, Profile>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
    Profile,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<int> dailyLimitMinutes,
  Value<double> soundVolume,
  Value<double> musicVolume,
  Value<bool> parentalGateEnabled,
  Value<int?> lastResetDate,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<int> dailyLimitMinutes,
  Value<double> soundVolume,
  Value<double> musicVolume,
  Value<bool> parentalGateEnabled,
  Value<int?> lastResetDate,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyLimitMinutes => $composableBuilder(
      column: $table.dailyLimitMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get soundVolume => $composableBuilder(
      column: $table.soundVolume, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get musicVolume => $composableBuilder(
      column: $table.musicVolume, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get parentalGateEnabled => $composableBuilder(
      column: $table.parentalGateEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastResetDate => $composableBuilder(
      column: $table.lastResetDate, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyLimitMinutes => $composableBuilder(
      column: $table.dailyLimitMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get soundVolume => $composableBuilder(
      column: $table.soundVolume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get musicVolume => $composableBuilder(
      column: $table.musicVolume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get parentalGateEnabled => $composableBuilder(
      column: $table.parentalGateEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastResetDate => $composableBuilder(
      column: $table.lastResetDate,
      builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dailyLimitMinutes => $composableBuilder(
      column: $table.dailyLimitMinutes, builder: (column) => column);

  GeneratedColumn<double> get soundVolume => $composableBuilder(
      column: $table.soundVolume, builder: (column) => column);

  GeneratedColumn<double> get musicVolume => $composableBuilder(
      column: $table.musicVolume, builder: (column) => column);

  GeneratedColumn<bool> get parentalGateEnabled => $composableBuilder(
      column: $table.parentalGateEnabled, builder: (column) => column);

  GeneratedColumn<int> get lastResetDate => $composableBuilder(
      column: $table.lastResetDate, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> dailyLimitMinutes = const Value.absent(),
            Value<double> soundVolume = const Value.absent(),
            Value<double> musicVolume = const Value.absent(),
            Value<bool> parentalGateEnabled = const Value.absent(),
            Value<int?> lastResetDate = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            dailyLimitMinutes: dailyLimitMinutes,
            soundVolume: soundVolume,
            musicVolume: musicVolume,
            parentalGateEnabled: parentalGateEnabled,
            lastResetDate: lastResetDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> dailyLimitMinutes = const Value.absent(),
            Value<double> soundVolume = const Value.absent(),
            Value<double> musicVolume = const Value.absent(),
            Value<bool> parentalGateEnabled = const Value.absent(),
            Value<int?> lastResetDate = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            id: id,
            dailyLimitMinutes: dailyLimitMinutes,
            soundVolume: soundVolume,
            musicVolume: musicVolume,
            parentalGateEnabled: parentalGateEnabled,
            lastResetDate: lastResetDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SettingsTable, Setting>(table),
                    BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
typedef $$LevelProgressTableCreateCompanionBuilder = LevelProgressCompanion
    Function({
  required String id,
  required String levelId,
  Value<int> starsEarned,
  Value<bool> isCompleted,
  Value<int?> completedAt,
  Value<int> attempts,
  Value<int?> bestTimeMs,
  Value<int> rowid,
});
typedef $$LevelProgressTableUpdateCompanionBuilder = LevelProgressCompanion
    Function({
  Value<String> id,
  Value<String> levelId,
  Value<int> starsEarned,
  Value<bool> isCompleted,
  Value<int?> completedAt,
  Value<int> attempts,
  Value<int?> bestTimeMs,
  Value<int> rowid,
});

class $$LevelProgressTableFilterComposer
    extends Composer<_$AppDatabase, $LevelProgressTable> {
  $$LevelProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get levelId => $composableBuilder(
      column: $table.levelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get starsEarned => $composableBuilder(
      column: $table.starsEarned, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bestTimeMs => $composableBuilder(
      column: $table.bestTimeMs, builder: (column) => ColumnFilters(column));
}

class $$LevelProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $LevelProgressTable> {
  $$LevelProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get levelId => $composableBuilder(
      column: $table.levelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get starsEarned => $composableBuilder(
      column: $table.starsEarned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bestTimeMs => $composableBuilder(
      column: $table.bestTimeMs, builder: (column) => ColumnOrderings(column));
}

class $$LevelProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $LevelProgressTable> {
  $$LevelProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<int> get starsEarned => $composableBuilder(
      column: $table.starsEarned, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get bestTimeMs => $composableBuilder(
      column: $table.bestTimeMs, builder: (column) => column);
}

class $$LevelProgressTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LevelProgressTable,
    LevelProgressData,
    $$LevelProgressTableFilterComposer,
    $$LevelProgressTableOrderingComposer,
    $$LevelProgressTableAnnotationComposer,
    $$LevelProgressTableCreateCompanionBuilder,
    $$LevelProgressTableUpdateCompanionBuilder,
    (
      LevelProgressData,
      BaseReferences<_$AppDatabase, $LevelProgressTable, LevelProgressData>
    ),
    LevelProgressData,
    PrefetchHooks Function()> {
  $$LevelProgressTableTableManager(_$AppDatabase db, $LevelProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LevelProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LevelProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LevelProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> levelId = const Value.absent(),
            Value<int> starsEarned = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int?> bestTimeMs = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LevelProgressCompanion(
            id: id,
            levelId: levelId,
            starsEarned: starsEarned,
            isCompleted: isCompleted,
            completedAt: completedAt,
            attempts: attempts,
            bestTimeMs: bestTimeMs,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String levelId,
            Value<int> starsEarned = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int?> bestTimeMs = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LevelProgressCompanion.insert(
            id: id,
            levelId: levelId,
            starsEarned: starsEarned,
            isCompleted: isCompleted,
            completedAt: completedAt,
            attempts: attempts,
            bestTimeMs: bestTimeMs,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LevelProgressTable, LevelProgressData>(table),
                    BaseReferences<_$AppDatabase, $LevelProgressTable,
                        LevelProgressData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LevelProgressTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LevelProgressTable,
    LevelProgressData,
    $$LevelProgressTableFilterComposer,
    $$LevelProgressTableOrderingComposer,
    $$LevelProgressTableAnnotationComposer,
    $$LevelProgressTableCreateCompanionBuilder,
    $$LevelProgressTableUpdateCompanionBuilder,
    (
      LevelProgressData,
      BaseReferences<_$AppDatabase, $LevelProgressTable, LevelProgressData>
    ),
    LevelProgressData,
    PrefetchHooks Function()>;
typedef $$StickerCollectionTableCreateCompanionBuilder
    = StickerCollectionCompanion Function({
  required String id,
  required String stickerId,
  required int unlockedAt,
  Value<int> rowid,
});
typedef $$StickerCollectionTableUpdateCompanionBuilder
    = StickerCollectionCompanion Function({
  Value<String> id,
  Value<String> stickerId,
  Value<int> unlockedAt,
  Value<int> rowid,
});

class $$StickerCollectionTableFilterComposer
    extends Composer<_$AppDatabase, $StickerCollectionTable> {
  $$StickerCollectionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stickerId => $composableBuilder(
      column: $table.stickerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnFilters(column));
}

class $$StickerCollectionTableOrderingComposer
    extends Composer<_$AppDatabase, $StickerCollectionTable> {
  $$StickerCollectionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stickerId => $composableBuilder(
      column: $table.stickerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnOrderings(column));
}

class $$StickerCollectionTableAnnotationComposer
    extends Composer<_$AppDatabase, $StickerCollectionTable> {
  $$StickerCollectionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stickerId =>
      $composableBuilder(column: $table.stickerId, builder: (column) => column);

  GeneratedColumn<int> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => column);
}

class $$StickerCollectionTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StickerCollectionTable,
    StickerCollectionData,
    $$StickerCollectionTableFilterComposer,
    $$StickerCollectionTableOrderingComposer,
    $$StickerCollectionTableAnnotationComposer,
    $$StickerCollectionTableCreateCompanionBuilder,
    $$StickerCollectionTableUpdateCompanionBuilder,
    (
      StickerCollectionData,
      BaseReferences<_$AppDatabase, $StickerCollectionTable,
          StickerCollectionData>
    ),
    StickerCollectionData,
    PrefetchHooks Function()> {
  $$StickerCollectionTableTableManager(
      _$AppDatabase db, $StickerCollectionTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StickerCollectionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StickerCollectionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StickerCollectionTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> stickerId = const Value.absent(),
            Value<int> unlockedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StickerCollectionCompanion(
            id: id,
            stickerId: stickerId,
            unlockedAt: unlockedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String stickerId,
            required int unlockedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StickerCollectionCompanion.insert(
            id: id,
            stickerId: stickerId,
            unlockedAt: unlockedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$StickerCollectionTable, StickerCollectionData>(
                        table),
                    BaseReferences<_$AppDatabase, $StickerCollectionTable,
                        StickerCollectionData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StickerCollectionTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StickerCollectionTable,
    StickerCollectionData,
    $$StickerCollectionTableFilterComposer,
    $$StickerCollectionTableOrderingComposer,
    $$StickerCollectionTableAnnotationComposer,
    $$StickerCollectionTableCreateCompanionBuilder,
    $$StickerCollectionTableUpdateCompanionBuilder,
    (
      StickerCollectionData,
      BaseReferences<_$AppDatabase, $StickerCollectionTable,
          StickerCollectionData>
    ),
    StickerCollectionData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$LevelProgressTableTableManager get levelProgress =>
      $$LevelProgressTableTableManager(_db, _db.levelProgress);
  $$StickerCollectionTableTableManager get stickerCollection =>
      $$StickerCollectionTableTableManager(_db, _db.stickerCollection);
}
