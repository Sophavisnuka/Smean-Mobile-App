import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ====================
// TABLE DEFINITIONS
// ====================

/// Users table - Local authentication (multiple users per device)
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cards table - Main entity representing a transcription card
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get cardName => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Audios table - Audio files linked to cards (recorded or uploaded)
class Audios extends Table {
  TextColumn get id => text()();
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text()(); // Local path to audio file
  TextColumn get sourceType => text()(); // 'recorded' or 'uploaded'
  IntColumn get duration => integer()(); // Duration in seconds
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Transcripts table - Transcription text linked to cards
class Transcripts extends Table {
  TextColumn get id => text()();
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();
  TextColumn get transcriptionText =>
      text()(); // The transcription text (editable)
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ====================
// DATABASE CLASS
// ====================

@DriftDatabase(tables: [Users, Cards, Audios, Transcripts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ====================
  // HELPER: Open Connection (Cross-Platform)
  // ====================
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'smean_app_db',
      // Use native SQLite on mobile/desktop, IndexedDB on web
      native: DriftNativeOptions(shareAcrossIsolates: true),
    );
  }
}
