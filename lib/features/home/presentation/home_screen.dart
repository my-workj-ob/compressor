import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:compressor/core/theme/app_colors.dart';
import 'package:compressor/core/utils/file_size_formatter.dart';
import 'package:compressor/features/compression/presentation/pdf_compression_screen.dart';
import 'package:compressor/features/file_history/application/file_history_controller.dart';
import 'package:compressor/features/home/presentation/widgets/action_grid_card.dart';
import 'package:compressor/features/home/presentation/widgets/hero_compression_illustration.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/l10n/app_localizations.dart';

/// Screen 2: Home Screen with quick action cards and compression hero.
class HomeScreen extends StatelessWidget {
  final FileHistoryController historyController;
  final LanguageController languageController;
  final void Function(int tabIndex)? onNavigateTab;

  const HomeScreen({
    super.key,
    required this.historyController,
    required this.languageController,
    this.onNavigateTab,
  });

  Future<void> _pickAndCompressPdf(BuildContext context) async {
    final pickedList = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final files = pickedList
        .where((p) => p.path != null)
        .map((p) => File(p.path!))
        .toList();

    if (files.isNotEmpty && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PdfCompressionScreen(
            initialFiles: files,
            fileType: 'pdf',
            historyController: historyController,
            languageController: languageController,
          ),
        ),
      );
    } else if (context.mounted) {
      // If user opened without picking immediately, navigate to screen to pick
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PdfCompressionScreen(
            fileType: 'pdf',
            historyController: historyController,
            languageController: languageController,
          ),
        ),
      );
    }
  }

  Future<void> _pickAndCompressImage(BuildContext context) async {
    final pickedList = await FilePicker.pickFiles(
      type: FileType.image,
    );
    final files = pickedList
        .where((p) => p.path != null)
        .map((p) => File(p.path!))
        .toList();

    if (files.isNotEmpty && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PdfCompressionScreen(
            initialFiles: files,
            fileType: 'image',
            historyController: historyController,
            languageController: languageController,
          ),
        ),
      );
    } else if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PdfCompressionScreen(
            fileType: 'image',
            historyController: historyController,
            languageController: languageController,
          ),
        ),
      );
    }
  }

  Future<void> _pickAndCompressFiles(BuildContext context) async {
    final pickedList = await FilePicker.pickFiles(
      type: FileType.any,
    );
    final files = pickedList
        .where((p) => p.path != null)
        .map((p) => File(p.path!))
        .toList();

    if (files.isNotEmpty && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PdfCompressionScreen(
            initialFiles: files,
            fileType: 'files',
            historyController: historyController,
            languageController: languageController,
          ),
        ),
      );
    } else if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PdfCompressionScreen(
            fileType: 'files',
            historyController: historyController,
            languageController: languageController,
          ),
        ),
      );
    }
  }

  Future<void> _showCleanFilesModal(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    int tempBytes = 0;
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        final entities = tempDir.listSync(recursive: true);
        for (final entity in entities) {
          if (entity is File) {
            tempBytes += await entity.length();
          }
        }
      }
    } catch (_) {}

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final formattedSize = FileSizeFormatter.formatBytes(tempBytes);

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.cleaning_services_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.cleanFiles,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.cleanFilesSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.cleanFiles,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          formattedSize,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: tempBytes == 0
                        ? null
                        : () async {
                            try {
                              final tempDir = await getTemporaryDirectory();
                              if (await tempDir.exists()) {
                                final entities = tempDir.listSync();
                                for (final entity in entities) {
                                  try {
                                    await entity.delete(recursive: true);
                                  } catch (_) {}
                                }
                              }
                            } catch (_) {}

                            setModalState(() {
                              tempBytes = 0;
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.cacheCleared),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.clearCache,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.featureComingSoon),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => onNavigateTab?.call(3), // Navigate to Settings tab
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
          child: Column(
            children: [
              // Headline Title
              Text(
                l10n.appName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),

              // Tagline
              Text(
                l10n.appTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 16),

              // 3D Hero Compression Illustration
              const HeroCompressionIllustration(size: 175),

              const SizedBox(height: 20),

              // 2x2 Quick Actions Grid
              Row(
                children: [
                  Expanded(
                    child: ActionGridCard(
                      title: l10n.compressPdf,
                      iconWidget: _buildIconBadge(
                        color: AppColors.pdfRed,
                        child: const Text(
                          'PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      onTap: () => _pickAndCompressPdf(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionGridCard(
                      title: l10n.compressImage,
                      iconWidget: _buildIconBadge(
                        color: AppColors.imageBlue,
                        child: const Icon(
                          Icons.image_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onTap: () => _pickAndCompressImage(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ActionGridCard(
                      title: l10n.compressVideo,
                      iconWidget: _buildIconBadge(
                        color: AppColors.videoPurple,
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      onTap: () => _showComingSoon(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionGridCard(
                      title: l10n.compressFiles,
                      iconWidget: _buildIconBadge(
                        color: AppColors.fileGreen,
                        child: const Icon(
                          Icons.insert_drive_file_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onTap: () => _pickAndCompressFiles(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Clean Files Banner Card
              InkWell(
                onTap: () => _showCleanFilesModal(context),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.cleanFiles,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.cleanFilesSubtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge({required Color color, required Widget child}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}
