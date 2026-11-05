import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:compressor/app/app.dart';
import 'package:compressor/features/file_history/application/file_history_controller.dart';
import 'package:compressor/features/file_history/data/file_history_repository.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/features/language/data/language_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize persistent dependencies
  final sharedPreferences = await SharedPreferences.getInstance();

  final languageRepository = LanguageRepository(sharedPreferences);
  final languageController = LanguageController(languageRepository);

  final fileHistoryRepository = FileHistoryRepository(sharedPreferences);
  final fileHistoryController = FileHistoryController(fileHistoryRepository);

  runApp(
    CompressorApp(
      languageController: languageController,
      historyController: fileHistoryController,
    ),
  );
}
