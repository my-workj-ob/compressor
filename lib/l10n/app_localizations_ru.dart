// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Clean PDF & File Compressor';

  @override
  String get appTagline =>
      'Сжимайте файлы с сохранением качества. Офлайн. Быстро. Безопасно.';

  @override
  String get chooseLanguage => 'Выберите язык';

  @override
  String get selectLanguageSubtitle =>
      'Выберите предпочтительный язык для продолжения';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishSub => 'Основной язык';

  @override
  String get languageUzbek => 'O‘zbek tili';

  @override
  String get languageUzbekSub => 'Узбекский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageRussianSub => 'Русский язык';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get navHome => 'Главная';

  @override
  String get navRecent => 'Недавние';

  @override
  String get navFiles => 'Файлы';

  @override
  String get navSettings => 'Настройки';

  @override
  String get compressPdf => 'Сжать PDF';

  @override
  String get compressImage => 'Сжать фото';

  @override
  String get compressVideo => 'Сжать видео';

  @override
  String get compressFiles => 'Сжать файлы';

  @override
  String get cleanFiles => 'Очистить файлы';

  @override
  String get cleanFilesSubtitle => 'Поиск и удаление тяжелых файлов';

  @override
  String get selectFilePrompt => 'Выберите файл для сжатия';

  @override
  String get chooseFromDevice => 'Выбрать на устройстве';

  @override
  String get compressionLevel => 'Уровень сжатия';

  @override
  String get levelLight => 'Мягкий';

  @override
  String get levelLightSub => 'Лучшее качество';

  @override
  String get levelBalanced => 'Баланс';

  @override
  String get levelBalancedSub => 'Хорошее качество';

  @override
  String get levelStrong => 'Сильный';

  @override
  String get levelStrongSub => 'Минимальный размер';

  @override
  String get optimizeForWeb => 'Оптимизация для сети';

  @override
  String get optimizeForWebSub => 'Удобно для отправки через интернет';

  @override
  String get previewFirstPage => 'Предпросмотр первой страницы';

  @override
  String get startCompression => 'Начать сжатие';

  @override
  String get compressingTitle => 'Сжатие...';

  @override
  String get compressingSubtitle =>
      'Это может занять немного времени. Пожалуйста, не закрывайте приложение.';

  @override
  String get compressingFile => 'Сжатие файла...';

  @override
  String get originalSize => 'Исходный размер';

  @override
  String get estimatedSize => 'Ожидаемый размер';

  @override
  String get newSize => 'Новый размер';

  @override
  String get stagePreparing => 'Подготовка файла';

  @override
  String get stageAnalyzing => 'Анализ содержимого';

  @override
  String get stageCompressing => 'Сжатие...';

  @override
  String get stageOptimizing => 'Оптимизация качества';

  @override
  String get stageFinalizing => 'Завершение обработки';

  @override
  String get cancel => 'Отмена';

  @override
  String get compressionCompleted => 'Сжатие завершено!';

  @override
  String get compressionSuccessSubtitle => 'Ваш файл был успешно сжат.';

  @override
  String get compressionFailed => 'Сжатие не удалось';

  @override
  String get compressionFailedSubtitle =>
      'Произошла ошибка при сжатии файла. Попробуйте еще раз.';

  @override
  String percentSmaller(String percent) {
    return 'на $percent% меньше';
  }

  @override
  String get noReduction => 'Файл уже оптимального размера';

  @override
  String get openFile => 'Открыть файл';

  @override
  String get share => 'Поделиться';

  @override
  String get saveToDevice => 'Сохранить на устройство';

  @override
  String get delete => 'Удалить';

  @override
  String get rename => 'Переименовать';

  @override
  String get renameDialogTitle => 'Переименовать файл';

  @override
  String get enterNewName => 'Введите новое имя файла';

  @override
  String get save => 'Сохранить';

  @override
  String get myFiles => 'Мои файлы';

  @override
  String get searchFiles => 'Поиск файлов...';

  @override
  String get filterAll => 'Все';

  @override
  String get filterPdf => 'PDF';

  @override
  String get filterImages => 'Изображения';

  @override
  String get filterVideos => 'Видео';

  @override
  String get filterDocuments => 'Документы';

  @override
  String get dateToday => 'Сегодня';

  @override
  String get dateYesterday => 'Вчера';

  @override
  String get noFilesFound => 'Файлы не найдены';

  @override
  String get noFilesFoundSubtitle => 'Сжатые файлы появятся здесь';

  @override
  String get deleteConfirmationTitle => 'Удалить файл?';

  @override
  String get deleteConfirmationMessage =>
      'Вы уверены, что хотите удалить этот файл? Это действие нельзя отменить.';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get privacyPolicy => 'Приватность и безопасность';

  @override
  String get offlineBadge => '100% Офлайн и Приватно';

  @override
  String get offlineDescription =>
      'Все операции выполняются строго локально на вашем телефоне. Файлы никуда не передаются.';

  @override
  String get clearCache => 'Очистить временный кэш';

  @override
  String get cacheCleared => 'Кэш успешно очищен';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get featureComingSoon =>
      'Эта функция появится в ближайшем обновлении.';

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count страницы',
      many: '$count страниц',
      few: '$count страницы',
      one: '1 страница',
    );
    return '$_temp0';
  }

  @override
  String get errorFileNotFound => 'Выбранный файл не найден или недоступен.';

  @override
  String get errorFileTooLarge => 'Файл слишком большой для обработки.';

  @override
  String get fileSavedToast => 'Файл успешно сохранен на устройство.';

  @override
  String get fileDeletedToast => 'Файл удален.';

  @override
  String get saveAsZip => 'Сохранить в ZIP архив';

  @override
  String get saveAsZipSub => 'Сжать и упаковать файлы в .zip архив';

  @override
  String get addMoreFiles => 'Добавить файлы';

  @override
  String filesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файлов',
      many: '$count файлов',
      few: '$count файла',
      one: '1 файл',
    );
    return '$_temp0';
  }
}
