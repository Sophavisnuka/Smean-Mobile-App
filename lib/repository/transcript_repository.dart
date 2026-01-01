import 'package:drift/drift.dart' as drift;
import 'package:smean_mobile_app/database/database.dart';

/// Repository for managing Transcriptions linked to Cards
class TranscriptRepository {
  final AppDatabase db;

  TranscriptRepository(this.db);

  /// Create a transcript for a card
  Future<String> createTranscript({
    required String transcriptId,
    required String cardId,
    required String text,
  }) async {
    final now = DateTime.now();

    await db
        .into(db.transcripts)
        .insert(
          TranscriptsCompanion(
            id: drift.Value(transcriptId),
            cardId: drift.Value(cardId),
            transcriptionText: drift.Value(text),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ),
        );

    return transcriptId;
  }

  /// Get transcript for a specific card
  Future<Transcript?> getTranscriptByCardId(String cardId) async {
    final query = db.select(db.transcripts)
      ..where((transcript) => transcript.cardId.equals(cardId));

    return await query.getSingleOrNull();
  }

  /// Update transcript text
  Future<void> updateTranscriptText(String transcriptId, String newText) async {
    await (db.update(
      db.transcripts,
    )..where((transcript) => transcript.id.equals(transcriptId))).write(
      TranscriptsCompanion(
        transcriptionText: drift.Value(newText),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  /// Delete transcript
  Future<void> deleteTranscript(String transcriptId) async {
    await (db.delete(
      db.transcripts,
    )..where((transcript) => transcript.id.equals(transcriptId))).go();
  }

  /// Get all transcripts for a user (via their cards)
  Future<List<Transcript>> getTranscriptsForUser(String userId) async {
    final query = db.select(db.transcripts).join([
      drift.innerJoin(db.cards, db.cards.id.equalsExp(db.transcripts.cardId)),
    ])..where(db.cards.userId.equals(userId));

    final results = await query.get();
    return results.map((row) => row.readTable(db.transcripts)).toList();
  }
}
