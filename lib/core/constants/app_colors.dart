import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1194b4);
  static const Color secondary = Color(0xFF006e94);
  static const Color contrast = Colors.white;
  static const Color additional = Colors.black;

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
