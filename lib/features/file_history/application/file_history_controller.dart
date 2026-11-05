import 'package:flutter/material.dart';
import 'package:compressor/features/file_history/data/file_history_repository.dart';
import 'package:compressor/features/file_history/domain/compressed_file_record.dart';

/// Controller managing file history state, search, and category filtering.
class FileHistoryController extends ChangeNotifier {
  final FileHistoryRepository _repository;

  List<CompressedFileRecord> _records = [];
  String _selectedCategory = 'all'; // 'all', 'pdf', 'image', 'video', 'document'
  String _searchQuery = '';

  FileHistoryController(this._repository) {
    loadRecords();
  }

  List<CompressedFileRecord> get allRecords => _records;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<CompressedFileRecord> get filteredRecords {
    return _records.where((record) {
      // Category filter
      if (_selectedCategory != 'all' &&
          record.fileType.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      // Search filter
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        return record.fileName.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  void loadRecords() {
    _records = _repository.loadRecords();
    notifyListeners();
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addRecord(CompressedFileRecord record) async {
    await _repository.addRecord(record);
    loadRecords();
  }

  Future<void> deleteRecord(String id) async {
    await _repository.deleteRecord(id);
    loadRecords();
  }

  Future<void> renameRecord(String id, String newName) async {
    await _repository.renameRecord(id, newName);
    loadRecords();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    loadRecords();
  }
}
