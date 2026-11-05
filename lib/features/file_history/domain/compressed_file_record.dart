import 'package:compressor/core/utils/file_size_formatter.dart';

/// Immutable model representing a compressed file entry in local history.
class CompressedFileRecord {
  final String id;
  final String fileName;
  final String filePath;
  final int originalSizeBytes;
  final int compressedSizeBytes;
  final String fileType; // 'pdf', 'image', 'video', 'document'
  final DateTime createdAt;
  final int? pageCount;

  const CompressedFileRecord({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.fileType,
    required this.createdAt,
    this.pageCount,
  });

  /// Percentage saved through compression.
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

  CompressedFileRecord copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? originalSizeBytes,
    int? compressedSizeBytes,
    String? fileType,
    DateTime? createdAt,
    int? pageCount,
  }) {
    return CompressedFileRecord(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      originalSizeBytes: originalSizeBytes ?? this.originalSizeBytes,
      compressedSizeBytes: compressedSizeBytes ?? this.compressedSizeBytes,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
      pageCount: pageCount ?? this.pageCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'originalSizeBytes': originalSizeBytes,
      'compressedSizeBytes': compressedSizeBytes,
      'fileType': fileType,
      'createdAt': createdAt.toIso8601String(),
      'pageCount': pageCount,
    };
  }

  factory CompressedFileRecord.fromJson(Map<String, dynamic> json) {
    return CompressedFileRecord(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      originalSizeBytes: json['originalSizeBytes'] as int? ?? 0,
      compressedSizeBytes: json['compressedSizeBytes'] as int? ?? 0,
      fileType: json['fileType'] as String? ?? 'pdf',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      pageCount: json['pageCount'] as int?,
    );
  }
}
