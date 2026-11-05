import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
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
  Future<String?> getApplicationDocumentsPath() async => tempDir.path;

  @override
  Future<String?> getTemporaryPath() async => tempDir.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CompressionService.compressPdf executes successfully', () async {
    final tempDir = await Directory.systemTemp.createTemp('pdf_test_');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir);

    try {
      final doc = PdfDocument();
      doc.pages.add();
      final initialBytes = await doc.save();
      doc.dispose();

      final pdfFile = File(p.join(tempDir.path, 'sample_doc.pdf'));
      await pdfFile.writeAsBytes(initialBytes);

      final service = CompressionService();
      final result = await service.compressPdf(
        inputFile: pdfFile,
        preset: CompressionPreset.strong,
        optimizeForWeb: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.compressedPath, isNotNull);
      expect(File(result.compressedPath!).existsSync(), isTrue);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
