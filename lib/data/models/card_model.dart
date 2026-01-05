import 'audio_class.dart';
import 'transcript_class.dart';

/// Represents a Card in the app - the main entity containing audio and transcription
class CardModel {
  final String cardId;
  final String userId;
  final String cardName;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Composition: Use existing models instead of duplicating attributes
  final AudioRecord? audio;
  final TranscriptClass? transcript;

  CardModel({
    required this.cardId,
    required this.userId,
    required this.cardName,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.audio,
    this.transcript,
  });

  // Convenience getters for backward compatibility
  String? get audioId => audio?.audioId;
  String? get audioFilePath => audio?.filePath;
  int? get audioDuration => audio?.duration;
  Duration? get audioDurationObj => audio?.getDuration;
  String? get audioSourceType => audio?.sourceType;

  String? get transcriptId => transcript?.transcriptId;
  String? get transcriptionText => transcript?.text;

  bool get hasAudio => audio != null;
  bool get hasTranscript => transcript != null && transcript!.text.isNotEmpty;

  /// Create a copy with updated fields
  CardModel copyWith({
    String? cardId,
    String? userId,
    String? cardName,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    AudioRecord? audio,
    TranscriptClass? transcript,
  }) {
    return CardModel(
      cardId: cardId ?? this.cardId,
      userId: userId ?? this.userId,
      cardName: cardName ?? this.cardName,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      audio: audio ?? this.audio,
      transcript: transcript ?? this.transcript,
    );
  }
}
