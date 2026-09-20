// Drift Database - Offline-first local storage (Updated for Drift 2.x)
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Tables
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get childName => text().withLength(min: 1, max: 50)();
  IntColumn get totalStars => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  IntColumn get id => integer()();
  IntColumn get dailyLimitMinutes => integer().withDefault(const Constant(30))();
  RealColumn get soundVolume => real().withDefault(const Constant(1.0))();
  RealColumn get musicVolume => real().withDefault(const Constant(0.7))();
  BoolColumn get parentalGateEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get lastResetDate => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LevelProgress extends Table {
  TextColumn get id => text()();
  TextColumn get levelId => text()();
  IntColumn get starsEarned => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get bestTimeMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {levelId},
  ];
}

class StickerCollection extends Table {
  TextColumn get id => text()();
  TextColumn get stickerId => text()();
  IntColumn get unlockedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {stickerId},
  ];
}

// Database
@DriftDatabase(tables: [Profiles, Settings, LevelProgress, StickerCollection])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle future migrations
    },
    beforeOpen: (details) async {
      // Insert default settings after database is created
      if (details.wasCreated) {
        await into(settings).insert(SettingsCompanion.insert(
          id: const Value(1),
          dailyLimitMinutes: const Value(30),
          soundVolume: const Value(1.0),
          musicVolume: const Value(0.7),
          parentalGateEnabled: const Value(true),
        ));
      }
    },
  );

  // DAOs
  ProfileDao get profileDao => ProfileDao(this);
  SettingsDao get settingsDao => SettingsDao(this);
  LevelProgressDao get levelProgressDao => LevelProgressDao(this);
  StickerCollectionDao get stickerCollectionDao => StickerCollectionDao(this);
}

DatabaseConnection _openConnection() {
    return driftDatabase(
      name: 'kids_adventure',
      native: DriftNativeOptions(
        databasePath: () async {
          final dir = await getApplicationDocumentsDirectory();
          return p.join(dir.path, 'kids_adventure.db');
        },
      ),
    );
  }

// DAOs
class ProfileDao {
  final AppDatabase _db;

  ProfileDao(this._db);

  Future<Profile?> getProfile() async {
    final query = _db.select(_db.profiles)..limit(1);
    return await query.getSingleOrNull();
  }

  Stream<Profile?> watchProfile() {
    return (_db.select(_db.profiles)..limit(1))
        .watchSingleOrNull();
  }

  Future<void> createProfile(String id, String name) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    await _db.into(_db.profiles).insert(ProfilesCompanion.insert(
      id: id,
      childName: name,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> updateProfile(Profile profile) async {
    await _db.update(_db.profiles).replace(ProfilesCompanion(
      id: Value(profile.id),
      childName: Value(profile.childName),
      totalStars: Value(profile.totalStars),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  Future<void> addStars(int stars) async {
    final Profile? profile = await getProfile();
    if (profile != null) {
      await updateProfile(profile.copyWith(
        totalStars: profile.totalStars + stars,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }
}

class SettingsDao {
  final AppDatabase _db;

  SettingsDao(this._db);

  Future<Setting> getSettings() async {
    final query = _db.select(_db.settings)..where((s) => s.id.equals(1));
    final Setting? result = await query.getSingleOrNull();
    return result ?? Setting(
      id: 1,
      dailyLimitMinutes: 30,
      soundVolume: 1.0,
      musicVolume: 0.7,
      parentalGateEnabled: true,
    );
  }

  Stream<Setting> watchSettings() {
    return (_db.select(_db.settings)..where((s) => s.id.equals(1)))
        .watchSingle()
        .map((Setting row) => Setting(
          id: row.id,
          dailyLimitMinutes: row.dailyLimitMinutes,
          soundVolume: row.soundVolume,
          musicVolume: row.musicVolume,
          parentalGateEnabled: row.parentalGateEnabled,
          lastResetDate: row.lastResetDate,
        ));
  }

  Future<void> updateSettings({
    int? dailyLimitMinutes,
    double? soundVolume,
    double? musicVolume,
    bool? parentalGateEnabled,
    int? lastResetDate,
  }) async {
    await _db.into(_db.settings).insertOnConflictUpdate(SettingsCompanion(
      id: const Value(1),
      dailyLimitMinutes: dailyLimitMinutes != null ? Value(dailyLimitMinutes) : const Value.absent(),
      soundVolume: soundVolume != null ? Value(soundVolume) : const Value.absent(),
      musicVolume: musicVolume != null ? Value(musicVolume) : const Value.absent(),
      parentalGateEnabled: parentalGateEnabled != null ? Value(parentalGateEnabled) : const Value.absent(),
      lastResetDate: lastResetDate != null ? Value(lastResetDate) : const Value.absent(),
    ));
  }
}

class LevelProgressDao {
  final AppDatabase _db;

  LevelProgressDao(this._db);

  Future<LevelProgressData?> getLevelProgress(String levelId) async {
    final query = _db.select(_db.levelProgress)..where((lp) => lp.levelId.equals(levelId));
    return await query.getSingleOrNull();
  }

  Stream<LevelProgressData?> watchLevelProgress(String levelId) {
    return (_db.select(_db.levelProgress)..where((lp) => lp.levelId.equals(levelId)))
        .watchSingleOrNull();
  }

  Future<List<LevelProgressData>> getAllProgress() async {
    return await _db.select(_db.levelProgress).get();
  }

  Stream<List<LevelProgressData>> watchAllProgress() {
    return _db.select(_db.levelProgress).watch();
  }

  Future<void> updateProgress(LevelProgressData progress) async {
    await _db.into(_db.levelProgress).insertOnConflictUpdate(LevelProgressCompanion(
      id: Value(progress.id),
      levelId: Value(progress.levelId),
      starsEarned: Value(progress.starsEarned),
      isCompleted: Value(progress.isCompleted),
      completedAt: progress.completedAt != null ? Value(progress.completedAt!) : const Value.absent(),
      attempts: Value(progress.attempts),
      bestTimeMs: progress.bestTimeMs != null ? Value(progress.bestTimeMs!) : const Value.absent(),
    ));
  }

  Future<void> completeLevel({
    required String levelId,
    required int starsEarned,
    required int timeMs,
    required bool hadMistakes,
  }) async {
    final LevelProgressData? existing = await getLevelProgress(levelId);
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int attempts = (existing?.attempts ?? 0) + 1;
    final bool isNewCompletion = existing?.isCompleted != true;
    final int bestTime = existing?.bestTimeMs != null
        ? (timeMs < existing!.bestTimeMs! ? timeMs : existing.bestTimeMs!)
        : timeMs;

    final int newStars = existing?.starsEarned != null && existing!.starsEarned > starsEarned
        ? existing.starsEarned
        : starsEarned;

    await _db.into(_db.levelProgress).insertOnConflictUpdate(LevelProgressCompanion(
      id: Value(levelId),
      levelId: Value(levelId),
      starsEarned: Value(newStars),
      isCompleted: const Value(true),
      completedAt: isNewCompletion ? Value(now) : Value(existing?.completedAt ?? now),
      attempts: Value(attempts),
      bestTimeMs: Value(bestTime),
    ));

    // Add stars to profile if this is a new completion or better stars
    if (isNewCompletion || newStars > (existing?.starsEarned ?? 0)) {
      final ProfileDao profileDao = ProfileDao(_db);
      final int starsToAdd = isNewCompletion ? starsEarned : (newStars - (existing?.starsEarned ?? 0));
      await profileDao.addStars(starsToAdd);
    }
  }
}

class StickerCollectionDao {
  final AppDatabase _db;

  StickerCollectionDao(this._db);

  Future<bool> hasSticker(String stickerId) async {
    final query = _db.select(_db.stickerCollection)..where((s) => s.stickerId.equals(stickerId));
    final StickerCollectionData? result = await query.getSingleOrNull();
    return result != null;
  }

  Stream<bool> watchHasSticker(String stickerId) {
    return (_db.select(_db.stickerCollection)..where((s) => s.stickerId.equals(stickerId)))
        .watchSingleOrNull()
        .map((StickerCollectionData? row) => row != null);
  }

  Future<List<StickerCollectionData>> getAllStickers() async {
    return await _db.select(_db.stickerCollection).get();
  }

  Stream<List<StickerCollectionData>> watchAllStickers() {
    return _db.select(_db.stickerCollection).watch();
  }

  Future<void> unlockSticker(String stickerId) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    await _db.into(_db.stickerCollection).insertOnConflictUpdate(StickerCollectionCompanion.insert(
      id: stickerId,
      stickerId: stickerId,
      unlockedAt: now,
    ));
  }
}