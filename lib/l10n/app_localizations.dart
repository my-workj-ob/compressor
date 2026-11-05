import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Clean PDF & File Compressor'**
  String get appName;

  /// Tagline displayed on the home screen
  ///
  /// In en, this message translates to:
  /// **'Reduce file size. Keep quality. Offline. Fast. Secure.'**
  String get appTagline;

  /// Header title on the language selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// Subtitle on the language selection screen
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language to continue'**
  String get selectLanguageSubtitle;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// English language subtitle
  ///
  /// In en, this message translates to:
  /// **'Main language'**
  String get languageEnglishSub;

  /// Uzbek language name
  ///
  /// In en, this message translates to:
  /// **'O‘zbek tili'**
  String get languageUzbek;

  /// Uzbek language subtitle
  ///
  /// In en, this message translates to:
  /// **'O‘zbekcha'**
  String get languageUzbekSub;

  /// Russian language name
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// Russian language subtitle
  ///
  /// In en, this message translates to:
  /// **'Русский язык'**
  String get languageRussianSub;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Bottom navigation Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation Recent tab
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get navRecent;

  /// Bottom navigation Files tab
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get navFiles;

  /// Bottom navigation Settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Compress PDF action
  ///
  /// In en, this message translates to:
  /// **'Compress PDF'**
  String get compressPdf;

  /// Compress Image action
  ///
  /// In en, this message translates to:
  /// **'Compress Image'**
  String get compressImage;

  /// Compress Video action
  ///
  /// In en, this message translates to:
  /// **'Compress Video'**
  String get compressVideo;

  /// Compress Files action
  ///
  /// In en, this message translates to:
  /// **'Compress Files'**
  String get compressFiles;

  /// Clean files banner title
  ///
  /// In en, this message translates to:
  /// **'Clean Files'**
  String get cleanFiles;

  /// Clean files banner subtitle
  ///
  /// In en, this message translates to:
  /// **'Find and remove large files'**
  String get cleanFilesSubtitle;

  /// Prompt to select a file
  ///
  /// In en, this message translates to:
  /// **'Select a file to compress'**
  String get selectFilePrompt;

  /// Button to pick file from device
  ///
  /// In en, this message translates to:
  /// **'Choose from Device'**
  String get chooseFromDevice;

  /// Compression level title
  ///
  /// In en, this message translates to:
  /// **'Compression level'**
  String get compressionLevel;

  /// Light compression preset name
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get levelLight;

  /// Light compression preset subtitle
  ///
  /// In en, this message translates to:
  /// **'Best quality'**
  String get levelLightSub;

  /// Balanced compression preset name
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get levelBalanced;

  /// Balanced compression preset subtitle
  ///
  /// In en, this message translates to:
  /// **'Good quality'**
  String get levelBalancedSub;

  /// Strong compression preset name
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get levelStrong;

  /// Strong compression preset subtitle
  ///
  /// In en, this message translates to:
  /// **'Smallest size'**
  String get levelStrongSub;

  /// Optimize for web toggle title
  ///
  /// In en, this message translates to:
  /// **'Optimize for web'**
  String get optimizeForWeb;

  /// Optimize for web toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Better for sharing online'**
  String get optimizeForWebSub;

  /// Preview first page title
  ///
  /// In en, this message translates to:
  /// **'Preview first page'**
  String get previewFirstPage;

  /// Button to start compression
  ///
  /// In en, this message translates to:
  /// **'Start Compression'**
  String get startCompression;

  /// Compressing screen title
  ///
  /// In en, this message translates to:
  /// **'Compressing...'**
  String get compressingTitle;

  /// Compressing screen subtitle
  ///
  /// In en, this message translates to:
  /// **'This may take a few moments. Please keep the app open.'**
  String get compressingSubtitle;

  /// Compressing file status message
  ///
  /// In en, this message translates to:
  /// **'Compressing file...'**
  String get compressingFile;

  /// Original file size label
  ///
  /// In en, this message translates to:
  /// **'Original size'**
  String get originalSize;

  /// Estimated file size label
  ///
  /// In en, this message translates to:
  /// **'Estimated size'**
  String get estimatedSize;

  /// New file size label
  ///
  /// In en, this message translates to:
  /// **'New size'**
  String get newSize;

  /// Stage 1: Preparing file
  ///
  /// In en, this message translates to:
  /// **'Preparing file'**
  String get stagePreparing;

  /// Stage 2: Analyzing content
  ///
  /// In en, this message translates to:
  /// **'Analyzing content'**
  String get stageAnalyzing;

  /// Stage 3: Compressing
  ///
  /// In en, this message translates to:
  /// **'Compressing...'**
  String get stageCompressing;

  /// Stage 4: Optimizing for quality
  ///
  /// In en, this message translates to:
  /// **'Optimizing for quality'**
  String get stageOptimizing;

  /// Stage 5: Finalizing file
  ///
  /// In en, this message translates to:
  /// **'Finalizing file'**
  String get stageFinalizing;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Result screen success title
  ///
  /// In en, this message translates to:
  /// **'Compression completed!'**
  String get compressionCompleted;

  /// Result screen success subtitle
  ///
  /// In en, this message translates to:
  /// **'Your file has been successfully compressed.'**
  String get compressionSuccessSubtitle;

  /// Result screen failure title
  ///
  /// In en, this message translates to:
  /// **'Compression failed'**
  String get compressionFailed;

  /// Result screen failure subtitle
  ///
  /// In en, this message translates to:
  /// **'An error occurred while compressing the file. Please try again.'**
  String get compressionFailedSubtitle;

  /// Badge showing compression reduction percentage
  ///
  /// In en, this message translates to:
  /// **'{percent}% smaller'**
  String percentSmaller(String percent);

  /// Label when file cannot be reduced further
  ///
  /// In en, this message translates to:
  /// **'File is already optimal'**
  String get noReduction;

  /// Open file button
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get openFile;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Save to device button
  ///
  /// In en, this message translates to:
  /// **'Save to Device'**
  String get saveToDevice;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Rename button
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// Rename dialog title
  ///
  /// In en, this message translates to:
  /// **'Rename File'**
  String get renameDialogTitle;

  /// Rename dialog input placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter new file name'**
  String get enterNewName;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// My files screen title
  ///
  /// In en, this message translates to:
  /// **'My Files'**
  String get myFiles;

  /// Search input placeholder
  ///
  /// In en, this message translates to:
  /// **'Search files...'**
  String get searchFiles;

  /// Filter pill All
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter pill PDF
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get filterPdf;

  /// Filter pill Images
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get filterImages;

  /// Filter pill Videos
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get filterVideos;

  /// Filter pill Documents
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get filterDocuments;

  /// Date section Today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// Date section Yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No files found'**
  String get noFilesFound;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Compressed files will appear here'**
  String get noFilesFoundSubtitle;

  /// Delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete file?'**
  String get deleteConfirmationTitle;

  /// Delete dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this file? This action cannot be undone.'**
  String get deleteConfirmationMessage;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language settings tile title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Privacy settings title
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyPolicy;

  /// Offline badge title
  ///
  /// In en, this message translates to:
  /// **'100% Offline & Private'**
  String get offlineBadge;

  /// Offline description in settings
  ///
  /// In en, this message translates to:
  /// **'All compression runs locally on your device. Your documents and photos never leave your phone.'**
  String get offlineDescription;

  /// Clear cache button
  ///
  /// In en, this message translates to:
  /// **'Clear Temporary Cache'**
  String get clearCache;

  /// Snackbar message when cache is cleared
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Snackbar message for upcoming features
  ///
  /// In en, this message translates to:
  /// **'This feature will be available in the upcoming update.'**
  String get featureComingSoon;

  /// Number of pages in PDF
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pagesCount(int count);

  /// Error when file is missing
  ///
  /// In en, this message translates to:
  /// **'Selected file could not be found or opened.'**
  String get errorFileNotFound;

  /// Error when file is too large
  ///
  /// In en, this message translates to:
  /// **'File is too large to process.'**
  String get errorFileTooLarge;

  /// Toast when file is saved
  ///
  /// In en, this message translates to:
  /// **'File saved to device successfully.'**
  String get fileSavedToast;

  /// Toast when file is deleted
  ///
  /// In en, this message translates to:
  /// **'File deleted.'**
  String get fileDeletedToast;

  /// Option to package compressed files into a ZIP
  ///
  /// In en, this message translates to:
  /// **'Save as ZIP archive'**
  String get saveAsZip;

  /// Subtitle for ZIP package option
  ///
  /// In en, this message translates to:
  /// **'Compress and bundle files into a .zip archive'**
  String get saveAsZipSub;

  /// Button to add more files to compression queue
  ///
  /// In en, this message translates to:
  /// **'Add more files'**
  String get addMoreFiles;

  /// Plural counter for selected files
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String filesCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
