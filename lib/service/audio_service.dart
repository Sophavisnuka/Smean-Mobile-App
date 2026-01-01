import 'package:smean_mobile_app/repository/audio_repository.dart';
import 'package:smean_mobile_app/models/audio_class.dart';

class AudioService {
  Future<List<AudioRecord>> loadAudios() async {
    return await AudioRepository.getAudios();
  }
  Future<void> saveAudios(List<AudioRecord> audios) async {
    return await AudioRepository.saveAudios(audios);
  }
  Future<List<AudioRecord>> updateAudio(String newTitle, String audioId, List<AudioRecord> currentAudio) async {
    final updated = List.of(currentAudio);
    for (int i = 0; i < updated.length; i++) {
      if (updated[i].audioId == audioId) {
        final oldAudio = updated[i];
        updated[i] = AudioRecord(
          audioId: oldAudio.audioId, 
          filePath: oldAudio.filePath, 
          audioTitle: newTitle, 
          createdAt: oldAudio.createdAt
        );
        break;
      }
    }
    await saveAudios(updated);
    return updated;
  }

}
