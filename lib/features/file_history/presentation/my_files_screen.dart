import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import 'package:compressor/core/theme/app_colors.dart';
import 'package:compressor/features/file_history/application/file_history_controller.dart';
import 'package:compressor/features/file_history/domain/compressed_file_record.dart';
import 'package:compressor/l10n/app_localizations.dart';

/// Screen 6: My Files Screen with category filters, search, and grouped date sections.
class MyFilesScreen extends StatefulWidget {
  final FileHistoryController historyController;

  const MyFilesScreen({super.key, required this.historyController});

  @override
  State<MyFilesScreen> createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends State<MyFilesScreen> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    widget.historyController.setSearchQuery(value);
  }

  Future<void> _openFile(CompressedFileRecord record) async {
    if (await File(record.filePath).exists()) {
      await OpenFilex.open(record.filePath);
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

  Future<void> _shareFile(CompressedFileRecord record) async {
    final file = File(record.filePath);
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
        ShareParams(files: [XFile(record.filePath)], text: record.fileName),
      );
    } catch (_) {
      // Platform fallback (e.g. Linux desktop where dbus portal file sharing is unsupported)
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final toastText = '${AppLocalizations.of(context)!.fileSavedToast} (${record.filePath})';
        await Clipboard.setData(ClipboardData(text: record.filePath));
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

  Future<void> _saveFile(CompressedFileRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final file = File(record.filePath);

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

    try {
      final bytes = await file.readAsBytes();
      final mimeType = _getMimeType(record.fileName);

      final uri = await FilePicker.saveFile(
        fileName: record.fileName,
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
    }
  }

  Future<void> _renameFile(CompressedFileRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    final textController = TextEditingController(text: record.fileName);

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
      await widget.historyController.renameRecord(record.id, newName);
    }
  }

  Future<void> _deleteFile(CompressedFileRecord record) async {
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
      final f = File(record.filePath);
      if (await f.exists()) await f.delete();
      await widget.historyController.deleteRecord(record.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fileDeletedToast)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchFiles,
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : Text(l10n.myFiles),
        centerTitle: !_isSearchActive,
        actions: [
          IconButton(
            icon: Icon(
              _isSearchActive ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                if (_isSearchActive) {
                  _isSearchActive = false;
                  _searchController.clear();
                  widget.historyController.setSearchQuery('');
                } else {
                  _isSearchActive = true;
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Row
            _buildFilterPills(l10n),

            const SizedBox(height: 8),

            // Grouped Files List or Empty State
            Expanded(
              child: ListenableBuilder(
                listenable: widget.historyController,
                builder: (context, _) {
                  final records = widget.historyController.filteredRecords;

                  if (records.isEmpty) {
                    return _buildEmptyState(l10n);
                  }

                  final grouped = _groupRecordsByDate(records, l10n);

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final group = grouped[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 8),
                            child: Text(
                              group.header,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          ...group.items.map((r) => _buildFileItem(r, l10n)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPills(AppLocalizations l10n) {
    final categories = [
      {'key': 'all', 'label': l10n.filterAll},
      {'key': 'pdf', 'label': l10n.filterPdf},
      {'key': 'image', 'label': l10n.filterImages},
      {'key': 'video', 'label': l10n.filterVideos},
      {'key': 'document', 'label': l10n.filterDocuments},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: categories.map((cat) {
          final isSelected =
              widget.historyController.selectedCategory == cat['key'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat['label']!),
              selected: isSelected,
              onSelected: (_) =>
                  widget.historyController.setCategory(cat['key']!),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFileItem(CompressedFileRecord record, AppLocalizations l10n) {
    final dateFormatted = DateFormat('dd MMM yyyy').format(record.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // File Icon badge
          _buildFileTypeBadge(record.fileType),
          const SizedBox(width: 14),

          // File name & size
          Expanded(
            child: InkWell(
              onTap: () => _openFile(record),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${record.formattedCompressedSize} • $dateFormatted',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3-dots actions menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) {
              switch (val) {
                case 'open':
                  _openFile(record);
                  break;
                case 'save':
                  _saveFile(record);
                  break;
                case 'share':
                  _shareFile(record);
                  break;
                case 'rename':
                  _renameFile(record);
                  break;
                case 'delete':
                  _deleteFile(record);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    const Icon(Icons.visibility_outlined, size: 18),
                    const SizedBox(width: 10),
                    Text(l10n.openFile),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    const Icon(Icons.download_rounded, size: 18),
                    const SizedBox(width: 10),
                    Text(l10n.saveToDevice),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(Icons.share_outlined, size: 18),
                    const SizedBox(width: 10),
                    Text(l10n.share),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 18),
                    const SizedBox(width: 10),
                    Text(l10n.rename),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text(l10n.delete,
                        style: const TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileTypeBadge(String fileType) {
    Color bg;
    Widget child;

    switch (fileType.toLowerCase()) {
      case 'image':
        bg = AppColors.imageBlue;
        child = const Icon(Icons.image_rounded, color: Colors.white, size: 18);
        break;
      case 'zip':
      case 'archive':
        bg = Colors.amber.shade800;
        child = const Icon(Icons.folder_zip_rounded, color: Colors.white, size: 20);
        break;
      case 'video':
        bg = AppColors.videoPurple;
        child = const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20);
        break;
      case 'document':
      case 'files':
        bg = AppColors.fileGreen;
        child = const Icon(Icons.insert_drive_file_rounded, color: Colors.white, size: 18);
        break;
      case 'pdf':
      default:
        bg = AppColors.pdfRed;
        child = const Text(
          'PDF',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        );
        break;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noFilesFound,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.noFilesFoundSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_DateGroup> _groupRecordsByDate(
    List<CompressedFileRecord> records,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<CompressedFileRecord>> map = {};

    for (final record in records) {
      final date = DateTime(
        record.createdAt.year,
        record.createdAt.month,
        record.createdAt.day,
      );

      String header;
      if (date == today) {
        header = l10n.dateToday;
      } else if (date == yesterday) {
        header = l10n.dateYesterday;
      } else {
        header = DateFormat('dd MMM yyyy').format(record.createdAt);
      }

      map.putIfAbsent(header, () => []).add(record);
    }

    return map.entries.map((e) => _DateGroup(e.key, e.value)).toList();
  }
}

class _DateGroup {
  final String header;
  final List<CompressedFileRecord> items;

  _DateGroup(this.header, this.items);
}
