import 'package:flutter/material.dart';
import 'package:compressor/core/theme/app_colors.dart';
import 'package:compressor/l10n/app_localizations.dart';

/// Compression preset levels corresponding to Screen 3 in reference design.
enum CompressionPreset {
  light,
  balanced,
  strong;

  IconData get icon {
    switch (this) {
      case CompressionPreset.light:
        return Icons.eco_rounded; // Leaf icon
      case CompressionPreset.balanced:
        return Icons.star_rounded; // Star icon
      case CompressionPreset.strong:
        return Icons.bolt_rounded; // Lightning icon
    }
  }

  Color get accentColor {
    switch (this) {
      case CompressionPreset.light:
        return AppColors.success;
      case CompressionPreset.balanced:
        return AppColors.primary;
      case CompressionPreset.strong:
        return AppColors.error;
    }
  }

  String getTitle(AppLocalizations l10n) {
    switch (this) {
      case CompressionPreset.light:
        return l10n.levelLight;
      case CompressionPreset.balanced:
        return l10n.levelBalanced;
      case CompressionPreset.strong:
        return l10n.levelStrong;
    }
  }

  String getSubtitle(AppLocalizations l10n) {
    switch (this) {
      case CompressionPreset.light:
        return l10n.levelLightSub;
      case CompressionPreset.balanced:
        return l10n.levelBalancedSub;
      case CompressionPreset.strong:
        return l10n.levelStrongSub;
    }
  }

  /// Estimated reduction ratio for UI preview.
  double get estimatedReductionRatio {
    switch (this) {
      case CompressionPreset.light:
        return 0.30;
      case CompressionPreset.balanced:
        return 0.50;
      case CompressionPreset.strong:
        return 0.70;
    }
  }

  /// Target image JPEG compression quality.
  int get imageQuality {
    switch (this) {
      case CompressionPreset.light:
        return 82;
      case CompressionPreset.balanced:
        return 62;
      case CompressionPreset.strong:
        return 42;
    }
  }
}
