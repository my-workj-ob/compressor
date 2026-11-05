import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:compressor/app/app.dart';
import 'package:compressor/core/constants/app_constants.dart';
import 'package:compressor/features/file_history/application/file_history_controller.dart';
import 'package:compressor/features/file_history/data/file_history_repository.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/features/language/data/language_repository.dart';

void main() {
  testWidgets('Language selection screen is shown on first launch with 3 languages',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final languageRepo = LanguageRepository(prefs);
    final languageController = LanguageController(languageRepo);

    final historyRepo = FileHistoryRepository(prefs);
    final historyController = FileHistoryController(historyRepo);

    await tester.pumpWidget(
      CompressorApp(
        languageController: languageController,
        historyController: historyController,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Screen 1 is displayed
    expect(find.text('Choose Language'), findsOneWidget);
    expect(find.text('Select your preferred language to continue'), findsOneWidget);

    // Verify 3 language options with flags are present
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Main language'), findsOneWidget);
    expect(find.text('O‘zbek tili'), findsOneWidget);
    expect(find.text('O‘zbekcha'), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('Русский язык'), findsOneWidget);

    // Continue button
    expect(find.text('Continue'), findsOneWidget);

    // Tap on Uzbek option
    await tester.tap(find.text('O‘zbek tili'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Text adapts to Uzbek in real-time
    expect(find.text('Tilni tanlang'), findsOneWidget);
    expect(find.text('Davom etish uchun kerakli tilni tanlang'), findsOneWidget);
    expect(find.text('Davom etish'), findsOneWidget);

    // Tap Continue button
    await tester.tap(find.text('Davom etish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Now navigated to MainScaffold / Home screen
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Asosiy'), findsOneWidget); // Uzbek for 'Home'
    expect(find.text('Sozlamalar'), findsOneWidget); // Uzbek for 'Settings'
  });

  testWidgets('Subsequent launch skips language screen and uses saved language',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefLanguageSetupCompleted: true,
      AppConstants.prefLanguageCode: 'ru',
    });
    final prefs = await SharedPreferences.getInstance();

    final languageRepo = LanguageRepository(prefs);
    final languageController = LanguageController(languageRepo);

    final historyRepo = FileHistoryRepository(prefs);
    final historyController = FileHistoryController(historyRepo);

    await tester.pumpWidget(
      CompressorApp(
        languageController: languageController,
        historyController: historyController,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify language selection screen is skipped
    expect(find.text('Choose Language'), findsNothing);
    expect(find.text('Выберите язык'), findsNothing);

    // Verify MainScaffold is shown in Russian
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Настройки'), findsOneWidget);
  });

  testWidgets('Changing language from Settings switches app in real-time',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefLanguageSetupCompleted: true,
      AppConstants.prefLanguageCode: 'en',
    });
    final prefs = await SharedPreferences.getInstance();

    final languageRepo = LanguageRepository(prefs);
    final languageController = LanguageController(languageRepo);

    final historyRepo = FileHistoryRepository(prefs);
    final historyController = FileHistoryController(historyRepo);

    await tester.pumpWidget(
      CompressorApp(
        languageController: languageController,
        historyController: historyController,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap Settings tab (4th tab)
    await tester.tap(find.byIcon(Icons.settings_outlined).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Language'), findsOneWidget);

    // Tap Language tile to open LanguageScreen
    await tester.tap(find.text('Language'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap Russian
    await tester.ensureVisible(find.text('Русский'));
    await tester.tap(find.text('Русский'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap Continue
    await tester.ensureVisible(find.text('Продолжить'));
    await tester.tap(find.text('Продолжить'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // App language updated in real-time to Russian
    expect(find.text('Настройки'), findsWidgets);
    expect(find.text('Язык'), findsOneWidget);
  });
}

