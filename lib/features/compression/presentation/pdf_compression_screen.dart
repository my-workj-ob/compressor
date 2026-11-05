import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:compressor/core/theme/app_colors.dart';
import 'package:compressor/core/utils/file_size_formatter.dart';
import 'package:compressor/features/compression/domain/compression_preset.dart';
import 'package:compressor/features/compression/presentation/compression_progress_screen.dart';
import 'package:compressor/features/file_history/application/file_history_controller.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/l10n/app_localizations.dart';

/// Screen 3: File & Image Compression Screen with selected file details and preset selector.
class PdfCompressionScreen extends StatefulWidget {
  final File? initialFile;
  final List<File>? initialFiles;
  final String fileType; // 'pdf', 'image', or 'files'
  final FileHistoryController historyController;
  final LanguageController languageController;

  const PdfCompressionScreen({
    super.key,
    this.initialFile,
    this.initialFiles,
    this.fileType = 'pdf',
    required this.historyController,
    required this.languageController,
  });

  @override
  State<PdfCompressionScreen> createState() => _PdfCompressionScreenState();
}

class _PdfCompressionScreenState extends State<PdfCompressionScreen> {
  List<File> _selectedFiles = [];
  int _fileSizeBytes = 0;
  int _pageCount = 1;
  CompressionPreset _selectedPreset = CompressionPreset.balanced;
  bool _optimizeForWeb = true;
  bool _saveAsZip = false;

  File? get _selectedFile =>
      _selectedFiles.isNotEmpty ? _selectedFiles.first : null;
  bool get _isMultipleFiles => _selectedFiles.length > 1;

  bool get _isImageMode {
    if (widget.fileType == 'image') return true;
    if (_selectedFiles.isNotEmpty) {
      return _selectedFiles.every((f) {
        final ext = p.extension(f.path).toLowerCase();
        return ['.jpg', '.jpeg', '.png', '.webp'].contains(ext);
      });
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialFiles != null && widget.initialFiles!.isNotEmpty) {
      _processSelectedFiles(widget.initialFiles!);
    } else if (widget.initialFile != null) {
      _processSelectedFiles([widget.initialFile!]);
    }
  }

  Future<void> _processSelectedFiles(List<File> files) async {
    try {
      int totalSize = 0;
      int pages = 1;
      for (final file in files) {
        if (await file.exists()) {
          totalSize += await file.length();
          final ext = p.extension(file.path).toLowerCase();
          if (ext == '.pdf') {
            try {
              final bytes = await file.readAsBytes();
              final doc = PdfDocument(inputBytes: bytes);
              pages = doc.pages.count;
              doc.dispose();
            } catch (_) {
              pages = 1;
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _selectedFiles = List<File>.from(files);
          _fileSizeBytes = totalSize;
          _pageCount = pages;
          if (files.length > 1) {
            _saveAsZip = true;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _pickFile() async {
    final pickedList = widget.fileType == 'image'
        ? await FilePicker.pickFiles(type: FileType.image)
        : (widget.fileType == 'files'
            ? await FilePicker.pickFiles(type: FileType.any)
            : await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              ));

    final files = pickedList
        .where((f) => f.path != null)
        .map((f) => File(f.path!))
        .toList();

    if (files.isNotEmpty) {
      await _processSelectedFiles(files);
    }
  }

  Future<void> _addMoreFiles() async {
    final pickedList = await FilePicker.pickFiles(
      type: widget.fileType == 'image'
          ? FileType.image
          : (widget.fileType == 'pdf'
              ? FileType.custom
              : FileType.any),
      allowedExtensions:
          widget.fileType == 'pdf' ? ['pdf', 'jpg', 'jpeg', 'png', 'webp'] : null,
    );

    final newFiles = pickedList
        .where((f) => f.path != null)
        .map((f) => File(f.path!))
        .toList();

    if (newFiles.isNotEmpty) {
      final existingPaths = _selectedFiles.map((f) => f.path).toSet();
      final combined = List<File>.from(_selectedFiles);
      for (final nf in newFiles) {
        if (!existingPaths.contains(nf.path)) {
          combined.add(nf);
          existingPaths.add(nf.path);
        }
      }
      await _processSelectedFiles(combined);
    }
  }

  Future<void> _removeFile(int index) async {
    if (index >= 0 && index < _selectedFiles.length) {
      final updated = List<File>.from(_selectedFiles)..removeAt(index);
      await _processSelectedFiles(updated);
    }
  }

  void _startCompression() {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectFilePrompt),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CompressionProgressScreen(
          files: _selectedFiles,
          saveAsZip: _saveAsZip || _selectedFiles.length > 1,
          preset: _selectedPreset,
          optimizeForWeb: _optimizeForWeb,
          fileSizeBytes: _fileSizeBytes,
          pageCount: _pageCount,
          isImage: _isImageMode,
          historyController: widget.historyController,
          languageController: widget.languageController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.fileType == 'image'
              ? l10n.compressImage
              : (widget.fileType == 'files'
                  ? l10n.compressFiles
                  : l10n.compressPdf),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected File Card or Picker prompt
                    if (_selectedFile != null)
                      _buildSelectedFileCard(l10n)
                    else
                      _buildPickPromptCard(l10n),

                    const SizedBox(height: 24),

                    // Compression Level Section
                    Text(
                      l10n.compressionLevel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3 Preset Cards in a Row: Light, Balanced, Strong
                    Row(
                      children: [
                        Expanded(
                          child: _buildPresetCard(
                            preset: CompressionPreset.light,
                            l10n: l10n,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPresetCard(
                            preset: CompressionPreset.balanced,
                            l10n: l10n,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPresetCard(
                            preset: CompressionPreset.strong,
                            l10n: l10n,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Save as ZIP toggle card
                    _buildSaveAsZipCard(l10n),

                    if (!_isImageMode) ...[
                      const SizedBox(height: 14),
                      // Optimize for Web Toggle Card
                      _buildOptimizeWebCard(l10n),
                    ],

                    const SizedBox(height: 20),

                    // Preview First Page Section
                    Text(
                      _isMultipleFiles ? l10n.filesCount(_selectedFiles.length) : l10n.previewFirstPage,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPreviewCard(l10n),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Start Compression Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: ElevatedButton(
                onPressed: _startCompression,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.35),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.settings_suggest_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      l10n.startCompression,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFileCard(AppLocalizations l10n) {
    if (_isMultipleFiles) {
      return _buildMultipleFilesCard(l10n);
    }

    final fileName = p.basename(_selectedFile!.path);
    final directory = p.dirname(_selectedFile!.path);
    final formattedSize = FileSizeFormatter.formatBytes(_fileSizeBytes);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _isImageMode ? AppColors.imageBlue : AppColors.pdfRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isImageMode
                      ? const Icon(Icons.image_rounded, color: Colors.white, size: 24)
                      : const Text(
                          'PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // File Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      directory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isImageMode
                          ? formattedSize
                          : '$formattedSize • ${l10n.pagesCount(_pageCount)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.change_circle_outlined, color: AppColors.primary),
                onPressed: _pickFile,
                tooltip: l10n.chooseFromDevice,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          InkWell(
            onTap: _addMoreFiles,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.addMoreFiles,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleFilesCard(AppLocalizations l10n) {
    final formattedSize = FileSizeFormatter.formatBytes(_fileSizeBytes);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.amber.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.folder_zip_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.filesCount(_selectedFiles.length),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formattedSize,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.primary),
                onPressed: _addMoreFiles,
                tooltip: l10n.addMoreFiles,
              ),
              IconButton(
                icon: const Icon(Icons.change_circle_outlined,
                    color: AppColors.primary),
                onPressed: _pickFile,
                tooltip: l10n.chooseFromDevice,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _selectedFiles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final f = _selectedFiles[index];
                final name = p.basename(f.path);
                final ext = p.extension(f.path).toLowerCase();
                final isImg = ['.jpg', '.jpeg', '.png', '.webp'].contains(ext);
                final isPdf = ext == '.pdf';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPdf
                            ? Icons.picture_as_pdf_rounded
                            : (isImg ? Icons.image_rounded : Icons.insert_drive_file_rounded),
                        size: 18,
                        color: isPdf
                            ? AppColors.pdfRed
                            : (isImg ? AppColors.imageBlue : AppColors.fileGreen),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _removeFile(index),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveAsZipCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.folder_zip_rounded,
              color: Colors.amber.shade800,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.saveAsZip,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  l10n.saveAsZipSub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _saveAsZip || _isMultipleFiles,
            activeThumbColor: Colors.amber.shade800,
            activeTrackColor: Colors.amber.shade200,
            onChanged: _isMultipleFiles
                ? null
                : (val) => setState(() => _saveAsZip = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPickPromptCard(AppLocalizations l10n) {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.selectFilePrompt,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.chooseFromDevice,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetCard({
    required CompressionPreset preset,
    required AppLocalizations l10n,
  }) {
    final isSelected = _selectedPreset == preset;

    return InkWell(
      onTap: () => setState(() => _selectedPreset = preset),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              preset.icon,
              color: preset.accentColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              preset.getTitle(l10n),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              preset.getSubtitle(l10n),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizeWebCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.language_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.optimizeForWeb,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  l10n.optimizeForWebSub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _optimizeForWeb,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => setState(() => _optimizeForWeb = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(AppLocalizations l10n) {
    if (_isMultipleFiles) {
      return Container(
        width: double.infinity,
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _selectedFiles.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final f = _selectedFiles[index];
            final ext = p.extension(f.path).toLowerCase();
            final isImg = ['.jpg', '.jpeg', '.png', '.webp'].contains(ext);

            if (isImg) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  f,
                  width: 100,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              );
            }

            return Container(
              width: 90,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ext == '.pdf'
                        ? Icons.picture_as_pdf_rounded
                        : Icons.insert_drive_file_rounded,
                    color:
                        ext == '.pdf' ? AppColors.pdfRed : AppColors.fileGreen,
                    size: 32,
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      p.basename(f.path),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    if (_isImageMode && _selectedFile != null) {
      return Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedFile!,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Simulated page document preview
          Center(
            child: Container(
              width: 120,
              height: 155,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    4,
                    (i) => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      width: double.infinity,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Simulated mini image block
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.apartment_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top right expand icon
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.open_in_full_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
