import 'dart:io';
import 'dart:ui';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:compressor/features/compression/application/compression_service.dart';
import 'package:compressor/features/compression/domain/compression_preset.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final Directory tempDir;
  MockPathProviderPlatform(this.tempDir);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return tempDir.path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return tempDir.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testDir;
  late CompressionService compressionService;

  setUp(() async {
    testDir = await Directory.systemTemp.createTemp('compressor_test_');
    PathProviderPlatform.instance = MockPathProviderPlatform(testDir);
    compressionService = CompressionService();
  });

  tearDown(() async {
    try {
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  test('compressImage achieves genuine measurable reduction on large image',
      () async {
    // Generate a test high-resolution uncompressed image (1800x1200)
    final image = img.Image(width: 1800, height: 1200);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        image.setPixelRgb(x, y, (x * 2) % 255, (y * 3) % 255, (x + y) % 255);
      }
    }
    // Encode initially with 100% quality (large file)
    final rawBytes = img.encodeJpg(image, quality: 100);
    final testFile = File(p.join(testDir.path, 'sample_photo.jpg'));
    await testFile.writeAsBytes(rawBytes);
    final originalSize = await testFile.length();

    // Run strong compression
    final result = await compressionService.compressImage(
      inputFile: testFile,
      preset: CompressionPreset.strong,
    );

    expect(result.isSuccess, isTrue);
    expect(result.compressedPath, isNotNull);
    expect(result.fileType, equals('image'));
    expect(result.compressedSizeBytes, lessThan(originalSize));
    // Verify genuine reduction (> 40% reduction)
    expect(result.reductionPercentage, greaterThan(40));

    final compressedFile = File(result.compressedPath!);
    expect(await compressedFile.exists(), isTrue);
  });

  test('compressPdf achieves genuine measurable reduction on PDF with images',
      () async {
    // Create a PDF with embedded high-res image
    final doc = PdfDocument();
    final page = doc.pages.add();

    final image = img.Image(width: 800, height: 800);
    for (int y = 0; y < 800; y++) {
      for (int x = 0; x < 800; x++) {
        image.setPixelRgb(x, y, (x * 255) ~/ 800, (y * 255) ~/ 800, ((x + y) * 128) ~/ 800);
      }
    }
    final originalJpg = img.encodeJpg(image, quality: 95);
    page.graphics.drawImage(PdfBitmap(originalJpg), const Rect.fromLTWH(0, 0, 400, 400));
    final initialPdfBytes = await doc.save();
    doc.dispose();

    final pdfFile = File(p.join(testDir.path, 'sample_book.pdf'));
    await pdfFile.writeAsBytes(initialPdfBytes);
    final originalSize = await pdfFile.length();

    // Run strong PDF compression
    final result = await compressionService.compressPdf(
      inputFile: pdfFile,
      preset: CompressionPreset.strong,
      optimizeForWeb: true,
    );

    expect(result.isSuccess, isTrue);
    expect(result.compressedPath, isNotNull);
    expect(result.fileType, equals('pdf'));
    expect(result.compressedSizeBytes, lessThan(originalSize));
    // Verify substantial reduction
    expect(result.reductionPercentage, greaterThan(30));

    final compressedFile = File(result.compressedPath!);
    expect(await compressedFile.exists(), isTrue);

    // Verify it is a valid PDF readable by PdfDocument
    final reloadedDoc = PdfDocument(inputBytes: await compressedFile.readAsBytes());
    expect(reloadedDoc.pages.count, equals(1));
    reloadedDoc.dispose();
  });

  test('compressArchive achieves genuine reduction on zip file', () async {
    final archive = Archive();
    // Add multiple repetitive text files
    for (int i = 0; i < 5; i++) {
      final content = List<int>.generate(10000, (index) => index % 64);
      archive.addFile(ArchiveFile('file_$i.txt', content.length, content));
    }
    final rawZip = ZipEncoder().encodeBytes(archive, level: DeflateLevel.none);

    final zipFile = File(p.join(testDir.path, 'test_archive.zip'));
    await zipFile.writeAsBytes(rawZip);
    final originalSize = await zipFile.length();

    final result = await compressionService.compressArchive(
      inputFile: zipFile,
      preset: CompressionPreset.strong,
    );

    expect(result.isSuccess, isTrue);
    expect(result.compressedSizeBytes, lessThan(originalSize));
  });

  test('compressArchive achieves deep transcompression on ZIP containing images', () async {
    final archive = Archive();
    final image = img.Image(width: 1200, height: 1200);
    for (int y = 0; y < 1200; y++) {
      for (int x = 0; x < 1200; x++) {
        image.setPixelRgb(x, y, (x * 255) ~/ 1200, (y * 255) ~/ 1200, ((x + y) * 128) ~/ 1200);
      }
    }
    final originalJpg = img.encodeJpg(image, quality: 95);
    archive.addFile(ArchiveFile('photo.jpg', originalJpg.length, originalJpg));
    final rawZip = ZipEncoder().encodeBytes(archive, level: DeflateLevel.bestCompression);

    final zipFile = File(p.join(testDir.path, 'photo_archive.zip'));
    await zipFile.writeAsBytes(rawZip);
    final originalSize = await zipFile.length();

    final result = await compressionService.compressArchive(
      inputFile: zipFile,
      preset: CompressionPreset.strong,
    );

    expect(result.isSuccess, isTrue);
    expect(result.compressedSizeBytes, lessThan(originalSize));
    expect(result.reductionPercentage, greaterThan(20));
  });

  test('compressAuto dispatches properly based on extension', () async {
    final textFile = File(p.join(testDir.path, 'data.txt'));
    await textFile.writeAsString('Hello world' * 500);

    final result = await compressionService.compressAuto(
      inputFile: textFile,
      preset: CompressionPreset.balanced,
    );

    expect(result.isSuccess, isTrue);
    expect(result.compressedPath, isNotNull);
  });

  test('compressPdf handles JPEG 2000 (JPXDecode) and achieves genuine reduction', () async {
    final bookFile = File('/tmp/test_book.pdf');
    if (!await bookFile.exists()) return;

    final origSize = await bookFile.length();
    final result = await compressionService.compressPdf(
      inputFile: bookFile,
      preset: CompressionPreset.strong,
      optimizeForWeb: true,
    );

    expect(result.isSuccess, isTrue);
    expect(result.compressedSizeBytes, lessThan(origSize));
    expect(result.pageCount, equals(328));
  });

  test('compressToZip bundles multiple files and images into a valid compressed ZIP',
      () async {
    // Create 2 test images
    final img1 = img.Image(width: 800, height: 600);
    final img1Bytes = img.encodeJpg(img1, quality: 90);
    final f1 = File(p.join(testDir.path, 'lecture_note_1.jpg'));
    await f1.writeAsBytes(img1Bytes);

    final img2 = img.Image(width: 800, height: 600);
    final img2Bytes = img.encodeJpg(img2, quality: 90);
    final f2 = File(p.join(testDir.path, 'lecture_note_2.jpg'));
    await f2.writeAsBytes(img2Bytes);

    // Create 1 text file
    final f3 = File(p.join(testDir.path, 'syllabus.txt'));
    await f3.writeAsString('Student notes for compressor app' * 100);

    final totalOriginal = await f1.length() + await f2.length() + await f3.length();

    final result = await compressionService.compressToZip(
      inputFiles: [f1, f2, f3],
      preset: CompressionPreset.strong,
    );

    expect(result.isSuccess, isTrue);
    expect(result.fileType, equals('zip'));
    expect(result.compressedPath, isNotNull);
    expect(result.fileName.endsWith('.zip'), isTrue);
    expect(result.originalSizeBytes, equals(totalOriginal));

    final zipFile = File(result.compressedPath!);
    expect(await zipFile.exists(), isTrue);

    // Verify it is a valid ZIP and contains all 3 files
    final zipBytes = await zipFile.readAsBytes();
    final decodedArchive = ZipDecoder().decodeBytes(zipBytes);
    expect(decodedArchive.files.length, equals(3));
    final fileNames = decodedArchive.files.map((e) => e.name).toSet();
    expect(fileNames, contains('lecture_note_1.jpg'));
    expect(fileNames, contains('lecture_note_2.jpg'));
    expect(fileNames, contains('syllabus.txt'));
  });
}
