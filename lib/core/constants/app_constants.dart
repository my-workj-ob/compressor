/// Centralized app constants for preferences, cache keys, and limits.
abstract class AppConstants {
  static const String appName = 'Clean PDF & File Compressor';
  static const String appVersion = '1.0.0';

  // SharedPreferences Keys
  static const String prefLanguageCode = 'pref_selected_language_code';
  static const String prefLanguageSetupCompleted = 'pref_language_setup_completed';
  static const String prefFileHistory = 'pref_compressed_file_history_v1';

  // Default Locale
  static const String defaultLanguageCode = 'en';

  // Supported Locales
  static const String langEnglish = 'en';
  static const String langUzbek = 'uz';
  static const String langRussian = 'ru';
}
