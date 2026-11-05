import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:compressor/core/constants/app_constants.dart';
import 'package:compressor/features/file_history/domain/compressed_file_record.dart';

/// Repository for persisting compression history locally in SharedPreferences.
class FileHistoryRepository {
  final SharedPreferences _prefs;

  FileHistoryRepository(this._prefs);

  /// Loads all history records ordered by createdAt descending.
  List<CompressedFileRecord> loadRecords() {
    final rawJson = _prefs.getString(AppConstants.prefFileHistory);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      final records = decoded
          .whereType<Map<String, dynamic>>()
          .map(CompressedFileRecord.fromJson)
          .toList();
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return records;
    } catch (_) {
      return [];
    }
  }

  /// Adds a new compressed file record to persistent history.
  Future<void> addRecord(CompressedFileRecord record) async {
    final current = loadRecords();
    current.removeWhere((r) => r.id == record.id);
    current.insert(0, record);
    await _saveRecords(current);
  }

  /// Deletes a record by id.
  Future<void> deleteRecord(String id) async {
    final current = loadRecords();
    current.removeWhere((r) => r.id == id);
    await _saveRecords(current);
  }

  /// Renames an existing record.
  Future<void> renameRecord(String id, String newName) async {
    final current = loadRecords();
    final index = current.indexWhere((r) => r.id == id);
    if (index != -1) {
      current[index] = current[index].copyWith(fileName: newName);
      await _saveRecords(current);
    }
  }

  /// Clears all records.
  Future<void> clearAll() async {
    await _prefs.remove(AppConstants.prefFileHistory);
  }

  Future<void> _saveRecords(List<CompressedFileRecord> records) async {
    final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
    await _prefs.setString(AppConstants.prefFileHistory, encoded);
  }
}
