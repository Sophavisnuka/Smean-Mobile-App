import 'package:smean_mobile_app/data/audio_repository.dart';
import 'package:smean_mobile_app/models/audio_class.dart';

class AudioService {
  Future<List<AudioRecord>> loadAudios() async {
    return await AudioRepository.getAudios();
  }
}
