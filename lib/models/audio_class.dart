class AudioRecord {

  final String audioId;
  final String filePath;
  final String audioTitle;
  final String duration;
  final String format;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AudioRecord ({
    required this.audioId,
    required this.filePath,
    required this.audioTitle,
    required this.duration,
    required this.format,
    required this.createdAt,
    required this.updatedAt,
  });
}