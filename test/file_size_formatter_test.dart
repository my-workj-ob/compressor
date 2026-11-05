import 'package:flutter_test/flutter_test.dart';
import 'package:compressor/core/utils/file_size_formatter.dart';

void main() {
  group('FileSizeFormatter Tests', () {
    test('formatBytes handles zero and negative numbers', () {
      expect(FileSizeFormatter.formatBytes(0), '0 B');
      expect(FileSizeFormatter.formatBytes(-50), '0 B');
    });

    test('formatBytes formats bytes correctly across units', () {
      expect(FileSizeFormatter.formatBytes(500), '500 B');
      expect(FileSizeFormatter.formatBytes(1024), '1.0 KB');
      expect(FileSizeFormatter.formatBytes(1536), '1.5 KB');
      expect(FileSizeFormatter.formatBytes(1024 * 1024), '1.0 MB');
      expect(FileSizeFormatter.formatBytes(12400000), '11.8 MB');
    });

    test('calculateReductionPercentage calculates truthful percentage', () {
      // 12.4 MB down to 3.1 MB is ~75% reduction
      expect(
        FileSizeFormatter.calculateReductionPercentage(12400000, 3100000),
        75,
      );

      // No reduction or larger size returns 0
      expect(
        FileSizeFormatter.calculateReductionPercentage(1000, 1000),
        0,
      );
      expect(
        FileSizeFormatter.calculateReductionPercentage(1000, 1500),
        0,
      );

      // Edge cases
      expect(
        FileSizeFormatter.calculateReductionPercentage(0, 100),
        0,
      );
    });
  });
}
