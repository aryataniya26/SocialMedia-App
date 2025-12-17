import 'package:flutter/material.dart';

class AppColors {
  // PRIMARY COLORS
  static const Color primary = Color(0xFF6C3FD6); // Deep Purple
  static const Color primaryLight = Color(0xFF8B5FE8);
  static const Color secondary = Color(0x66FFB6C1);

  // SPLASH SCREEN GRADIENT
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      // Color(0xFF550D9B), // Top - Deep Purple
      // Color(0xFF8B5FE8), // Middle - Medium Purple
      // Color(0xFFFFFFFF), // Bottom - Light Pink
      Color(0xFF550D9B), // Deep Purple (Top)
      Color(0xFF54519B), // Purple-Blue
      Color(0xFFB88DAA), // Soft Pink
      Color(0xFFC99986),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // UI COLORS
  static const Color primaryDark = Color(0xFF3D0A6E);

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF1F1F1F);

  // Text
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // UI Elements
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color cardBackground = Color(0xFFF3F4F6);
  static const Color searchBackground = Color(0xFFF3F4F6);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Button Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF550D9B), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
