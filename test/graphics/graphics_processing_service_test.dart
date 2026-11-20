import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:prenest/features/reports/graphics/graphics_processing_service.dart';

void main() {
  late Directory testDirectory;
  late GraphicsProcessingService service;

  setUp(() async {
    testDirectory = await Directory.systemTemp.createTemp('graphics-test-');
    service = const GraphicsProcessingService();
  });

  tearDown(() async {
    if (await testDirectory.exists()) {
      await testDirectory.delete(recursive: true);
    }
  });

  test('processes a scanned image into enhanced and threshold JPEGs', () async {
    final source = await _createUnevenLightingImage(testDirectory);
    final originalBytes = await source.readAsBytes();

    final result = await service.process(source);

    expect(result.originalFile.path, source.path);
    expect(result.enhancedFile.path, isNot(source.path));
    expect(result.adaptiveThresholdFile.path, isNot(source.path));
    expect(await result.enhancedFile.exists(), isTrue);
    expect(await result.adaptiveThresholdFile.exists(), isTrue);
    expect(
      result.enhancedFile.path,
      endsWith('processed${Platform.pathSeparator}enhanced.jpg'),
    );
    expect(
      result.adaptiveThresholdFile.path,
      endsWith('processed${Platform.pathSeparator}threshold.jpg'),
    );
    expect(img.decodeImage(await result.enhancedFile.readAsBytes()), isNotNull);
    expect(
      img.decodeImage(await result.adaptiveThresholdFile.readAsBytes()),
      isNotNull,
    );
    expect(await source.readAsBytes(), originalBytes);
    expect(result.qualityBefore.unevenLightingDetected, isTrue);
  });

  test(
    'returns measurable quality values before and after processing',
    () async {
      final source = await _createUnevenLightingImage(testDirectory);

      final result = await service.process(source);
      final before = result.qualityBefore;
      final after = result.qualityAfter;

      expect(before.averageBrightness, inInclusiveRange(0, 255));
      expect(before.contrast, greaterThan(0));
      expect(before.illuminationVariation, greaterThan(0));
      expect(before.darkRegionRatio, inInclusiveRange(0, 1));
      expect(before.shadowRegionRatio, inInclusiveRange(0, 1));
      expect(after.averageBrightness, inInclusiveRange(0, 255));
      expect(after.contrast, inInclusiveRange(0, 255));
      expect(after.illuminationVariation, inInclusiveRange(0, 255));
      expect(after.darkRegionRatio, inInclusiveRange(0, 1));
      expect(after.shadowRegionRatio, inInclusiveRange(0, 1));
      expect(
        after.illuminationVariation,
        lessThan(before.illuminationVariation),
      );
    },
  );

  test('detects uneven lighting deterministically', () async {
    final unevenSource = await _createUnevenLightingImage(testDirectory);
    final uniformImage = img.Image(width: 48, height: 48, numChannels: 3);
    for (var y = 0; y < uniformImage.height; y++) {
      for (var x = 0; x < uniformImage.width; x++) {
        uniformImage.setPixelRgb(x, y, 220, 220, 220);
      }
    }
    final uniformSource = File(
      '${testDirectory.path}${Platform.pathSeparator}uniform.jpg',
    );
    await uniformSource.writeAsBytes(img.encodeJpg(uniformImage, quality: 100));

    final unevenFirst = await service.analyze(unevenSource);
    final unevenSecond = await service.analyze(unevenSource);
    final uniform = await service.analyze(uniformSource);

    expect(unevenFirst.unevenLightingDetected, isTrue);
    expect(
      unevenFirst.illuminationVariation,
      unevenSecond.illuminationVariation,
    );
    expect(unevenFirst.darkRegionRatio, unevenSecond.darkRegionRatio);
    expect(uniform.unevenLightingDetected, isFalse);
    expect(uniform.illuminationVariation, lessThan(1));
  });

  test('rejects missing and invalid image inputs cleanly', () async {
    final missing = File(
      '${testDirectory.path}${Platform.pathSeparator}missing.jpg',
    );
    await expectLater(
      service.process(missing),
      throwsA(isA<GraphicsProcessingException>()),
    );

    final invalid = File(
      '${testDirectory.path}${Platform.pathSeparator}invalid.jpg',
    );
    await invalid.writeAsBytes([1, 2, 3, 4]);
    await expectLater(
      service.process(invalid),
      throwsA(isA<GraphicsProcessingException>()),
    );
  });

  test(
    'never overwrites the original scan while writing derivatives',
    () async {
      final source = await _createUnevenLightingImage(testDirectory);
      final sourceBytes = await source.readAsBytes();

      final result = await service.process(source);

      expect(result.originalFile.path, source.path);
      expect(result.enhancedFile.path, isNot(source.path));
      expect(result.adaptiveThresholdFile.path, isNot(source.path));
      expect(await source.readAsBytes(), sourceBytes);
    },
  );
}

Future<File> _createUnevenLightingImage(Directory directory) async {
  final image = img.Image(width: 96, height: 64, numChannels: 3);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final brightness = 105 + (x * 125 ~/ (image.width - 1));
      final isText = y % 12 < 2 && x > 8 && x < 88;
      final value = isText ? 25 : brightness;
      image.setPixelRgb(x, y, value, value, value);
    }
  }

  final file = File('${directory.path}${Platform.pathSeparator}original.jpg');
  await file.writeAsBytes(img.encodeJpg(image, quality: 100));
  return file;
}
