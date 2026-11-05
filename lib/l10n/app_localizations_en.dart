// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Clean PDF & File Compressor';

  @override
  String get appTagline =>
      'Reduce file size. Keep quality. Offline. Fast. Secure.';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get selectLanguageSubtitle =>
      'Select your preferred language to continue';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishSub => 'Main language';

  @override
  String get languageUzbek => 'O‘zbek tili';

  @override
  String get languageUzbekSub => 'O‘zbekcha';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageRussianSub => 'Русский язык';

  @override
  String get continueButton => 'Continue';

  @override
  String get navHome => 'Home';

  @override
  String get navRecent => 'Recent';

  @override
  String get navFiles => 'Files';

  @override
  String get navSettings => 'Settings';

  @override
  String get compressPdf => 'Compress PDF';

  @override
  String get compressImage => 'Compress Image';

  @override
  String get compressVideo => 'Compress Video';

  @override
  String get compressFiles => 'Compress Files';

  @override
  String get cleanFiles => 'Clean Files';

  @override
  String get cleanFilesSubtitle => 'Find and remove large files';

  @override
  String get selectFilePrompt => 'Select a file to compress';

  @override
  String get chooseFromDevice => 'Choose from Device';

  @override
  String get compressionLevel => 'Compression level';

  @override
  String get levelLight => 'Light';

  @override
  String get levelLightSub => 'Best quality';

  @override
  String get levelBalanced => 'Balanced';

  @override
  String get levelBalancedSub => 'Good quality';

  @override
  String get levelStrong => 'Strong';

  @override
  String get levelStrongSub => 'Smallest size';

  @override
  String get optimizeForWeb => 'Optimize for web';

  @override
  String get optimizeForWebSub => 'Better for sharing online';

  @override
  String get previewFirstPage => 'Preview first page';

  @override
  String get startCompression => 'Start Compression';

  @override
  String get compressingTitle => 'Compressing...';

  @override
  String get compressingSubtitle =>
      'This may take a few moments. Please keep the app open.';

  @override
  String get compressingFile => 'Compressing file...';

  @override
  String get originalSize => 'Original size';

  @override
  String get estimatedSize => 'Estimated size';

  @override
  String get newSize => 'New size';

  @override
  String get stagePreparing => 'Preparing file';

  @override
  String get stageAnalyzing => 'Analyzing content';

  @override
  String get stageCompressing => 'Compressing...';

  @override
  String get stageOptimizing => 'Optimizing for quality';

  @override
  String get stageFinalizing => 'Finalizing file';

  @override
  String get cancel => 'Cancel';

  @override
  String get compressionCompleted => 'Compression completed!';

  @override
  String get compressionSuccessSubtitle =>
      'Your file has been successfully compressed.';

  @override
  String get compressionFailed => 'Compression failed';

  @override
  String get compressionFailedSubtitle =>
      'An error occurred while compressing the file. Please try again.';

  @override
  String percentSmaller(String percent) {
    return '$percent% smaller';
  }

  @override
  String get noReduction => 'File is already optimal';

  @override
  String get openFile => 'Open File';

  @override
  String get share => 'Share';

  @override
  String get saveToDevice => 'Save to Device';

  @override
  String get delete => 'Delete';

  @override
  String get rename => 'Rename';

  @override
  String get renameDialogTitle => 'Rename File';

  @override
  String get enterNewName => 'Enter new file name';

  @override
  String get save => 'Save';

  @override
  String get myFiles => 'My Files';

  @override
  String get searchFiles => 'Search files...';

  @override
  String get filterAll => 'All';

  @override
  String get filterPdf => 'PDF';

  @override
  String get filterImages => 'Images';

  @override
  String get filterVideos => 'Videos';

  @override
  String get filterDocuments => 'Documents';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get noFilesFound => 'No files found';

  @override
  String get noFilesFoundSubtitle => 'Compressed files will appear here';

  @override
  String get deleteConfirmationTitle => 'Delete file?';

  @override
  String get deleteConfirmationMessage =>
      'Are you sure you want to delete this file? This action cannot be undone.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get privacyPolicy => 'Privacy & Security';

  @override
  String get offlineBadge => '100% Offline & Private';

  @override
  String get offlineDescription =>
      'All compression runs locally on your device. Your documents and photos never leave your phone.';

  @override
  String get clearCache => 'Clear Temporary Cache';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get appVersion => 'App Version';

  @override
  String get featureComingSoon =>
      'This feature will be available in the upcoming update.';

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get errorFileNotFound => 'Selected file could not be found or opened.';

  @override
  String get errorFileTooLarge => 'File is too large to process.';

  @override
  String get fileSavedToast => 'File saved to device successfully.';

  @override
  String get fileDeletedToast => 'File deleted.';

  @override
  String get saveAsZip => 'Save as ZIP archive';

  @override
  String get saveAsZipSub => 'Compress and bundle files into a .zip archive';

  @override
  String get addMoreFiles => 'Add more files';

  @override
  String filesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }
}
