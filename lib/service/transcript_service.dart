import 'package:uuid/uuid.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/data/repository/transcript_repository.dart';
import 'package:smean_mobile_app/service/mock_transcript_generator.dart';

const uuid = Uuid();

class TranscriptService {
  final TranscriptRepository _repo;

  TranscriptService(AppDatabase db) : _repo = TranscriptRepository(db);

  /// Generate mock transcription for a card
  /// In Phase 2, this will be replaced with real API call
  Future<String> generateMockTranscription({
    required String cardId,
    required String cardName,
    required int durationSeconds,
    int? seed,
  }) async {
    // Simulate processing delay (1-3 seconds)
    await Future.delayed(Duration(seconds: 2));

    final segments = MockTranscriptGenerator.generateSegments(
      durationSeconds: durationSeconds,
      seed: seed ?? (cardId.hashCode ^ cardName.hashCode),
    );
    final text = MockTranscriptGenerator.flattenSegments(segments);
    final transcriptId = uuid.v4();

    await _repo.createTranscript(
      transcriptId: transcriptId,
      cardId: cardId,
      text: text,
    );

    return transcriptId;
  }

  /// Update transcript text (for editing)
  Future<void> updateTranscription(String transcriptId, String newText) async {
    await _repo.updateTranscriptText(transcriptId, newText);
  }

  /// Get transcript for a card
  Future<Transcript?> getTranscriptForCard(String cardId) async {
    return await _repo.getTranscriptByCardId(cardId);
  }
}
