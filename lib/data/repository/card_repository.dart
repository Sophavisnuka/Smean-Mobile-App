import 'package:drift/drift.dart' as drift;
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/data/models/card_model.dart';
import 'package:smean_mobile_app/data/models/audio_class.dart';
import 'package:smean_mobile_app/data/models/transcript_class.dart';

/// Repository for managing CardModel entities
class CardRepository {
  final AppDatabase db;

  CardRepository(this.db);

  /// Get all cards for a specific user
  Future<List<CardModel>> getCardsForUser(String userId) async {
    final query = db.select(db.cards)
      ..where((card) => card.userId.equals(userId))
      ..orderBy([(card) => drift.OrderingTerm.desc(card.createdAt)]);

    final cards = await query.get();

    final cardModels = <CardModel>[];
    for (final card in cards) {
      final cardModel = await _buildCardModel(card);
      if (cardModel != null) cardModels.add(cardModel);
    }

    return cardModels;
  }

  /// Get a single card by ID
  Future<CardModel?> getCardById(String cardId) async {
    final query = db.select(db.cards)..where((card) => card.id.equals(cardId));
    final card = await query.getSingleOrNull();

    if (card == null) return null;
    return await _buildCardModel(card);
  }

  /// Create a new card with audio
  Future<String> createCard({
    required String userId,
    required String cardName,
    required String audioFilePath,
    required String sourceType,
    required int audioDuration,
    required String cardId,
    required String audioId,
    bool isFavorite = false,
    DateTime? createdAt,
  }) async {
    final now = createdAt ?? DateTime.now();

    // Insert card
    await db
        .into(db.cards)
        .insert(
          CardsCompanion(
            id: drift.Value(cardId),
            userId: drift.Value(userId),
            cardName: drift.Value(cardName),
            isFavorite: drift.Value(isFavorite),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ),
        );

    // Insert audio
    await db
        .into(db.audios)
        .insert(
          AudiosCompanion(
            id: drift.Value(audioId),
            cardId: drift.Value(cardId),
            filePath: drift.Value(audioFilePath),
            sourceType: drift.Value(sourceType),
            duration: drift.Value(audioDuration),
            createdAt: drift.Value(now),
          ),
        );

    return cardId;
  }

  /// Update card name
  Future<void> updateCardName(String cardId, String newName) async {
    await (db.update(db.cards)..where((card) => card.id.equals(cardId))).write(
      CardsCompanion(
        cardName: drift.Value(newName),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String cardId, bool isFavorite) async {
    await (db.update(db.cards)..where((card) => card.id.equals(cardId))).write(
      CardsCompanion(
        isFavorite: drift.Value(isFavorite),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  /// Delete a card (cascade deletes audio and transcript)
  Future<void> deleteCard(String cardId) async {
    await (db.delete(db.cards)..where((card) => card.id.equals(cardId))).go();
  }

  /// Search cards by name for a user
  Future<List<CardModel>> searchCards(String userId, String query) async {
    final searchQuery = db.select(db.cards)
      ..where(
        (card) => card.userId.equals(userId) & card.cardName.like('%$query%'),
      )
      ..orderBy([(card) => drift.OrderingTerm.desc(card.createdAt)]);

    final cards = await searchQuery.get();

    final cardModels = <CardModel>[];
    for (final card in cards) {
      final cardModel = await _buildCardModel(card);
      if (cardModel != null) cardModels.add(cardModel);
    }

    return cardModels;
  }

  /// Get favorite cards for a user
  Future<List<CardModel>> getFavoriteCards(String userId) async {
    final query = db.select(db.cards)
      ..where(
        (card) => card.userId.equals(userId) & card.isFavorite.equals(true),
      )
      ..orderBy([(card) => drift.OrderingTerm.desc(card.createdAt)]);

    final cards = await query.get();

    final cardModels = <CardModel>[];
    for (final card in cards) {
      final cardModel = await _buildCardModel(card);
      if (cardModel != null) cardModels.add(cardModel);
    }

    return cardModels;
  }

  // ==================== PRIVATE HELPERS ====================

  /// Build a CardModel from database Card data
  Future<CardModel?> _buildCardModel(Card card) async {
    final audioData = await _getAudioForCard(card.id);
    final transcriptData = await _getTranscriptForCard(card.id);

    final audio = audioData != null
        ? AudioRecord(
            audioId: audioData.id,
            filePath: audioData.filePath,
            audioTitle: card.cardName,
            createdAt: audioData.createdAt,
            duration: audioData.duration,
            isFavorite: card.isFavorite,
            sourceType: audioData.sourceType,
          )
        : null;

    final transcript = transcriptData != null
        ? TranscriptClass(
            transcriptId: transcriptData.id,
            text: transcriptData.transcriptionText,
            audioId: audioData?.id ?? '',
          )
        : null;

    return CardModel(
      cardId: card.id,
      userId: card.userId,
      cardName: card.cardName,
      isFavorite: card.isFavorite,
      createdAt: card.createdAt,
      updatedAt: card.updatedAt,
      audio: audio,
      transcript: transcript,
    );
  }

  Future<Audio?> _getAudioForCard(String cardId) async {
    final query = db.select(db.audios)
      ..where((audio) => audio.cardId.equals(cardId));
    return await query.getSingleOrNull();
  }

  Future<Transcript?> _getTranscriptForCard(String cardId) async {
    final query = db.select(db.transcripts)
      ..where((transcript) => transcript.cardId.equals(cardId))
      ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])
      ..limit(1);
    final results = await query.get();
    return results.isEmpty ? null : results.first;
  }
}
