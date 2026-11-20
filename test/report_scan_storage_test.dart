import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/features/reports/capture/report_scan_storage.dart';

void main() {
  late Directory testDirectory;
  late Directory supportDirectory;
  late Directory sourceDirectory;

  ReportScanStorage createStorage() {
    return ReportScanStorage(
      supportDirectoryProvider: () async => supportDirectory,
    );
  }

  String reportsPath() =>
      '${supportDirectory.path}${Platform.pathSeparator}reports';

  Future<File> createSource(String name, List<int> bytes) async {
    final file = File('${sourceDirectory.path}${Platform.pathSeparator}$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  setUp(() async {
    testDirectory = await Directory.systemTemp.createTemp('report-scan-test-');
    supportDirectory = Directory(
      '${testDirectory.path}${Platform.pathSeparator}support',
    );
    sourceDirectory = Directory(
      '${testDirectory.path}${Platform.pathSeparator}source',
    );
    await sourceDirectory.create();
  });

  tearDown(() async {
    if (await testDirectory.exists()) {
      await testDirectory.delete(recursive: true);
    }
  });

  test('copies JPEG and PDF into persistent app support storage', () async {
    final jpegSource = await createSource('scan.jpg', [1, 2, 3]);
    final pdfSource = await createSource('scan.pdf', [4, 5, 6]);
    final storage = createStorage();

    final saved = await storage.save(
      jpegSources: [jpegSource],
      pdfSource: pdfSource,
    );

    expect(saved, isNotNull);
    final scan = saved!;
    expect(scan.images, hasLength(1));
    expect(scan.images.single.path, endsWith('original.jpg'));
    expect(scan.pdfFile?.path, endsWith('original.pdf'));
    expect(
      scan.images.single.path,
      contains('${Platform.pathSeparator}reports${Platform.pathSeparator}'),
    );
    expect(await scan.images.single.exists(), isTrue);
    expect(await scan.pdfFile!.exists(), isTrue);
    expect(await scan.images.single.readAsBytes(), [1, 2, 3]);
    expect(await scan.pdfFile!.readAsBytes(), [4, 5, 6]);
  });

  test('stores JPEG without creating a PDF when none is supplied', () async {
    final jpegSource = await createSource('scan.jpg', [1]);

    final saved = await createStorage().save(jpegSources: [jpegSource]);

    expect(saved, isNotNull);
    expect(saved!.pdfFile, isNull);
    expect(await saved.images.single.exists(), isTrue);
    expect(
      await File(
        '${saved.images.single.parent.path}${Platform.pathSeparator}original.pdf',
      ).exists(),
      isFalse,
    );
  });

  test('does not create storage when no output files are returned', () async {
    final saved = await createStorage().save(jpegSources: []);

    expect(saved, isNull);
    expect(await Directory(reportsPath()).exists(), isFalse);
  });

  test('surfaces copy failure and removes incomplete scan files', () async {
    final jpegSource = await createSource('scan.jpg', [1]);
    final missingPdfSource = File(
      '${sourceDirectory.path}${Platform.pathSeparator}missing.pdf',
    );

    await expectLater(
      createStorage().save(
        jpegSources: [jpegSource],
        pdfSource: missingPdfSource,
      ),
      throwsA(
        isA<ReportScanStorageException>().having(
          (error) => error.message,
          'message',
          contains('PDF'),
        ),
      ),
    );

    expect(await Directory(reportsPath()).list().toList(), isEmpty);
  });

  test('stores a supplied PDF even when no JPEG is returned', () async {
    final pdfSource = await createSource('scan.pdf', [4]);

    final saved = await createStorage().save(
      jpegSources: [],
      pdfSource: pdfSource,
    );

    expect(saved, isNotNull);
    expect(saved!.images, isEmpty);
    expect(await saved.pdfFile!.exists(), isTrue);
    expect(
      await File(
        '${saved.pdfFile!.parent.path}${Platform.pathSeparator}original.jpg',
      ).exists(),
      isFalse,
    );
  });
}
