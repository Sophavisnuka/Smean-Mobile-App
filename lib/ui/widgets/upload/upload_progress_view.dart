import 'package:flutter/material.dart';

/// A widget that displays an upload progress view
class UploadProgressView extends StatelessWidget {
  const UploadProgressView({
    super.key,
    required this.isKhmer,
    required this.primary,
    required this.secondary,
    this.sheenAnimation,
    this.reduceMotion = false,
  });

  final bool isKhmer;
  final Color primary;
  final Color secondary;
  final Animation<double>? sheenAnimation;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final sheenValue = reduceMotion ? 0.0 : (sheenAnimation?.value ?? 0.0);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  secondary.withOpacity(0.24),
                  primary.withOpacity(0.14),
                ],
              ),
              border: Border.all(color: primary.withOpacity(0.55), width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.25),
                  blurRadius: 26,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
                backgroundColor: secondary.withOpacity(0.25),
              ),
            ),
          ),

          const SizedBox(height: 28),

          Text(
            isKhmer
                ? 'កំពុងដំណើរការឯកសាររបស់អ្នក...'
                : 'Processing your file...',
            style: const TextStyle(
              fontFamily: 'GoogleSans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            isKhmer
                ? 'សូមរង់ចាំបន្តិច អាចចំណាយពេលពីរបីវិនាទី'
                : 'Hang tight—this only takes a few seconds.',
            style: const TextStyle(
              fontFamily: 'GoogleSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 22),

          _ProgressBar(
            primary: primary,
            secondary: secondary,
            sheenValue: sheenValue,
            reduceMotion: reduceMotion,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.primary,
    required this.secondary,
    required this.sheenValue,
    required this.reduceMotion,
  });

  final Color primary;
  final Color secondary;
  final double sheenValue;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: secondary.withOpacity(0.18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              width: 260,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, secondary]),
              ),
            ),
            if (!reduceMotion)
              FractionalTranslation(
                translation: Offset((sheenValue * 2) - 0.5, 0),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.30),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
