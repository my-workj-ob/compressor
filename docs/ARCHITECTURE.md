# Clean PDF & File Compressor - Architecture

## 1. Overview
`Clean PDF & File Compressor` is an offline-first, privacy-by-design Flutter application for document and image compression. The architecture strictly isolates presentation, application logic, domain entities, and data persistence.

```
lib/
├── app/
│   └── app.dart                 # Root MaterialApp, routing, localization setup
├── core/
│   ├── constants/               # Global keys, storage keys
│   ├── errors/                  # App exceptions and failure representations
│   ├── theme/                   # Palette tokens, typography, ThemeData
│   └── utils/                   # File size & date formatters
├── features/
│   ├── language/                # Dedicated first-launch & settings language selection
│   │   ├── domain/              # AppLanguage enum, language models
│   │   ├── data/                # LanguageRepository (SharedPreferences persistence)
│   │   ├── application/         # LanguageController (ChangeNotifier)
│   │   └── presentation/        # LanguageScreen & LanguagePickerSheet
│   ├── home/                    # Main dashboard & quick compression actions
│   │   └── presentation/        # HomeScreen & 3D hero compression illustration
│   ├── compression/             # PDF & Image local processing engine
│   │   ├── domain/              # CompressionPreset, CompressionResult, ProcessingStage
│   │   ├── application/         # CompressionService (local PDF/Image processing)
│   │   └── presentation/        # PdfCompressionScreen, ProgressScreen, ResultScreen
│   ├── file_history/            # Local file records & management
│   │   ├── domain/              # CompressedFileRecord model
│   │   ├── data/                # FileHistoryRepository
│   │   ├── application/         # FileHistoryController
│   │   └── presentation/        # MyFilesScreen (grouped date lists, filters, actions)
│   ├── settings/                # Offline privacy disclosure, language change, cache clear
│   │   └── presentation/        # SettingsScreen
│   └── main_navigation/        # MainScaffold with persistent bottom tabs
├── l10n/                        # ARB translation files (EN, UZ, RU) & generated classes
└── main.dart                    # App bootstrap & dependency initialization
```

## 2. Localization Architecture
- **Official Flutter Intl**: Configured via `l10n.yaml` with ARB files (`app_en.arb`, `app_uz.arb`, `app_ru.arb`).
- **Default Locale**: English (`en`) on first launch.
- **First-Launch Flow**: If no language has been chosen yet, `LanguageScreen` is shown as the initial screen.
- **Persistence**: Chosen language code is stored in `SharedPreferences`.
- **Dynamic Switching**: `LanguageController` notifies listeners; `MaterialApp` rebuilds instantaneously with the updated locale without restarting the app.
- **Zero Hardcoded Strings**: All user-facing UI text, buttons, toasts, and dialogs reference `AppLocalizations.of(context)!`.

## 3. Privacy & Offline Guarantees
- All compression is performed entirely on the client device using `syncfusion_flutter_pdf` and Dart `image` manipulation.
- Zero network requests or analytics trackers are used for file processing.
- Temporary files are stored in the application's cache directory and can be cleared on demand from Settings.
