import 'package:flutter/material.dart';
import 'package:smean_mobile_app/core/utils/formatting.dart';
import 'package:smean_mobile_app/service/mock_transcript_generator.dart';

/// A widget that displays a timestamped transcript list (read-only).
class TranscriptSection extends StatelessWidget {
  const TranscriptSection({
    super.key,
    required this.isKhmer,
    required this.segments,
    this.onSegmentTap,
    this.showMockBadge = false,
  });

  final bool isKhmer;
  final List<TranscriptSegment> segments;
  final ValueChanged<TranscriptSegment>? onSegmentTap;
  final bool showMockBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 280),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                isKhmer ? 'អត្ថបទបម្លែងពេញលេញ' : 'Full Transcription',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (showMockBadge) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: const Text('Mock', style: TextStyle(fontSize: 12)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: segments.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final segment = segments[index];
                final start = formatDuration(
                  Duration(seconds: segment.startSeconds),
                );
                final end = formatDuration(
                  Duration(seconds: segment.endSeconds),
                );

                return InkWell(
                  onTap: onSegmentTap == null
                      ? null
                      : () => onSegmentTap!(segment),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$start - $end',
                          style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          segment.text,
                          style: const TextStyle(height: 1.35),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
