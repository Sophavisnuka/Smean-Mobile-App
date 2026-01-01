/// Represents a Card in the app - the main entity containing audio and transcription
class CardModel {
  final String cardId;
  final String userId;
  final String cardName;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Audio information (from audios table)
  final String? audioId;
  final String? audioFilePath;
  final String? audioSourceType; // 'recorded' or 'uploaded'
  final int? audioDuration; // seconds
  
  // Transcription information (from transcripts table)
  final String? transcriptId;
  final String? transcriptionText;

  CardModel({
    required this.cardId,
    required this.userId,
    required this.cardName,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.audioId,
    this.audioFilePath,
    this.audioSourceType,
    this.audioDuration,
    this.transcriptId,
    this.transcriptionText,
  });

  Duration? get audioDurationObj => 
      audioDuration != null ? Duration(seconds: audioDuration!) : null;

  bool get hasAudio => audioFilePath != null;
  bool get hasTranscript => transcriptionText != null && transcriptionText!.isNotEmpty;
  bool get isRecorded => audioSourceType == 'recorded';
  bool get isUploaded => audioSourceType == 'uploaded';

  /// Create a copy with updated fields
  CardModel copyWith({
    String? cardId,
    String? userId,
    String? cardName,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? audioId,
    String? audioFilePath,
    String? audioSourceType,
    int? audioDuration,
    String? transcriptId,
    String? transcriptionText,
  }) {
    return CardModel(
      cardId: cardId ?? this.cardId,
      userId: userId ?? this.userId,
      cardName: cardName ?? this.cardName,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      audioId: audioId ?? this.audioId,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      audioSourceType: audioSourceType ?? this.audioSourceType,
      audioDuration: audioDuration ?? this.audioDuration,
      transcriptId: transcriptId ?? this.transcriptId,
      transcriptionText: transcriptionText ?? this.transcriptionText,
    );
  }
}
