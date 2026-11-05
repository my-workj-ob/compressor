import 'package:flutter/material.dart';
import 'package:compressor/core/theme/app_theme.dart';
import 'package:compressor/features/file_history/application/file_history_controller.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/features/language/presentation/language_screen.dart';
import 'package:compressor/features/main_navigation/presentation/main_scaffold.dart';
import 'package:compressor/l10n/app_localizations.dart';

/// Root application widget connecting dynamic localization, theme, and first-launch flow.
class CompressorApp extends StatelessWidget {
  final LanguageController languageController;
  final FileHistoryController historyController;

  const CompressorApp({
    super.key,
    required this.languageController,
    required this.historyController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Clean PDF & File Compressor',
          theme: AppTheme.lightTheme,
          locale: languageController.currentLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: languageController.isFirstLaunch
              ? LanguageScreen(
                  controller: languageController,
                  isFirstLaunch: true,
                )
              : MainScaffold(
                  languageController: languageController,
                  historyController: historyController,
                ),
        );
      },
    );
  }
}
