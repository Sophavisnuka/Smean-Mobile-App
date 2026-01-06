import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smean_mobile_app/ui/widgets/recording/recording_timer_widget.dart';

/// Custom painter for the animated ring around the timer
class RingPainter extends CustomPainter {
  RingPainter({
    required this.progress,
    required this.isActive,
    required this.primary,
    required this.secondary,
  });

  final double progress;
  final bool isActive;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = SweepGradient(
        colors: isActive
            ? [primary, secondary, primary]
            : [secondary, secondary.withOpacity(0.55), secondary],
        startAngle: -math.pi / 2,
        endAngle: 1.5 * math.pi,
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);

    final backgroundPaint = Paint()
      ..color = secondary.withOpacity(isActive ? 0.18 : 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      basePaint,
    );
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}

/// Animated waveform bar visualization
class WaveformBar extends StatelessWidget {
  const WaveformBar({
    super.key,
    required this.animation,
    required this.isActive,
    required this.secondary,
  });

  final Animation<double> animation;
  final bool isActive;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    final baseColor = secondary;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: isActive ? 1 : 0.6,
      child: SizedBox(
        height: 36,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(18, (index) {
                final phase = animation.value * 2 * math.pi + index * 0.35;
                final height = 10 + (math.sin(phase).abs() * 20);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 6,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: baseColor,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

/// Complete timer section with ring animation, timer display, and waveform
class RecordTimerSection extends StatelessWidget {
  const RecordTimerSection({
    super.key,
    required this.duration,
    required this.isRecording,
    required this.pulseAnimation,
    required this.sweepAngle,
    required this.primary,
    required this.secondary,
  });

  final Duration duration;
  final bool isRecording;
  final Animation<double> pulseAnimation;
  final double sweepAngle;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 220,
          width: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow shadow
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: isRecording
                      ? [
                          BoxShadow(
                            color: primary.withOpacity(
                              0.25 + (0.12 * pulseAnimation.value),
                            ),
                            blurRadius: 32 + (10 * pulseAnimation.value),
                            spreadRadius: 4 + (4 * pulseAnimation.value),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: primary.withOpacity(0.22),
                            blurRadius: 26,
                            spreadRadius: 2,
                          ),
                        ],
                ),
              ),
              // Inner circle
              if (isRecording)
                Container(
                  height: 190,
                  width: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withOpacity(0.14),
                    border: Border.all(color: primary, width: 1.4),
                  ),
                )
              else
                Container(
                  height: 190,
                  width: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: secondary.withOpacity(0.10),
                    border: Border.all(
                      color: primary.withOpacity(0.85),
                      width: 1.4,
                    ),
                  ),
                ),
              // Animated ring
              CustomPaint(
                size: const Size.square(190),
                painter: RingPainter(
                  progress: pulseAnimation.value,
                  isActive: isRecording,
                  primary: primary,
                  secondary: secondary,
                ),
              ),
              // Border frames when recording
              if (isRecording) ...[
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        height: 214,
                        width: 214,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withOpacity(0.32),
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        height: 188,
                        width: 188,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withOpacity(0.26),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              // Rotating indicator dot
              if (isRecording)
                Positioned.fill(
                  child: Transform.rotate(
                    angle: sweepAngle,
                    child: Transform.translate(
                      offset: const Offset(0, -100),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary,
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.32),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Timer display
              RecordingTimerWidget(
                duration: duration,
                textStyle: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        WaveformBar(
          animation: pulseAnimation,
          isActive: isRecording,
          secondary: secondary,
        ),
      ],
    );
  }
}
