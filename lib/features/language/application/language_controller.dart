import 'package:flutter/material.dart';
import 'package:compressor/core/constants/app_constants.dart';
import 'package:compressor/features/language/data/language_repository.dart';
import 'package:compressor/features/language/domain/app_language.dart';

/// State controller managing active locale and onboarding language selection state.
class LanguageController extends ChangeNotifier {
  final LanguageRepository _repository;

  Locale _currentLocale = const Locale(AppConstants.defaultLanguageCode);
  bool _isFirstLaunch = true;

  LanguageController(this._repository) {
    _init();
  }

  Locale get currentLocale => _currentLocale;
  AppLanguage get currentLanguage => AppLanguage.fromLocale(_currentLocale);
  bool get isFirstLaunch => _isFirstLaunch;

  void _init() {
    final hasCompleted = _repository.hasCompletedLanguageSetup;
    _isFirstLaunch = !hasCompleted;

    final savedCode = _repository.getSavedLanguageCode();
    if (savedCode != null && savedCode.isNotEmpty) {
      _currentLocale = Locale(savedCode);
    } else {
      // English must be the default on initial launch
      _currentLocale = const Locale(AppConstants.defaultLanguageCode);
    }
  }

  /// Changes the application language in real-time and persists the choice.
  Future<void> setLanguage(Locale newLocale) async {
    if (_currentLocale == newLocale) return;
    _currentLocale = newLocale;
    await _repository.saveLanguageCode(newLocale.languageCode);
    notifyListeners();
  }

  /// Completes the initial onboarding language selection and marks it done.
  Future<void> completeLanguageSetup(Locale selectedLocale) async {
    _currentLocale = selectedLocale;
    await _repository.saveLanguageCode(selectedLocale.languageCode);
    await _repository.setLanguageSetupCompleted(true);
    _isFirstLaunch = false;
    notifyListeners();
  }

  /// Resets setup for testing or demonstration purposes.
  Future<void> resetSetupForTesting() async {
    await _repository.setLanguageSetupCompleted(false);
    _isFirstLaunch = true;
    _currentLocale = const Locale(AppConstants.defaultLanguageCode);
    notifyListeners();
  }
}
