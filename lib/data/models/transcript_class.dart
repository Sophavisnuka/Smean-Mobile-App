class TranscriptClass {
  final String transcriptId;
  final String text;
  final String audioId;

  TranscriptClass({
    required this.transcriptId,
    required this.text,
    required this.audioId,
  });

  Map<String, dynamic> toJson() {
    return {'transcriptId': transcriptId, 'text': text, 'audioId': audioId};
  }

  factory TranscriptClass.fromJson(Map<String, dynamic> json) => TranscriptClass(
    transcriptId: json['transcriptId'] as String,
    audioId: json['audioId'] as String,
    text: json['text'] as String,
  );
}
