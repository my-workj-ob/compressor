import 'dart:math' as math;

/// Utility for safely formatting byte sizes into human-readable strings.
abstract class FileSizeFormatter {
  static String formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (math.log(bytes) / math.log(1024)).floor();
    final clampedIndex = i.clamp(0, suffixes.length - 1);
    final size = bytes / math.pow(1024, clampedIndex);
    return '${size.toStringAsFixed(clampedIndex == 0 ? 0 : decimals)} ${suffixes[clampedIndex]}';
  }

  /// Calculates real percentage reduction safely avoiding division by zero or negative claims.
  static int calculateReductionPercentage(int originalBytes, int compressedBytes) {
    if (originalBytes <= 0) return 0;
    if (compressedBytes >= originalBytes) return 0;
    final diff = originalBytes - compressedBytes;
    final ratio = (diff / originalBytes) * 100;
    return ratio.clamp(0, 99).round();
  }
}
