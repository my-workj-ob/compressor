import 'package:compressor/core/utils/file_size_formatter.dart';

/// Result entity returned after executing a local compression job.
class CompressionResult {
  final bool isSuccess;
  final String originalPath;
  final String? compressedPath;
  final String fileName;
  final int originalSizeBytes;
  final int compressedSizeBytes;
  final String fileType;
  final int? pageCount;
  final Duration duration;
  final String? errorMessage;

  const CompressionResult({
    required this.isSuccess,
    required this.originalPath,
    this.compressedPath,
    required this.fileName,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.fileType,
    this.pageCount,
    required this.duration,
    this.errorMessage,
  });

  int get reductionPercentage {
    return FileSizeFormatter.calculateReductionPercentage(
      originalSizeBytes,
      compressedSizeBytes,
    );
  }

  String get formattedOriginalSize =>
      FileSizeFormatter.formatBytes(originalSizeBytes);

  String get formattedCompressedSize =>
      FileSizeFormatter.formatBytes(compressedSizeBytes);

  bool get hasReduction => compressedSizeBytes < originalSizeBytes;
}
