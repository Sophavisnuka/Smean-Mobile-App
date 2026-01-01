class AudioCategory {
  final String audioCategoryId;
  final String audioId;
  final String categoryId;
  final DateTime createdAt;

  AudioCategory({
    required this.audioCategoryId,
    required this.audioId,
    required this.categoryId,
    required this.createdAt,
  });

  factory AudioCategory.fromJson(Map<String, dynamic> json) {
    return AudioCategory(
      audioCategoryId: json['audioCategoryId'] as String,
      audioId: json['audioId'] as String,
      categoryId: json['CategoryId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioCategoryId': audioCategoryId,
      'audioId': audioId,
      'CategoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
