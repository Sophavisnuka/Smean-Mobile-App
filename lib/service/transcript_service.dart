import 'package:uuid/uuid.dart';
import 'package:smean_mobile_app/database/database.dart';
import 'package:smean_mobile_app/repository/transcript_repository.dart';

const uuid = Uuid();

class TranscriptService {
  final TranscriptRepository _repo;

  TranscriptService(AppDatabase db) : _repo = TranscriptRepository(db);

  String _mockText(String? title) {
    final base = (title == null || title.trim().isEmpty)
        ? 'This is a mock transcript generated for demo purposes.'
        : 'This is a mock transcript for "$title".';

    return '$base\n\n'
        '• Key point 1: This transcription is not accurate yet.\n'
        '• Key point 2: It demonstrates how the UI will show text.\n'
        '• Key point 3: Later we can replace this with real speech-to-text.';
  }

  /// Generate mock transcription for a card
  /// In Phase 2, this will be replaced with real API call
  Future<String> generateMockTranscription({
    required String cardId,
    required String cardName,
  }) async {
    // Simulate processing delay (1-3 seconds)
    await Future.delayed(Duration(seconds: 2));

    final text = _mockText(cardName);
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
