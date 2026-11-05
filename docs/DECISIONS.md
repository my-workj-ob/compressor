# Architectural Decisions

## ADR 001: Localization via Official Flutter `flutter_localizations` & ARB
- **Context**: The app requires complete localization into English, Uzbek (`uz`), and Russian (`ru`).
- **Decision**: Use Flutter's standard `gen-l10n` tool with `output-dir: lib/l10n` and non-synthetic generation to ensure direct, type-safe imports (`package:compressor/l10n/app_localizations.dart`).
- **Consequences**: Compile-time safety, zero runtime translation lookup overhead, support for ICU pluralization and parameter placeholders.

## ADR 002: State Management with `ChangeNotifier` and `ListenableBuilder`
- **Context**: Need lightweight, predictable state management without introducing heavy framework overhead or unnecessary external dependencies.
- **Decision**: Use Dart's built-in `ChangeNotifier` for `LanguageController` and `FileHistoryController`.
- **Consequences**: Standard Flutter primitives, testable in unit tests without widget tree mocking, no boilerplate, zero external state library dependencies.

## ADR 003: Local Offline Compression Engine
- **Context**: User documents and photos must remain strictly confidential and never be transmitted over the network.
- **Decision**: Use `syncfusion_flutter_pdf` for local PDF processing (adjusting image quality, compressing page streams, removing unreferenced resources) and `image` for bitmap compression.
- **Consequences**: Complete privacy guarantee, works with zero internet connection, predictable performance on device.
