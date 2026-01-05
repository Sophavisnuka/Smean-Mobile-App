import 'package:drift/drift.dart' as drift;
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/data/models/audio_class.dart';

/// Repository for managing Audio records
/// Note: Most card operations have been moved to CardRepository
class AudioRepository {
  final AppDatabase db;

  AudioRepository(this.db);

  /// Get audio record by audio ID
  Future<AudioRecord?> getAudioById(String audioId) async {
    final query = db.select(db.audios)
      ..where((audio) => audio.id.equals(audioId));
    
    final audioData = await query.getSingleOrNull();
    if (audioData == null) return null;

    // Get card name for audioTitle
    final card = await (db.select(db.cards)
          ..where((c) => c.id.equals(audioData.cardId)))
        .getSingleOrNull();

    return AudioRecord(
      audioId: audioData.id,
      filePath: audioData.filePath,
      audioTitle: card?.cardName ?? 'Untitled',
      createdAt: audioData.createdAt,
      duration: audioData.duration,
      isFavorite: card?.isFavorite ?? false,
    );
  }

  /// Get audio record for a specific card
  Future<AudioRecord?> getAudioForCard(String cardId) async {
    final query = db.select(db.audios)
      ..where((audio) => audio.cardId.equals(cardId));
    
    final audioData = await query.getSingleOrNull();
    if (audioData == null) return null;

    // Get card info
    final card = await (db.select(db.cards)
          ..where((c) => c.id.equals(cardId)))
        .getSingleOrNull();

    return AudioRecord(
      audioId: audioData.id,
      filePath: audioData.filePath,
      audioTitle: card?.cardName ?? 'Untitled',
      createdAt: audioData.createdAt,
      duration: audioData.duration,
      isFavorite: card?.isFavorite ?? false,
    );
  }

  /// Update audio file path
  Future<void> updateAudioFilePath(String audioId, String newPath) async {
    await (db.update(db.audios)..where((audio) => audio.id.equals(audioId)))
        .write(
      AudiosCompanion(
        filePath: drift.Value(newPath),
      ),
    );
  }

  /// Delete audio record
  Future<void> deleteAudio(String audioId) async {
    await (db.delete(db.audios)..where((audio) => audio.id.equals(audioId)))
        .go();
  }
}
