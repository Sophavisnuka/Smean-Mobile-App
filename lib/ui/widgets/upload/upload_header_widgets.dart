import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppBar title for Upload Screen
class UploadScreenHeaderTitle extends StatelessWidget {
  const UploadScreenHeaderTitle({super.key, required this.isKhmer});

  final bool isKhmer;

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.manropeTextTheme(Theme.of(context).textTheme);
    return Row(
      children: [
        Image.asset('assets/images/Smean-Logo.png', height: 40),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isKhmer ? 'ផ្ទុកឡើង' : 'Upload',
              style: GoogleFonts.spaceGrotesk(
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
class UploadCardHeader extends StatelessWidget {
  const UploadCardHeader({super.key, required this.isKhmer});

  final bool isKhmer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isKhmer
              ? 'ផ្ទុក ឈប់ ពិនិត្យ និងរក្សាទុក'
              : 'Upload, preview, and save with ease',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isKhmer
              ? 'ផ្ទុកឡើងដោយមានការការពារ ពីលំហូររហ័សទៅការពិនិត្យ'
              : 'Glass card polish, intentional spacing, and soft teal glow.',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
            height: 1.4,
            letterSpacing: 0.1,
          ).merge(textTheme.bodyMedium),
        ),
      ],
    );
  }
}
