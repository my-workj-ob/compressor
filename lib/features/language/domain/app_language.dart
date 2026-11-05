import 'package:flutter/material.dart';
import 'package:compressor/core/constants/app_constants.dart';
import 'package:compressor/l10n/app_localizations.dart';

/// Supported application languages.
enum AppLanguage {
  english(AppConstants.langEnglish, '🇬🇧'),
  uzbek(AppConstants.langUzbek, '🇺🇿'),
  russian(AppConstants.langRussian, '🇷🇺');

  final String code;
  final String flagEmoji;

  const AppLanguage(this.code, this.flagEmoji);

  Locale get locale => Locale(code);

  static AppLanguage fromLocale(Locale locale) {
    return fromCode(locale.languageCode);
  }

  static AppLanguage fromCode(String? code) {
    switch (code) {
      case AppConstants.langUzbek:
        return AppLanguage.uzbek;
      case AppConstants.langRussian:
        return AppLanguage.russian;
      case AppConstants.langEnglish:
      default:
        return AppLanguage.english;
    }
  }

  /// Native display name for this language.
  String get nativeName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.uzbek:
        return 'O‘zbek tili';
      case AppLanguage.russian:
        return 'Русский';
    }
  }

  /// Native subtitle for this language.
  String get nativeSubtitle {
    switch (this) {
      case AppLanguage.english:
        return 'Main language';
      case AppLanguage.uzbek:
        return 'O‘zbekcha';
      case AppLanguage.russian:
        return 'Русский язык';
    }
  }

  /// Localized title based on active AppLocalizations.
  String getLocalizedTitle(AppLocalizations l10n) {
    switch (this) {
      case AppLanguage.english:
        return l10n.languageEnglish;
      case AppLanguage.uzbek:
        return l10n.languageUzbek;
      case AppLanguage.russian:
        return l10n.languageRussian;
    }
  }

  /// Localized subtitle based on active AppLocalizations.
  String getLocalizedSubtitle(AppLocalizations l10n) {
    switch (this) {
      case AppLanguage.english:
        return l10n.languageEnglishSub;
      case AppLanguage.uzbek:
        return l10n.languageUzbekSub;
      case AppLanguage.russian:
        return l10n.languageRussianSub;
    }
  }
}
