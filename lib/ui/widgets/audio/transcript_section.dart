import 'package:flutter/material.dart';

/// A widget that displays an editable transcript section
class TranscriptSection extends StatelessWidget {
  const TranscriptSection({
    super.key,
    required this.isKhmer,
    required this.controller,
    this.showMockBadge = false,
  });

  final bool isKhmer;
  final TextEditingController controller;
  final bool showMockBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 250),
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
            child: SingleChildScrollView(
              child: TextField(
                controller: controller,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
