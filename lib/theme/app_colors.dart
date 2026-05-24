import 'package:flutter/material.dart';

class AppColors {
  // Light mode background gradient colors
  static const Color backgroundStart = Color(0xFFFDFBFB);
  static const Color backgroundEnd = Color(0xFFF3F8F9); // Light pastel mix

  // Main Card
  static const Color cardColor = Colors.white;

  // Accents
  static const Color primary = Color(0xFF64C3A5); // Teal / Greenish
  static const Color primaryDark = Color(0xFF4CA085);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B); // Dark Slate
  static const Color textSecondary = Color(0xFF64748B); // Lighter Slate
  
  // Inputs
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputBackground = Colors.white;

  // Gradient for buttons if needed
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF64C3A5), Color(0xFF64C3A5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // App Background Gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFF5F5), Color(0xFFF0FDF4), Color(0xFFEFF6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Helper Extension for color darkening used across dashboards
extension ColorDarken on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsv = HSVColor.fromColor(this);
    final newValue = (hsv.value - amount).clamp(0.0, 1.0);

    return hsv.withValue(newValue).toColor();
  }
}

// Shared State for Audio Player across different roles
class SharedAudioState {
  static final ValueNotifier<String> currentTitle = ValueNotifier<String>('No track playing');
  static final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
}
