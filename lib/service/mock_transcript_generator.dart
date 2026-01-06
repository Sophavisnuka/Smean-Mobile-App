import 'dart:math';

class TranscriptSegment {
  final int startSeconds;
  final int endSeconds;
  final String text;

  const TranscriptSegment({
    required this.startSeconds,
    required this.endSeconds,
    required this.text,
  });

  TranscriptSegment copyWith({
    int? startSeconds,
    int? endSeconds,
    String? text,
  }) {
    return TranscriptSegment(
      startSeconds: startSeconds ?? this.startSeconds,
      endSeconds: endSeconds ?? this.endSeconds,
      text: text ?? this.text,
    );
  }
}

/// Deterministic helper for generating mock Khmer transcripts and summaries.
class MockTranscriptGenerator {
  static const int _baseDurationSeconds = 60;
  static const String _englishSummary =
      'This is a mock overview of the recording, highlighting the main talking points and the general mood of the conversation.';
  static const String _khmerSummary =
      'នេះជាសង្ខេបសាកល្បងសម្រាប់អត្ថបទបម្លែង ដើម្បីបង្ហាញរូបរាង UI និងលំហូរការប្រើប្រាស់។';

  // Reusable pool of Khmer sentences for transcript chunks.
  static const List<String> _khmerSentences = [
    'នេះគឺជាអត្ថបទសាកល្បងសម្រាប់ការស្តាប់និងការសរសេរ។',
    'យើងពិភាក្សាអំពីការអប់រំនិងការអភិវឌ្ឍជីវិតប្រចាំថ្ងៃ។',
    'សម្ភាសន៍នេះរំលឹកឱ្យយើងចំពោះតម្លៃនៃសហគមន៍។',
    'ការស្តាប់សំឡេងអាចជួយយើងយល់ដឹងពីអារម្មណ៍។',
    'អ្នកនិយាយបានលើកឡើងពីការសហការនិងការប្តេជ្ញា។',
    'ពេលវេលាបន្តិចនេះជួយអោយយើងឆ្លុះបញ្ចាំង។',
    'ពាក្យសំខាន់ៗស្តីពីសុវត្ថិភាព និងការសម្រេចចិត្ត។',
    'ការផ្លាស់ប្តូរតូចៗអាចបង្កើតផលប៉ះពាល់ធំ។',
    'ពេលសម្រាកខ្លីធ្វើអោយយើងមានថាមពលឡើងវិញ។',
    'សម្លេងផ្ទាល់ជួយបញ្ចប់ការបកស្រាយឱ្យច្បាស់។',
  ];

  static String summary({bool isKhmer = false}) {
    return isKhmer ? _khmerSummary : _englishSummary;
  }

  static List<TranscriptSegment> generateSegments({
    required int durationSeconds,
    int seed = 1337,
  }) {
    final safeDuration = durationSeconds <= 0 ? 1 : durationSeconds;
    final basePattern = _buildOneMinutePattern(seed: seed);

    if (safeDuration <= _baseDurationSeconds) {
      return _trimToDuration(basePattern, safeDuration);
    }

    return _extendPattern(basePattern, safeDuration);
  }

  static String flattenSegments(List<TranscriptSegment> segments) {
    return segments.map((s) => s.text).join(' ');
  }

  static List<TranscriptSegment> _buildOneMinutePattern({required int seed}) {
    final random = Random(seed);
    final segments = <TranscriptSegment>[];
    int start = 0;

    while (start < _baseDurationSeconds) {
      final remaining = _baseDurationSeconds - start;
      final maxLen = remaining < 12 ? remaining : 12;
      final minLen = remaining <= 5 ? remaining : 5;
      final length = remaining <= 5
          ? remaining
          : random.nextInt(maxLen - minLen + 1) + minLen;
      final end = start + length - 1;
      final text = _khmerSentences[segments.length % _khmerSentences.length];

      segments.add(
        TranscriptSegment(startSeconds: start, endSeconds: end, text: text),
      );

      start = end + 1;
    }

    return segments;
  }

  static List<TranscriptSegment> _extendPattern(
    List<TranscriptSegment> basePattern,
    int durationSeconds,
  ) {
    final extended = <TranscriptSegment>[];
    int offset = 0;

    while (offset + _baseDurationSeconds <= durationSeconds) {
      extended.addAll(_shiftSegments(basePattern, offset));
      offset += _baseDurationSeconds;
    }

    final remaining = durationSeconds - offset;
    if (remaining > 0) {
      final shifted = _shiftSegments(basePattern, offset);
      extended.addAll(_trimToDuration(shifted, remaining));
    }

    return extended;
  }

  static List<TranscriptSegment> _trimToDuration(
    List<TranscriptSegment> segments,
    int targetDurationSeconds,
  ) {
    if (segments.isEmpty || targetDurationSeconds <= 0) return const [];

    final trimmed = <TranscriptSegment>[];
    final cutoff = segments.first.startSeconds + targetDurationSeconds - 1;

    for (final segment in segments) {
      if (segment.startSeconds > cutoff) break;
      final end = segment.endSeconds > cutoff ? cutoff : segment.endSeconds;
      trimmed.add(segment.copyWith(endSeconds: end));
      if (end == cutoff) break;
    }

    return trimmed;
  }

  static List<TranscriptSegment> _shiftSegments(
    List<TranscriptSegment> base,
    int offset,
  ) {
    return base
        .map(
          (segment) => TranscriptSegment(
            startSeconds: segment.startSeconds + offset,
            endSeconds: segment.endSeconds + offset,
            text: segment.text,
          ),
        )
        .toList(growable: false);
  }
}
