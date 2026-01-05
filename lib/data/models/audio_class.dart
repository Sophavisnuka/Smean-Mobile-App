class AudioRecord {
  final String audioId;
  final String filePath;
  final String audioTitle;
  final DateTime createdAt;
  final int duration;
  final bool isFavorite;
  final String sourceType;

  AudioRecord({
    required this.audioId,
    required this.filePath,
    required this.audioTitle,
    required this.createdAt,
    required this.duration,
    this.isFavorite = false,
    this.sourceType = 'recorded',
  });

  factory AudioRecord.fromJson(Map<String, dynamic> json) {
    return AudioRecord(
      audioId: json['audioId'] as String,
      filePath: json['filePath'] as String,
      audioTitle: json['audioTitle'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      duration: (json['duration'] ?? 0) as int,
      isFavorite: (json['isFavorite'] ?? false) as bool,
      sourceType: (json['sourceType'] ?? 'recorded') as String,
    );
  }
  Duration get getDuration => Duration(seconds: duration);

  Map<String, dynamic> toJson() {
    return {
      'audioId': audioId,
      'audioTitle': audioTitle,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration,
      'isFavorite': isFavorite,
      'sourceType': sourceType,
    };
  }
}
