import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:compressor/core/theme/app_colors.dart';
import 'package:compressor/core/utils/file_size_formatter.dart';
import 'package:compressor/features/compression/application/compression_service.dart';
import 'package:compressor/features/compression/domain/compression_preset.dart';
import 'package:compressor/features/compression/domain/compression_result.dart';
import 'package:compressor/features/compression/domain/processing_stage.dart';
import 'package:compressor/features/compression/presentation/compression_result_screen.dart';
import 'package:compressor/features/file_history/application/file_history_controller.dart';
import 'package:compressor/features/file_history/domain/compressed_file_record.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/l10n/app_localizations.dart';

/// Screen 4: Compression Progress Screen with circular progress indicator and stage tracker.
class CompressionProgressScreen extends StatefulWidget {
  final File? file;
  final List<File>? files;
  final bool saveAsZip;
  final CompressionPreset preset;
  final bool optimizeForWeb;
  final int fileSizeBytes;
  final int pageCount;
  final int? customTargetSizeBytes;
  final bool isImage;
  final FileHistoryController historyController;
  final LanguageController languageController;

  const CompressionProgressScreen({
    super.key,
    this.file,
    this.files,
    this.saveAsZip = false,
    required this.preset,
    required this.optimizeForWeb,
    required this.fileSizeBytes,
    required this.pageCount,
    this.isImage = false,
    this.customTargetSizeBytes,
    required this.historyController,
    required this.languageController,
  }) : assert(file != null || (files != null && files.length > 0));

  @override
  State<CompressionProgressScreen> createState() =>
      _CompressionProgressScreenState();
}

class _CompressionProgressScreenState extends State<CompressionProgressScreen> {
  final CompressionService _compressionService = CompressionService();

  late final List<File> _effectiveFiles;
  bool get _isZipMode => widget.saveAsZip || _effectiveFiles.length > 1;

  ProcessingStage _currentStage = ProcessingStage.preparing;
  double _progress = 0.15;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _effectiveFiles = widget.files != null && widget.files!.isNotEmpty
        ? widget.files!
        : (widget.file != null ? [widget.file!] : []);
    _startCompressionProcess();
  }

  Future<void> _startCompressionProcess() async {
    final CompressionResult result;
    if (_isZipMode) {
      result = await _compressionService.compressToZip(
        inputFiles: _effectiveFiles,
        preset: widget.preset,
        optimizeForWeb: widget.optimizeForWeb,
        onProgress: (stage, progressValue) {
          if (!mounted || _isCancelled) return;
          setState(() {
            _currentStage = stage;
            _progress = progressValue;
          });
        },
      );
    } else {
      result = await _compressionService.compressAuto(
        inputFile: _effectiveFiles.first,
        preset: widget.preset,
        optimizeForWeb: widget.optimizeForWeb,
        customTargetSizeBytes: widget.customTargetSizeBytes,
        onProgress: (stage, progressValue) {
          if (!mounted || _isCancelled) return;
          setState(() {
            _currentStage = stage;
            _progress = progressValue;
          });
        },
      );
    }

    if (!mounted || _isCancelled) return;

    if (result.isSuccess && result.compressedPath != null) {
      final ext = p.extension(result.compressedPath!).toLowerCase();
      final String recordFileType;
      if (ext == '.zip') {
        recordFileType = 'zip';
      } else if (ext == '.pdf') {
        recordFileType = 'pdf';
      } else if (['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
        recordFileType = 'image';
      } else {
        recordFileType = 'files';
      }

      // Save record to local history
      final record = CompressedFileRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: result.fileName,
        filePath: result.compressedPath!,
        originalSizeBytes: result.originalSizeBytes,
        compressedSizeBytes: result.compressedSizeBytes,
        fileType: recordFileType,
        createdAt: DateTime.now(),
        pageCount: recordFileType == 'pdf' ? (result.pageCount ?? widget.pageCount) : null,
      );
      await widget.historyController.addRecord(record);
    }

    if (!mounted) return;

    // Navigate to Result Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => CompressionResultScreen(
          result: result,
          historyController: widget.historyController,
          languageController: widget.languageController,
        ),
      ),
    );
  }

  void _onCancel() {
    _isCancelled = true;
    _compressionService.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final originalFormatted =
        FileSizeFormatter.formatBytes(widget.fileSizeBytes);
    final percentInt = (_progress * 100).clamp(0, 100).toInt();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onCancel();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l10n.compressingTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _onCancel,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Circular Progress Ring Indicator with PDF Badge & Percentage
                      _buildCircularIndicator(percentInt),

                      const SizedBox(height: 24),

                      // Status Title & Subtitle
                      Text(
                        l10n.compressingFile,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.compressingSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Original Size Card (omitting estimated size as actual compression depends on document streams)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isZipMode
                                  ? Icons.folder_zip_outlined
                                  : Icons.insert_drive_file_outlined,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${l10n.originalSize}: ',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              originalFormatted,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (_effectiveFiles.length > 1) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  l10n.filesCount(_effectiveFiles.length),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Processing Stages Checklist (5 Stages)
                      _buildStagesList(l10n, percentInt),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Cancel Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: OutlinedButton(
                  onPressed: _onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.errorLight, width: 1.5),
                    backgroundColor: AppColors.errorLight.withValues(alpha: 0.5),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularIndicator(int percent) {
    return Center(
      child: SizedBox(
        width: 170,
        height: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background track
            SizedBox(
              width: 170,
              height: 170,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 9,
                color: AppColors.primaryLight,
              ),
            ),

            // Active animated progress
            SizedBox(
              width: 170,
              height: 170,
              child: CircularProgressIndicator(
                value: _progress.clamp(0.05, 1.0),
                strokeWidth: 9,
                strokeCap: StrokeCap.round,
                color: AppColors.primary,
              ),
            ),

            // Inner badge & text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isZipMode
                        ? Colors.amber.shade800
                        : (widget.isImage ? AppColors.imageBlue : AppColors.pdfRed),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isZipMode
                        ? 'ZIP'
                        : (widget.isImage ? 'IMG' : 'PDF'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStagesList(AppLocalizations l10n, int percent) {
    final stages = ProcessingStage.values;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(stages.length, (index) {
          final stage = stages[index];
          final isCompleted = _currentStage.index > stage.index;
          final isCurrent = _currentStage.index == stage.index;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Status icon
                if (isCompleted)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 22,
                  )
                else if (isCurrent)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.textMuted, width: 1.5),
                    ),
                  ),

                const SizedBox(width: 14),

                // Label
                Expanded(
                  child: Text(
                    isCurrent
                        ? '${stage.getLocalizedLabel(l10n)} $percent%'
                        : stage.getLocalizedLabel(l10n),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent
                          ? FontWeight.w700
                          : (isCompleted ? FontWeight.w600 : FontWeight.w400),
                      color: isCurrent
                          ? AppColors.primary
                          : (isCompleted
                              ? AppColors.textPrimary
                              : AppColors.textMuted),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
