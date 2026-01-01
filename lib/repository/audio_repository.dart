import 'package:drift/drift.dart' as drift;
import 'package:smean_mobile_app/database/database.dart';
import 'package:smean_mobile_app/models/card_model.dart';

/// Repository for managing Cards with Audio (recorded or uploaded)
class AudioRepository {
  final AppDatabase db;

  AudioRepository(this.db);

  /// Get all cards for a specific user (with audio and transcript info)
  Future<List<CardModel>> getCardsForUser(String userId) async {
    final query = db.select(db.cards)
      ..where((card) => card.userId.equals(userId))
      ..orderBy([(card) => drift.OrderingTerm.desc(card.createdAt)]);

    final cards = await query.get();

    // Load audio and transcript for each card
    final cardModels = <CardModel>[];
    for (final card in cards) {
      final audio = await _getAudioForCard(card.id);
      final transcript = await _getTranscriptForCard(card.id);

      cardModels.add(
        CardModel(
          cardId: card.id,
          userId: card.userId,
          cardName: card.cardName,
          isFavorite: card.isFavorite,
          createdAt: card.createdAt,
          updatedAt: card.updatedAt,
          audioId: audio?.id,
          audioFilePath: audio?.filePath,
          audioSourceType: audio?.sourceType,
          audioDuration: audio?.duration,
          transcriptId: transcript?.id,
          transcriptionText: transcript?.transcriptionText,
        ),
      );
    }

    return cardModels;
  }

  /// Get a single card by ID
  Future<CardModel?> getCardById(String cardId) async {
    final query = db.select(db.cards)..where((card) => card.id.equals(cardId));

    final card = await query.getSingleOrNull();
    if (card == null) return null;

    final audio = await _getAudioForCard(cardId);
    final transcript = await _getTranscriptForCard(cardId);

    return CardModel(
      cardId: card.id,
      userId: card.userId,
      cardName: card.cardName,
      isFavorite: card.isFavorite,
      createdAt: card.createdAt,
      updatedAt: card.updatedAt,
      audioId: audio?.id,
      audioFilePath: audio?.filePath,
      audioSourceType: audio?.sourceType,
      audioDuration: audio?.duration,
      transcriptId: transcript?.id,
      transcriptionText: transcript?.transcriptionText,
    );
  }

  /// Create a new card with audio
  Future<String> createCardWithAudio({
    required String userId,
    required String cardName,
    required String audioFilePath,
    required String sourceType, // 'recorded' or 'uploaded'
    required int audioDuration,
    required String cardId,
    required String audioId,
  }) async {
    final now = DateTime.now();

    // Insert card
    await db
        .into(db.cards)
        .insert(
          CardsCompanion(
            id: drift.Value(cardId),
            userId: drift.Value(userId),
            cardName: drift.Value(cardName),
            isFavorite: const drift.Value(false),
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
      final audio = await _getAudioForCard(card.id);
      final transcript = await _getTranscriptForCard(card.id);

      cardModels.add(
        CardModel(
          cardId: card.id,
          userId: card.userId,
          cardName: card.cardName,
          isFavorite: card.isFavorite,
          createdAt: card.createdAt,
          updatedAt: card.updatedAt,
          audioId: audio?.id,
          audioFilePath: audio?.filePath,
          audioSourceType: audio?.sourceType,
          audioDuration: audio?.duration,
          transcriptId: transcript?.id,
          transcriptionText: transcript?.transcriptionText,
        ),
      );
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
      final audio = await _getAudioForCard(card.id);
      final transcript = await _getTranscriptForCard(card.id);

      cardModels.add(
        CardModel(
          cardId: card.id,
          userId: card.userId,
          cardName: card.cardName,
          isFavorite: card.isFavorite,
          createdAt: card.createdAt,
          updatedAt: card.updatedAt,
          audioId: audio?.id,
          audioFilePath: audio?.filePath,
          audioSourceType: audio?.sourceType,
          audioDuration: audio?.duration,
          transcriptId: transcript?.id,
          transcriptionText: transcript?.transcriptionText,
        ),
      );
    }

    return cardModels;
  }

  // ==================== PRIVATE HELPERS ====================

  Future<Audio?> _getAudioForCard(String cardId) async {
    final query = db.select(db.audios)
      ..where((audio) => audio.cardId.equals(cardId));
    return await query.getSingleOrNull();
  }

  Future<Transcript?> _getTranscriptForCard(String cardId) async {
    final query = db.select(db.transcripts)
      ..where((transcript) => transcript.cardId.equals(cardId));
    return await query.getSingleOrNull();
  }
}
