import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:compressor/core/theme/app_colors.dart';
import 'package:compressor/features/compression/domain/compression_preset.dart';
import 'package:compressor/features/compression/domain/compression_result.dart';
import 'package:compressor/features/compression/presentation/compression_result_screen.dart';
import 'package:compressor/features/compression/presentation/pdf_compression_screen.dart';
import 'package:compressor/features/file_history/application/file_history_controller.dart';
import 'package:compressor/features/file_history/data/file_history_repository.dart';
import 'package:compressor/features/file_history/domain/compressed_file_record.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/features/language/data/language_repository.dart';
import 'package:compressor/features/main_navigation/presentation/main_scaffold.dart';
import 'package:compressor/l10n/app_localizations.dart';

void main() {
  testWidgets('Generate 6 Play Store Screenshots', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final languageRepo = LanguageRepository(prefs);
    final languageController = LanguageController(languageRepo);

    final historyRepo = FileHistoryRepository(prefs);
    final historyController = FileHistoryController(historyRepo);

    await historyController.addRecord(
      CompressedFileRecord(
        id: '1',
        fileName: 'Biology_Lecture_Slides.pdf',
        filePath: '/dummy/biology.pdf',
        originalSizeBytes: 18500000,
        compressedSizeBytes: 3900000,
        fileType: 'pdf',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        pageCount: 42,
      ),
    );
    await historyController.addRecord(
      CompressedFileRecord(
        id: '2',
        fileName: 'Campus_Event_Photos.zip',
        filePath: '/dummy/photos.zip',
        originalSizeBytes: 45000000,
        compressedSizeBytes: 11200000,
        fileType: 'zip',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    );
    await historyController.addRecord(
      CompressedFileRecord(
        id: '3',
        fileName: 'Project_Certificate.jpg',
        filePath: '/dummy/cert.jpg',
        originalSizeBytes: 8400000,
        compressedSizeBytes: 1400000,
        fileType: 'image',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );

    Future<void> captureScreen(Widget screenWidget, String filename) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              surface: AppColors.surface,
            ),
            scaffoldBackgroundColor: AppColors.background,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: RepaintBoundary(
            key: key,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(540, 960),
                devicePixelRatio: 2.0,
                padding: EdgeInsets.only(top: 24, bottom: 16),
              ),
              child: screenWidget,
            ),
          ),
        ),
      );
      // Wait for any async initState/futures to settle
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final file = File('/home/user/Desktop/compressor/screenshots/$filename');
      file.writeAsBytesSync(pngBytes);
      print('SUCCESS: ${file.path} (${image.width}x${image.height})');
    }

    // 1. Home Dashboard
    await captureScreen(
      MainScaffold(
        languageController: languageController,
        historyController: historyController,
        initialIndex: 0,
      ),
      'screenshot_1_home.png',
    );

    // 2. Preset Selection Screen
    await captureScreen(
      PdfCompressionScreen(
        fileType: 'pdf',
        historyController: historyController,
        languageController: languageController,
      ),
      'screenshot_2_pdf_compression.png',
    );

    // 3. Image Compression Screen
    await captureScreen(
      PdfCompressionScreen(
        fileType: 'image',
        historyController: historyController,
        languageController: languageController,
      ),
      'screenshot_3_image_compression.png',
    );

    // 4. Compression Result Screen
    await captureScreen(
      CompressionResultScreen(
        result: CompressionResult(
          isSuccess: true,
          originalPath: '/dummy/report.pdf',
          compressedPath: '/dummy/report.pdf',
          fileName: 'Annual_Financial_Report_2026.pdf',
          originalSizeBytes: 14800000,
          compressedSizeBytes: 2960000,
          fileType: 'pdf',
          pageCount: 36,
          duration: const Duration(seconds: 2),
        ),
        historyController: historyController,
        languageController: languageController,
      ),
      'screenshot_4_result_comparison.png',
    );

    // 5. My Files Screen
    await captureScreen(
      MainScaffold(
        languageController: languageController,
        historyController: historyController,
        initialIndex: 2,
      ),
      'screenshot_5_my_files.png',
    );

    // 6. Settings Screen
    await captureScreen(
      MainScaffold(
        languageController: languageController,
        historyController: historyController,
        initialIndex: 3,
      ),
      'screenshot_6_settings_privacy.png',
    );
  });
}
