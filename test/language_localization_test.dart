import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:compressor/core/constants/app_constants.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/features/language/data/language_repository.dart';
import 'package:compressor/features/language/domain/app_language.dart';
import 'package:compressor/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Language & Localization Tests', () {
    test('Default language is English on first launch', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LanguageRepository(prefs);
      final controller = LanguageController(repo);

      expect(controller.isFirstLaunch, isTrue);
      expect(controller.currentLocale.languageCode, equals('en'));
      expect(controller.currentLanguage, equals(AppLanguage.english));
    });

    test('Completing language setup persists choice and clears isFirstLaunch', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LanguageRepository(prefs);
      final controller = LanguageController(repo);

      await controller.completeLanguageSetup(const Locale('uz'));

      expect(controller.isFirstLaunch, isFalse);
      expect(controller.currentLocale.languageCode, equals('uz'));
      expect(controller.currentLanguage, equals(AppLanguage.uzbek));
      expect(prefs.getBool(AppConstants.prefLanguageSetupCompleted), isTrue);
      expect(prefs.getString(AppConstants.prefLanguageCode), equals('uz'));
    });

    test('Subsequent launches restore saved language and skip language selection', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefLanguageSetupCompleted: true,
        AppConstants.prefLanguageCode: 'ru',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = LanguageRepository(prefs);
      final controller = LanguageController(repo);

      expect(controller.isFirstLaunch, isFalse);
      expect(controller.currentLocale.languageCode, equals('ru'));
      expect(controller.currentLanguage, equals(AppLanguage.russian));
    });

    test('Real-time language switching notifies listeners and updates preference', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefLanguageSetupCompleted: true,
        AppConstants.prefLanguageCode: 'en',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = LanguageRepository(prefs);
      final controller = LanguageController(repo);

      bool notified = false;
      controller.addListener(() => notified = true);

      await controller.setLanguage(const Locale('uz'));

      expect(notified, isTrue);
      expect(controller.currentLocale.languageCode, equals('uz'));
      expect(prefs.getString(AppConstants.prefLanguageCode), equals('uz'));

      // Switch to Russian
      notified = false;
      await controller.setLanguage(const Locale('ru'));
      expect(notified, isTrue);
      expect(controller.currentLocale.languageCode, equals('ru'));
      expect(controller.currentLanguage, equals(AppLanguage.russian));
      expect(prefs.getString(AppConstants.prefLanguageCode), equals('ru'));
    });

    test('Completing language setup with Russian persists choice', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LanguageRepository(prefs);
      final controller = LanguageController(repo);

      await controller.completeLanguageSetup(const Locale('ru'));

      expect(controller.isFirstLaunch, isFalse);
      expect(controller.currentLocale.languageCode, equals('ru'));
      expect(controller.currentLanguage, equals(AppLanguage.russian));
      expect(prefs.getBool(AppConstants.prefLanguageSetupCompleted), isTrue);
      expect(prefs.getString(AppConstants.prefLanguageCode), equals('ru'));
    });

    test('All 3 language locales have complete translations without missing strings', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final uz = await AppLocalizations.delegate.load(const Locale('uz'));
      final ru = await AppLocalizations.delegate.load(const Locale('ru'));

      // Verify essential title and prompt strings
      expect(en.chooseLanguage, equals('Choose Language'));
      expect(uz.chooseLanguage, equals('Tilni tanlang'));
      expect(ru.chooseLanguage, equals('Выберите язык'));

      expect(en.continueButton, equals('Continue'));
      expect(uz.continueButton, equals('Davom etish'));
      expect(ru.continueButton, equals('Продолжить'));

      expect(en.appName, isNotEmpty);
      expect(uz.appName, isNotEmpty);
      expect(ru.appName, isNotEmpty);

      expect(en.compressPdf, isNotEmpty);
      expect(uz.compressPdf, isNotEmpty);
      expect(ru.compressPdf, isNotEmpty);

      expect(en.settings, isNotEmpty);
      expect(uz.settings, isNotEmpty);
      expect(ru.settings, isNotEmpty);

      // Verify plural handling
      expect(en.pagesCount(1), equals('1 page'));
      expect(en.pagesCount(120), equals('120 pages'));
      expect(uz.pagesCount(1), equals('1 sahifa'));
      expect(uz.pagesCount(120), equals('120 sahifa'));
      expect(ru.pagesCount(1), equals('1 страница'));
      expect(ru.pagesCount(5), equals('5 страниц'));
    });
  });
}
