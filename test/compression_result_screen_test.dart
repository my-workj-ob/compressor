import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:compressor/features/compression/domain/compression_result.dart';
import 'package:compressor/features/compression/presentation/compression_result_screen.dart';
import 'package:compressor/features/file_history/application/file_history_controller.dart';
import 'package:compressor/features/file_history/data/file_history_repository.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/features/language/data/language_repository.dart';
import 'package:compressor/l10n/app_localizations.dart';

void main() {
  testWidgets('CompressionResultScreen renders Save to Device button',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final languageRepo = LanguageRepository(prefs);
    final languageController = LanguageController(languageRepo);

    final historyRepo = FileHistoryRepository(prefs);
    final historyController = FileHistoryController(historyRepo);

    final tempDir = Directory.systemTemp.createTempSync('compressor_test_');
    final testFile = File('${tempDir.path}/sample_compressed.pdf');
    testFile.writeAsBytesSync([1, 2, 3, 4, 5]);

    final result = CompressionResult(
      isSuccess: true,
      originalPath: '/dummy/original.pdf',
      compressedPath: testFile.path,
      fileName: 'sample_compressed.pdf',
      originalSizeBytes: 10000,
      compressedSizeBytes: 5000,
      fileType: 'pdf',
      duration: const Duration(seconds: 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('uz'),
        home: CompressionResultScreen(
          result: result,
          historyController: historyController,
          languageController: languageController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Qurilmaga saqlash'), findsOneWidget);
    expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    expect(find.text('Faylni ochish'), findsOneWidget);
    expect(find.text('Ulashish'), findsOneWidget);

    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });
}
