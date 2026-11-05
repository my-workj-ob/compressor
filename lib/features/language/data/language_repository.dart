import 'package:shared_preferences/shared_preferences.dart';
import 'package:compressor/core/constants/app_constants.dart';

/// Repository for persistent language preferences and onboarding flag.
class LanguageRepository {
  final SharedPreferences _prefs;

  LanguageRepository(this._prefs);

  /// Returns whether the user has previously completed the initial language selection.
  bool get hasCompletedLanguageSetup {
    return _prefs.getBool(AppConstants.prefLanguageSetupCompleted) ?? false;
  }

  /// Sets the flag indicating the user has completed the initial language selection.
  Future<void> setLanguageSetupCompleted(bool value) async {
    await _prefs.setBool(AppConstants.prefLanguageSetupCompleted, value);
  }

  /// Returns the saved language code, or null if never saved.
  String? getSavedLanguageCode() {
    return _prefs.getString(AppConstants.prefLanguageCode);
  }

  /// Persists the selected language code.
  Future<void> saveLanguageCode(String languageCode) async {
    await _prefs.setString(AppConstants.prefLanguageCode, languageCode);
  }
}
