import 'package:uuid/uuid.dart';
import 'package:smean_mobile_app/models/transcript_class.dart';
import 'package:smean_mobile_app/repository/transcript_repository.dart';

const uuid = Uuid();

class TranscriptService {

  String _mockText(String? title) {
    final base = (title == null || title.trim().isEmpty)
      ? 'This is a mock transcript generated for demo purposes.'
      : 'This is a mock transcript for "$title".';

    return '$base\n\n'
      '• Key point 1: This transcription is not accurate yet.\n'
      '• Key point 2: It demonstrates how the UI will show text.\n'
      '• Key point 3: Later we can replace this with real speech-to-text.';
  }
  Future<Transcript?> generateMock(String audioId,String audioTitle) async {
    final mock = await TranscriptRepository.getTranscripts();
    
    final text = _mockText(audioTitle);

    final t = Transcript(
      transcriptId: uuid.v4(), 
      text: text, 
      audioId: audioId
    );

    mock.add(t);
    await TranscriptRepository.saveTranscripts(mock);
    return t;
  }
}