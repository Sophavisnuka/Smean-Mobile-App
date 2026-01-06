import 'package:flutter/material.dart';

/// AppBar title for Record Screen
class RecordScreenHeaderTitle extends StatelessWidget {
  const RecordScreenHeaderTitle({super.key, required this.isKhmer});

  final bool isKhmer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Image.asset('assets/images/Smean-Logo.png', height: 40),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isKhmer ? 'កំណត់ត្រាសម្លេង' : 'Voice capture',
              style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              'SMEAN',
              style: textTheme.labelLarge?.copyWith(
                color: Colors.black54,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Card header with title and description
class RecordCardHeader extends StatelessWidget {
  const RecordCardHeader({super.key, required this.isKhmer});

  final bool isKhmer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isKhmer
              ? 'ថត ឈប់ ពិនិត្យ និងរក្សាទុក'
              : 'Record, preview, and save with ease',
          style: const TextStyle(
            fontFamily: 'GoogleSans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isKhmer
              ? 'ការរាប់ពេលវេលាច្បាស់លាស់ ដោយប៊ូតុងថតមានពន្លឺ'
              : 'Intentional controls, live timer, and a glowing record button.',
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
