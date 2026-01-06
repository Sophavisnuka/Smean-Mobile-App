import 'package:flutter/material.dart';

/// Main recording button widget with record/stop states
class RecordingButtonWidget extends StatelessWidget {
  const RecordingButtonWidget({
    super.key,
    required this.isRecording,
    required this.onTap,
    this.radius = 58,
    this.pulseValue = 0,
  });

  final bool isRecording;
  final VoidCallback onTap;
  final double radius;
  final double pulseValue;

  @override
  Widget build(BuildContext context) {
    final activeGradient = const [Color(0xFF0DB2AC), Color(0xFF4FE2D2)];
    final idleGradient = const [Color(0xFFE8EDF8), Color(0xFFE6F4F2)];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        scale: isRecording ? 1.02 + (pulseValue * 0.04) : 1,
        curve: Curves.easeOut,
        child: Container(
          height: radius * 2,
          width: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isRecording ? activeGradient : idleGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: isRecording
                ? [
                    BoxShadow(
                      color: const Color(
                        0xFF0DB2AC,
                      ).withOpacity(0.40 + (0.18 * pulseValue)),
                      blurRadius: 26 + (12 * pulseValue),
                      spreadRadius: 4 + (6 * pulseValue),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: radius * (isRecording ? 1.18 : 1.1),
                width: radius * (isRecording ? 1.18 : 1.1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(isRecording ? 0.14 : 0.06),
                ),
              ),
              Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
                size: radius * 0.9,
                color: isRecording ? Colors.white : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
