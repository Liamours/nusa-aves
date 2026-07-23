import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/bird_sighting.dart';

/// Persistence for [BirdSighting] records, backed by SQLite. Replaces the
/// in-memory `sampleSightings` list so recordings survive an app restart.
class DatabaseService {
  static const _dbName = 'nusa_aves.db';
  static const _table = 'sightings';
  static const _speciesTable = 'species';

  static const _createSightingsTable = '''
    CREATE TABLE sightings (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      scientificName TEXT NOT NULL,
      imageUrl TEXT NOT NULL,
      accuracy TEXT NOT NULL,
      accuracyValue INTEGER NOT NULL,
      recordedAt INTEGER NOT NULL,
      location TEXT NOT NULL,
      audioDuration TEXT NOT NULL,
      isAudioOnly INTEGER NOT NULL,
      category TEXT NOT NULL,
      overview TEXT NOT NULL,
      isEndemic INTEGER NOT NULL,
      endangeredStatus TEXT NOT NULL,
      temperature TEXT NOT NULL,
      weatherCondition TEXT NOT NULL,
      audioFilePath TEXT
    )
  ''';

  /// Reference table for all 219 target species, seeded once from the
  /// bundled CSVs by SpeciesRepository.ensureLoaded() — see
  /// mobile-user/DATABASE.md for why this exists alongside `sightings`
  /// (catalog browsing, stats/filter queries that need a real join,
  /// neither of which an in-memory Map can do).
  static const _createSpeciesTable = '''
    CREATE TABLE species (
      scientific_name TEXT PRIMARY KEY,
      common_english TEXT,
      common_indonesian TEXT,
      description TEXT,
      image_url TEXT,
      endangerment_category TEXT NOT NULL,
      is_endemic_malaysia INTEGER NOT NULL,
      is_endemic_indonesia INTEGER NOT NULL,
      source_url_1 TEXT,
      source_url_2 TEXT
    )
  ''';

  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(_createSightingsTable);
        await db.execute(_createSpeciesTable);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(_createSpeciesTable);
        }
      },
    );
  }

  Future<void> insertSighting(BirdSighting sighting) async {
    final db = await _database;
    await db.insert(
      _table,
      sighting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BirdSighting>> getAllSightings() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'recordedAt DESC');
    return rows.map(BirdSighting.fromMap).toList();
  }

  Future<BirdSighting?> getSightingById(String id) async {
    final db = await _database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return BirdSighting.fromMap(rows.first);
  }

  Future<void> deleteSighting(String id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getSpeciesCount() async {
    final db = await _database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_speciesTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Batch-inserts species rows in one transaction. Called once by
  /// SpeciesRepository.ensureLoaded() when the table is empty — not meant
  /// to be called with a partial/incremental row set.
  Future<void> seedSpecies(List<Map<String, Object?>> rows) async {
    final db = await _database;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert(_speciesTable, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, Object?>>> getAllSpecies() async {
    final db = await _database;
    return db.query(_speciesTable, orderBy: 'scientific_name ASC');
  }

  Future<Map<String, Object?>?> getSpeciesByScientificName(String scientificName) async {
    final db = await _database;
    final rows = await db.query(
      _speciesTable,
      where: 'scientific_name = ?',
      whereArgs: [scientificName],
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, Object?>>> getSpeciesByStatus(String endangermentCategory) async {
    final db = await _database;
    return db.query(
      _speciesTable,
      where: 'endangerment_category = ?',
      whereArgs: [endangermentCategory],
      orderBy: 'scientific_name ASC',
    );
  }
}
