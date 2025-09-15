import 'package:flutter/material.dart';

/// App Color Constants
class AppColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF0066CC);
  static const Color primaryOrange = Color(0xFFFFAD03);
  static const Color primaryCoral = Color(0xFFFD9148);
  static const Color primaryWhite = Color(0xFFFFFFFF);

  // Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryOrange, primaryCoral, primaryWhite],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // Alternative gradient variations
  static const LinearGradient blueToOrangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryOrange],
  );

  static const LinearGradient orangeToCoralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, primaryCoral],
  );

  static const LinearGradient coralToWhiteGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryCoral, primaryWhite],
  );

  // Radial gradient variation
  static const RadialGradient primaryRadialGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [primaryBlue, primaryOrange, primaryCoral, primaryWhite],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
}
