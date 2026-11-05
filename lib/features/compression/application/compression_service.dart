import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:archive/archive.dart';

import 'package:compressor/features/compression/data/pdf_advanced_engine.dart';
import 'package:compressor/features/compression/domain/compression_preset.dart';
import 'package:compressor/features/compression/domain/compression_result.dart';
import 'package:compressor/features/compression/domain/processing_stage.dart';

/// Service executing genuine offline local compression for documents, images, and archives.
class CompressionService {
  bool _isCancelled = false;

  void cancel() {
    _isCancelled = true;
  }

  /// Automatically inspects file extension and routes to the optimal compressor.
  Future<CompressionResult> compressAuto({
    required File inputFile,
    required CompressionPreset preset,
    int? customTargetSizeBytes,
    bool optimizeForWeb = true,
    void Function(ProcessingStage stage, double progress)? onProgress,
  }) async {
    final ext = p.extension(inputFile.path).toLowerCase();
    if (ext == '.pdf') {
      return compressPdf(
        inputFile: inputFile,
        preset: preset,
        customTargetSizeBytes: customTargetSizeBytes,
        optimizeForWeb: optimizeForWeb,
        onProgress: onProgress,
      );
    } else if (['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
      return compressImage(
        inputFile: inputFile,
        preset: preset,
        onProgress: onProgress,
      );
    } else if (['.zip', '.docx', '.xlsx', '.pptx', '.apk'].contains(ext)) {
      return compressArchive(
        inputFile: inputFile,
        preset: preset,
        optimizeForWeb: optimizeForWeb,
        onProgress: onProgress,
      );
    } else {
      return compressGenericFile(
        inputFile: inputFile,
        preset: preset,
        onProgress: onProgress,
      );
    }
  }

  /// Compresses a PDF file completely offline using deep stream and image optimization.
  Future<CompressionResult> compressPdf({
    required File inputFile,
    required CompressionPreset preset,
    int? customTargetSizeBytes,
    required bool optimizeForWeb,
    void Function(ProcessingStage stage, double progress)? onProgress,
  }) async {
    _isCancelled = false;
    final stopwatch = Stopwatch()..start();

    try {
      final fileName = p.basename(inputFile.path);
      final originalSizeBytes = await inputFile.length();

      // Stage 1: Preparing file
      onProgress?.call(ProcessingStage.preparing, 0.15);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (_isCancelled) throw Exception('Operation cancelled by user');

      // Stage 2: Analyzing content & embedded streams
      onProgress?.call(ProcessingStage.analyzing, 0.35);
      final inputBytes = await inputFile.readAsBytes();
      if (_isCancelled) throw Exception('Operation cancelled by user');

      // Stage 3: Deep compression & image recompression
      onProgress?.call(ProcessingStage.compressing, 0.40);
      final optResult = await PdfAdvancedEngine.optimize(
        PdfAdvancedParams(
          inputBytes: inputBytes,
          preset: preset,
          customTargetSizeBytes: customTargetSizeBytes,
          optimizeForWeb: optimizeForWeb,
        ),
        onProgress: (pageProgress) {
          if (_isCancelled) return;
          // Smoothly interpolate progress between 0.40 and 0.85
          final current = 0.40 + 0.45 * pageProgress;
          onProgress?.call(ProcessingStage.compressing, current);
        },
      );
      if (_isCancelled) throw Exception('Operation cancelled by user');

      // Stage 4: Optimizing structure & streams
      onProgress?.call(ProcessingStage.optimizing, 0.88);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (_isCancelled) throw Exception('Operation cancelled by user');

      final bytesToSave = optResult.outputBytes;

      // Stage 5: Finalizing file
      onProgress?.call(ProcessingStage.finalizing, 1.0);
      final outputDir = await _getOutputDirectory();
      final baseNameWithoutExt = p.basenameWithoutExtension(fileName);
      final outputPath = p.join(
        outputDir.path,
        '${baseNameWithoutExt}_compressed.pdf',
      );

      var outputFile = File(outputPath);
      int counter = 1;
      while (await outputFile.exists()) {
        outputFile = File(
          p.join(outputDir.path, '${baseNameWithoutExt}_compressed_$counter.pdf'),
        );
        counter++;
      }

      await outputFile.writeAsBytes(bytesToSave);
      final compressedSizeBytes = await outputFile.length();
      stopwatch.stop();

      return CompressionResult(
        isSuccess: true,
        originalPath: inputFile.path,
        compressedPath: outputFile.path,
        fileName: p.basename(outputFile.path),
        originalSizeBytes: originalSizeBytes,
        compressedSizeBytes: compressedSizeBytes,
        fileType: 'pdf',
        pageCount: optResult.pageCount,
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return CompressionResult(
        isSuccess: false,
        originalPath: inputFile.path,
        fileName: p.basename(inputFile.path),
        originalSizeBytes: await inputFile.exists() ? await inputFile.length() : 0,
        compressedSizeBytes: 0,
        fileType: 'pdf',
        duration: stopwatch.elapsed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Compresses an image file completely offline using the image package.
  Future<CompressionResult> compressImage({
    required File inputFile,
    required CompressionPreset preset,
    void Function(ProcessingStage stage, double progress)? onProgress,
  }) async {
    _isCancelled = false;
    final stopwatch = Stopwatch()..start();

    try {
      final fileName = p.basename(inputFile.path);
      final originalSizeBytes = await inputFile.length();

      // Stage 1: Preparing
      onProgress?.call(ProcessingStage.preparing, 0.15);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (_isCancelled) throw Exception('Operation cancelled');

      // Stage 2: Analyzing
      onProgress?.call(ProcessingStage.analyzing, 0.35);
      final rawBytes = await inputFile.readAsBytes();
      if (_isCancelled) throw Exception('Operation cancelled');

      final decoded = await compute(img.decodeImage, rawBytes);
      if (decoded == null) throw Exception('Unsupported image format');

      // Stage 3: Compressing & Smart Resizing
      onProgress?.call(ProcessingStage.compressing, 0.65);
      img.Image processedImage = decoded;

      final maxDim = decoded.width > decoded.height ? decoded.width : decoded.height;
      int? targetWidth;
      int? targetHeight;

      if (preset == CompressionPreset.strong && maxDim > 1280) {
        final scale = 1280.0 / maxDim;
        targetWidth = (decoded.width * scale).round();
        targetHeight = (decoded.height * scale).round();
      } else if (preset == CompressionPreset.balanced && maxDim > 1920) {
        final scale = 1920.0 / maxDim;
        targetWidth = (decoded.width * scale).round();
        targetHeight = (decoded.height * scale).round();
      } else if (preset == CompressionPreset.light && maxDim > 2560) {
        final scale = 2560.0 / maxDim;
        targetWidth = (decoded.width * scale).round();
        targetHeight = (decoded.height * scale).round();
      }

      if (targetWidth != null && targetHeight != null) {
        processedImage = img.copyResize(
          decoded,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      // Stage 4: Optimizing
      onProgress?.call(ProcessingStage.optimizing, 0.85);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (_isCancelled) throw Exception('Operation cancelled');

      final compressedBytes = await compute(
        _encodeJpgPayload,
        _JpgEncodeParams(processedImage, preset.imageQuality),
      );

      // Stage 5: Finalizing
      onProgress?.call(ProcessingStage.finalizing, 1.0);
      final outputDir = await _getOutputDirectory();
      final baseNameWithoutExt = p.basenameWithoutExtension(fileName);
      final outputPath = p.join(
        outputDir.path,
        '${baseNameWithoutExt}_compressed.jpg',
      );

      var outputFile = File(outputPath);
      int counter = 1;
      while (await outputFile.exists()) {
        outputFile = File(
          p.join(outputDir.path, '${baseNameWithoutExt}_compressed_$counter.jpg'),
        );
        counter++;
      }

      await outputFile.writeAsBytes(compressedBytes);
      final compressedSizeBytes = await outputFile.length();
      stopwatch.stop();

      return CompressionResult(
        isSuccess: true,
        originalPath: inputFile.path,
        compressedPath: outputFile.path,
        fileName: p.basename(outputFile.path),
        originalSizeBytes: originalSizeBytes,
        compressedSizeBytes: compressedSizeBytes,
        fileType: 'image',
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return CompressionResult(
        isSuccess: false,
        originalPath: inputFile.path,
        fileName: p.basename(inputFile.path),
        originalSizeBytes: await inputFile.exists() ? await inputFile.length() : 0,
        compressedSizeBytes: 0,
        fileType: 'image',
        duration: stopwatch.elapsed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<Uint8List> _compressEntryBytes({
    required String name,
    required Uint8List rawBytes,
    required CompressionPreset preset,
    bool optimizeForWeb = true,
  }) async {
    final ext = p.extension(name).toLowerCase();

    if (ext == '.pdf') {
      try {
        final optResult = await PdfAdvancedEngine.optimize(
          PdfAdvancedParams(
            inputBytes: rawBytes,
            preset: preset,
            optimizeForWeb: optimizeForWeb,
          ),
        );
        return optResult.outputBytes.length < rawBytes.length
            ? optResult.outputBytes
            : rawBytes;
      } catch (_) {
        return rawBytes;
      }
    } else if (['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
      try {
        int targetQuality;
        int maxDim;
        switch (preset) {
          case CompressionPreset.strong:
            targetQuality = 35;
            maxDim = 1080;
            break;
          case CompressionPreset.balanced:
            targetQuality = 50;
            maxDim = 1440;
            break;
          case CompressionPreset.light:
            targetQuality = 70;
            maxDim = 1920;
            break;
        }

        final decoded = img.decodeImage(rawBytes);
        if (decoded != null) {
          img.Image target = decoded;
          final maxSide = max(decoded.width, decoded.height);
          if (maxSide > maxDim) {
            final scale = maxDim / maxSide;
            target = img.copyResize(
              decoded,
              width: (decoded.width * scale).round(),
              height: (decoded.height * scale).round(),
              interpolation: img.Interpolation.linear,
            );
          }
          final encoded = img.encodeJpg(target, quality: targetQuality);
          return encoded.length < rawBytes.length
              ? Uint8List.fromList(encoded)
              : rawBytes;
        }
      } catch (_) {
        return rawBytes;
      }
    }
    return rawBytes;
  }

  /// Compresses ZIP and office archive formats (.zip, .docx, .xlsx, .pptx) offline
  /// using deep content-aware transcompression for embedded images and documents.
  Future<CompressionResult> compressArchive({
    required File inputFile,
    required CompressionPreset preset,
    bool optimizeForWeb = true,
    void Function(ProcessingStage stage, double progress)? onProgress,
  }) async {
    _isCancelled = false;
    final stopwatch = Stopwatch()..start();

    try {
      final fileName = p.basename(inputFile.path);
      final ext = p.extension(inputFile.path).toLowerCase();
      final originalSizeBytes = await inputFile.length();

      // Stage 1: Preparing
      onProgress?.call(ProcessingStage.preparing, 0.10);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (_isCancelled) throw Exception('Operation cancelled');

      // Stage 2: Analyzing
      onProgress?.call(ProcessingStage.analyzing, 0.25);
      final rawBytes = await inputFile.readAsBytes();
      if (_isCancelled) throw Exception('Operation cancelled');

      // Stage 3: Compressing in background
      onProgress?.call(ProcessingStage.compressing, 0.40);

      Archive inArchive;
      try {
        inArchive = ZipDecoder().decodeBytes(rawBytes);
      } catch (_) {
        inArchive = Archive();
      }

      Uint8List compressedBytes;
      if (inArchive.isEmpty) {
        compressedBytes = await compute(_compressGenericPayload, rawBytes);
      } else {
        final outArchive = Archive();
        final totalFiles = inArchive.files.length;

        for (int i = 0; i < totalFiles; i++) {
          if (_isCancelled) throw Exception('Operation cancelled');

          final file = inArchive.files[i];
          if (file.isFile) {
            final contentBytes = file.content;

            final entryCompressed = await _compressEntryBytes(
              name: file.name,
              rawBytes: contentBytes,
              preset: preset,
              optimizeForWeb: optimizeForWeb,
            );

            outArchive.addFile(
              ArchiveFile(file.name, entryCompressed.length, entryCompressed),
            );
          } else {
            outArchive.addFile(file);
          }

          final progress = 0.40 + 0.45 * ((i + 1) / totalFiles);
          onProgress?.call(ProcessingStage.compressing, progress);
        }

        if (_isCancelled) throw Exception('Operation cancelled');

        // Stage 4: Optimizing & creating ZIP
        onProgress?.call(ProcessingStage.optimizing, 0.90);
        compressedBytes = await compute(_encodeZipArchivePayload, outArchive);
      }

      if (_isCancelled) throw Exception('Operation cancelled');

      // Keep smaller
      final bytesToSave = compressedBytes.length < originalSizeBytes
          ? compressedBytes
          : rawBytes;

      // Stage 5: Finalizing
      onProgress?.call(ProcessingStage.finalizing, 1.0);
      final outputDir = await _getOutputDirectory();
      final baseNameWithoutExt = p.basenameWithoutExtension(fileName);
      final outputPath = p.join(
        outputDir.path,
        '${baseNameWithoutExt}_compressed$ext',
      );

      var outputFile = File(outputPath);
      int counter = 1;
      while (await outputFile.exists()) {
        outputFile = File(
          p.join(outputDir.path, '${baseNameWithoutExt}_compressed_$counter$ext'),
        );
        counter++;
      }

      await outputFile.writeAsBytes(bytesToSave);
      final compressedSizeBytes = await outputFile.length();
      stopwatch.stop();

      return CompressionResult(
        isSuccess: true,
        originalPath: inputFile.path,
        compressedPath: outputFile.path,
        fileName: p.basename(outputFile.path),
        originalSizeBytes: originalSizeBytes,
        compressedSizeBytes: compressedSizeBytes,
        fileType: 'zip',
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return CompressionResult(
        isSuccess: false,
        originalPath: inputFile.path,
        fileName: p.basename(inputFile.path),
        originalSizeBytes: await inputFile.exists() ? await inputFile.length() : 0,
        compressedSizeBytes: 0,
        fileType: 'zip',
        duration: stopwatch.elapsed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Compresses arbitrary generic files via high-efficiency Deflate/GZip.
  Future<CompressionResult> compressGenericFile({
    required File inputFile,
    required CompressionPreset preset,
    void Function(ProcessingStage stage, double progress)? onProgress,
  }) async {
    _isCancelled = false;
    final stopwatch = Stopwatch()..start();

    try {
      final fileName = p.basename(inputFile.path);
      final ext = p.extension(inputFile.path);
      final originalSizeBytes = await inputFile.length();

      onProgress?.call(ProcessingStage.preparing, 0.20);
      final rawBytes = await inputFile.readAsBytes();

      onProgress?.call(ProcessingStage.compressing, 0.60);
      final compressedBytes = await compute(_compressGenericPayload, rawBytes);

      onProgress?.call(ProcessingStage.finalizing, 1.0);
      final outputDir = await _getOutputDirectory();
      final baseNameWithoutExt = p.basenameWithoutExtension(fileName);
      final outputPath = p.join(
        outputDir.path,
        '${baseNameWithoutExt}_compressed$ext',
      );

      var outputFile = File(outputPath);
      int counter = 1;
      while (await outputFile.exists()) {
        outputFile = File(
          p.join(outputDir.path, '${baseNameWithoutExt}_compressed_$counter$ext'),
        );
        counter++;
      }

      final bytesToSave = compressedBytes.length < originalSizeBytes
          ? compressedBytes
          : rawBytes;

      await outputFile.writeAsBytes(bytesToSave);
      final compressedSizeBytes = await outputFile.length();
      stopwatch.stop();

      return CompressionResult(
        isSuccess: true,
        originalPath: inputFile.path,
        compressedPath: outputFile.path,
        fileName: p.basename(outputFile.path),
        originalSizeBytes: originalSizeBytes,
        compressedSizeBytes: compressedSizeBytes,
        fileType: 'files',
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return CompressionResult(
        isSuccess: false,
        originalPath: inputFile.path,
        fileName: p.basename(inputFile.path),
        originalSizeBytes: await inputFile.exists() ? await inputFile.length() : 0,
        compressedSizeBytes: 0,
        fileType: 'files',
        duration: stopwatch.elapsed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Compresses multiple files (PDFs, images, documents) or a single file into a high-compression .zip archive offline.
  Future<CompressionResult> compressToZip({
    required List<File> inputFiles,
    required CompressionPreset preset,
    bool optimizeForWeb = true,
    void Function(ProcessingStage stage, double progress)? onProgress,
  }) async {
    _isCancelled = false;
    final stopwatch = Stopwatch()..start();

    try {
      if (inputFiles.isEmpty) {
        throw Exception('No input files selected for ZIP compression');
      }

      // Stage 1: Preparing
      onProgress?.call(ProcessingStage.preparing, 0.10);
      int totalOriginalBytes = 0;
      for (final f in inputFiles) {
        if (await f.exists()) {
          totalOriginalBytes += await f.length();
        }
      }
      if (_isCancelled) throw Exception('Operation cancelled');

      // Stage 2: Analyzing
      onProgress?.call(ProcessingStage.analyzing, 0.20);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (_isCancelled) throw Exception('Operation cancelled');

      // Stage 3: Compressing individual files
      final archive = Archive();
      final totalCount = inputFiles.length;

      for (int i = 0; i < totalCount; i++) {
        if (_isCancelled) throw Exception('Operation cancelled');
        final file = inputFiles[i];
        if (!await file.exists()) continue;

        final name = p.basename(file.path);
        final rawBytes = await file.readAsBytes();

        final compressedBytes = await _compressEntryBytes(
          name: name,
          rawBytes: rawBytes,
          preset: preset,
          optimizeForWeb: optimizeForWeb,
        );

        archive.addFile(ArchiveFile(name, compressedBytes.length, compressedBytes));

        final progress = 0.20 + 0.65 * ((i + 1) / totalCount);
        onProgress?.call(ProcessingStage.compressing, progress);
      }

      if (_isCancelled) throw Exception('Operation cancelled');

      // Stage 4: Optimizing & creating ZIP
      onProgress?.call(ProcessingStage.optimizing, 0.90);
      final zipBytes = await compute(_encodeZipArchivePayload, archive);
      if (_isCancelled) throw Exception('Operation cancelled');

      // Stage 5: Finalizing
      onProgress?.call(ProcessingStage.finalizing, 1.0);
      final outputDir = await _getOutputDirectory();
      final firstNameWithoutExt = p.basenameWithoutExtension(inputFiles.first.path);
      final zipBaseName = inputFiles.length > 1
          ? '${firstNameWithoutExt}_bundle'
          : firstNameWithoutExt;
      final outputPath = p.join(outputDir.path, '${zipBaseName}_compressed.zip');

      var outputFile = File(outputPath);
      int counter = 1;
      while (await outputFile.exists()) {
        outputFile = File(
          p.join(outputDir.path, '${zipBaseName}_compressed_$counter.zip'),
        );
        counter++;
      }

      await outputFile.writeAsBytes(zipBytes);
      final compressedSizeBytes = await outputFile.length();
      stopwatch.stop();

      return CompressionResult(
        isSuccess: true,
        originalPath: inputFiles.first.path,
        compressedPath: outputFile.path,
        fileName: p.basename(outputFile.path),
        originalSizeBytes: totalOriginalBytes,
        compressedSizeBytes: compressedSizeBytes,
        fileType: 'zip',
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return CompressionResult(
        isSuccess: false,
        originalPath: inputFiles.isNotEmpty ? inputFiles.first.path : '',
        fileName: inputFiles.isNotEmpty ? p.basename(inputFiles.first.path) : '',
        originalSizeBytes: 0,
        compressedSizeBytes: 0,
        fileType: 'zip',
        duration: stopwatch.elapsed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<Directory> _getOutputDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final compressedDir = Directory(p.join(appDir.path, 'compressed_files'));
    if (!await compressedDir.exists()) {
      await compressedDir.create(recursive: true);
    }
    return compressedDir;
  }
}

Uint8List _encodeZipArchivePayload(Archive archive) {
  try {
    final encoded = ZipEncoder().encodeBytes(
      archive,
      level: DeflateLevel.bestCompression,
    );
    return encoded;
  } catch (_) {
    return Uint8List(0);
  }
}

class _JpgEncodeParams {
  final img.Image image;
  final int quality;

  const _JpgEncodeParams(this.image, this.quality);
}

Uint8List _encodeJpgPayload(_JpgEncodeParams params) {
  return Uint8List.fromList(
    img.encodeJpg(params.image, quality: params.quality),
  );
}


Uint8List _compressGenericPayload(Uint8List rawBytes) {
  try {
    final compressed = ZLibCodec(level: 9).encode(rawBytes);
    return Uint8List.fromList(compressed);
  } catch (_) {
    return rawBytes;
  }
}
