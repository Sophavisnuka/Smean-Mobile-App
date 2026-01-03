import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;
part 'database.g.dart';

// ====================
// TABLE DEFINITIONS
// ====================

/// App Session table - Stores the current logged-in user (single row)
class AppSession extends Table {
  IntColumn get id => integer().autoIncrement()(); // Always 1 row
  TextColumn get currentUserId => text().nullable()();
  TextColumn get languageCode =>
      text().withDefault(const Constant('en'))(); // 'en' or 'km'
  DateTimeColumn get lastUpdated => dateTime()();
}

/// Users table - Local authentication (multiple users per device)
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get imagePath => text().nullable()();

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

@DriftDatabase(tables: [AppSession, Users, Cards, Audios, Transcripts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add AppSession table
          await m.createTable(appSession);
        } 
        if (from < 3) {
          // add new column
          await m.addColumn(users, users.imagePath as GeneratedColumn<Object>);
        }
      },
    );
  }

  // ====================
  // HELPER: Open Connection (Cross-Platform)
  // ====================
  static QueryExecutor _openConnection() {
    return impl.connect('smean_app_db');
  }
}
