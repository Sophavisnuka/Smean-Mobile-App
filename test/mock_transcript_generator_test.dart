import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smean_mobile_app/service/mock_transcript_generator.dart';
import 'package:smean_mobile_app/ui/widgets/audio/transcript_section.dart';

void main() {
  test('generator covers short duration without gaps', () {
    final segments = MockTranscriptGenerator.generateSegments(
      durationSeconds: 4,
      seed: 7,
    );

    expect(segments.length, 1);
    expect(segments.first.startSeconds, 0);
    expect(segments.first.endSeconds, 3);
    expect(segments.first.text.isNotEmpty, isTrue);
  });

  test('generator extends pattern for long audio and stays deterministic', () {
    final durationSeconds = 130;
    final first = MockTranscriptGenerator.generateSegments(
      durationSeconds: durationSeconds,
      seed: 42,
    );
    final second = MockTranscriptGenerator.generateSegments(
      durationSeconds: durationSeconds,
      seed: 42,
    );

    expect(first.length, greaterThan(5));
    expect(first.last.endSeconds, durationSeconds - 1);
    for (var i = 1; i < first.length; i++) {
      expect(first[i].startSeconds, first[i - 1].endSeconds + 1);
    }

    for (var i = 0; i < first.length; i++) {
      expect(first[i].startSeconds, second[i].startSeconds);
      expect(first[i].endSeconds, second[i].endSeconds);
      expect(first[i].text, second[i].text);
    }
  });

  testWidgets('TranscriptSection is read-only and responds to taps', (
    tester,
  ) async {
    TranscriptSegment? tapped;
    final segments = MockTranscriptGenerator.generateSegments(
      durationSeconds: 14,
      seed: 11,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TranscriptSection(
            isKhmer: false,
            segments: segments,
            onSegmentTap: (segment) => tapped = segment,
            showMockBadge: true,
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('Mock'), findsOneWidget);

    await tester.tap(find.textContaining('00:00'));
    await tester.pumpAndSettle();

    expect(tapped, isNotNull);
    expect(tapped!.startSeconds, segments.first.startSeconds);
  });
}
