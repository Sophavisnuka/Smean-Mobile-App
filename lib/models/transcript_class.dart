class Transcript {
  final String transcriptId;
  final String text;
  final String audioId;

  Transcript({
    required this.transcriptId,
    required this.text,
    required this.audioId,
  });

  Map<String, dynamic> toJson() {
    return {'transcriptId': transcriptId, 'text': text, 'audioId': audioId};
  }

  factory Transcript.fromJson(Map<String, dynamic> json) => Transcript(
    transcriptId: json['transcriptId'] as String,
    audioId: json['audioId'] as String,
    text: json['text'] as String,
  );
}
