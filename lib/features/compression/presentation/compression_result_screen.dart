import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import 'package:compressor/core/theme/app_colors.dart';
import 'package:compressor/features/compression/domain/compression_result.dart';
import 'package:compressor/features/file_history/application/file_history_controller.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/features/main_navigation/presentation/main_scaffold.dart';
import 'package:compressor/l10n/app_localizations.dart';

/// Screen 5: Compression Result Screen showing size reduction stats and file actions.
class CompressionResultScreen extends StatefulWidget {
  final CompressionResult result;
  final FileHistoryController historyController;
  final LanguageController languageController;

  const CompressionResultScreen({
    super.key,
    required this.result,
    required this.historyController,
    required this.languageController,
  });

  @override
  State<CompressionResultScreen> createState() =>
      _CompressionResultScreenState();
}

class _CompressionResultScreenState extends State<CompressionResultScreen> {
  late String _currentFileName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentFileName = widget.result.fileName;
  }

  void _onClose() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (context) => MainScaffold(
          languageController: widget.languageController,
          initialIndex: 2, // Navigate to Files tab
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _openFile() async {
    final path = widget.result.compressedPath;
    if (path != null && await File(path).exists()) {
      await OpenFilex.open(path);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorFileNotFound),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _shareFile() async {
    final path = widget.result.compressedPath;
    if (path == null) return;
    final file = File(path);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorFileNotFound),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], text: _currentFileName),
      );
    } catch (_) {
      // Platform fallback (e.g. Linux desktop where portal file sharing is unsupported)
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final toastText = '${AppLocalizations.of(context)!.fileSavedToast} ($path)';
        await Clipboard.setData(ClipboardData(text: path));
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(toastText),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    }
  }

  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _saveToDevice() async {
    if (_isSaving) return;

    final path = widget.result.compressedPath;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    if (path == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorFileNotFound),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorFileNotFound),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final bytes = await file.readAsBytes();
      final mimeType = _getMimeType(_currentFileName);

      final uri = await FilePicker.saveFile(
        fileName: _currentFileName,
        bytes: bytes,
        mimeType: mimeType,
      );

      if (!mounted) return;

      if (uri != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.fileSavedToast),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('${l10n.compressionFailed}: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmationTitle),
        content: Text(l10n.deleteConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final path = widget.result.compressedPath;
      if (path != null) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fileDeletedToast)),
      );
      _onClose();
    }
  }

  Future<void> _showRenameDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final textController = TextEditingController(text: _currentFileName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameDialogTitle),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.enterNewName,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(textController.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && mounted) {
      setState(() => _currentFileName = newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSuccess = widget.result.isSuccess;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 26),
            onPressed: _onClose,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Success / Failure Icon badge
              _buildSuccessBadge(isSuccess),

              const SizedBox(height: 20),

              // Title & Subtitle
              Text(
                isSuccess
                    ? l10n.compressionCompleted
                    : l10n.compressionFailed,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isSuccess
                    ? l10n.compressionSuccessSubtitle
                    : l10n.compressionFailedSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              if (isSuccess) ...[
                // Comparison Card: Original -> New size & Percentage badge
                _buildComparisonCard(l10n),

                const SizedBox(height: 16),

                // File Details Card with Rename icon
                _buildFileCard(l10n),

                const SizedBox(height: 28),

                // Primary Action: Open File
                ElevatedButton(
                  onPressed: _openFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.visibility_outlined, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        l10n.openFile,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary Action: Share
                OutlinedButton(
                  onPressed: _shareFile,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.share,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Tertiary Action: Save to Device
                OutlinedButton(
                  onPressed: _isSaving ? null : _saveToDevice,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSaving) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ] else ...[
                        const Icon(Icons.download_rounded, color: AppColors.textPrimary),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        l10n.saveToDevice,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Destructive Action: Delete
                TextButton(
                  onPressed: _confirmDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        l10n.delete,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge(bool isSuccess) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft radial glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isSuccess ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.12),
            ),
          ),
          // Inner icon circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSuccess ? AppColors.success : AppColors.error,
              boxShadow: [
                BoxShadow(
                  color: (isSuccess ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isSuccess ? Icons.check_rounded : Icons.priority_high_rounded,
                color: Colors.white,
                size: 46,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(AppLocalizations l10n) {
    final reduction = widget.result.reductionPercentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.originalSize,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.result.formattedOriginalSize,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.newSize,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.result.formattedCompressedSize,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Percentage reduction pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.check_rounded, color: AppColors.success, size: 16),
                    ),
                  ),
                  TextSpan(
                    text: reduction > 0
                        ? l10n.percentSmaller(reduction.toString())
                        : l10n.noReduction,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(AppLocalizations l10n) {
    final isZip = widget.result.fileType == 'zip' ||
        widget.result.fileName.toLowerCase().endsWith('.zip');
    final isImage = widget.result.fileType == 'image';

    final Color badgeColor;
    final Widget badgeChild;
    if (isZip) {
      badgeColor = Colors.amber.shade800;
      badgeChild = const Icon(Icons.folder_zip_rounded, color: Colors.white, size: 22);
    } else if (isImage) {
      badgeColor = AppColors.imageBlue;
      badgeChild = const Icon(Icons.image_rounded, color: Colors.white, size: 22);
    } else {
      badgeColor = AppColors.pdfRed;
      badgeChild = const Text(
        'PDF',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: badgeChild),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentFileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  !isImage && widget.result.pageCount != null
                      ? '${widget.result.formattedCompressedSize} • ${l10n.pagesCount(widget.result.pageCount!)}'
                      : widget.result.formattedCompressedSize,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
            onPressed: _showRenameDialog,
            tooltip: l10n.rename,
          ),
        ],
      ),
    );
  }
}
