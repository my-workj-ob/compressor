import 'package:flutter/material.dart';

/// Centralized color palette matching the modern, clean reference design.
abstract class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF2563EB); // Vibrant Royal Blue
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF); // Soft blue selection tint
  static const Color primaryBorder = Color(0xFFBFDBFE); // Soft blue card border

  // Neutrals & Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Clean off-white slate
  static const Color surface = Color(0xFFFFFFFF); // Pure white card
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Light gray container

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A); // Dark navy
  static const Color textSecondary = Color(0xFF64748B); // Slate gray
  static const Color textMuted = Color(0xFF94A3B8); // Light slate

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Subtle line
  static const Color borderLight = Color(0xFFF1F5F9);

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald green
  static const Color successLight = Color(0xFFECFDF5);
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color purple = Color(0xFF8B5CF6); // Purple accent
  static const Color purpleLight = Color(0xFFF5F3FF);

  // File Type Specific Accents
  static const Color pdfRed = Color(0xFFEF4444);
  static const Color pdfRedLight = Color(0xFFFEE2E2);
  static const Color imageBlue = Color(0xFF3B82F6);
  static const Color imageBlueLight = Color(0xFFDBEAFE);
  static const Color videoPurple = Color(0xFF8B5CF6);
  static const Color videoPurpleLight = Color(0xFFEDE9FE);
  static const Color fileGreen = Color(0xFF10B981);
  static const Color fileGreenLight = Color(0xFFD1FAE5);
}
