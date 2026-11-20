import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:prenest/features/reports/capture/capture_quality_check_service.dart';

void main() {
  late Directory testDirectory;
  const service = CaptureQualityCheckService();

  setUp(() async {
    testDirectory = await Directory.systemTemp.createTemp('capture-quality-');
    _currentTestDirectory = testDirectory;
  });

  tearDown(() async {
    if (await testDirectory.exists()) {
      await testDirectory.delete(recursive: true);
    }
  });

  test('accepts a sharp, well-lit, readable image', () async {
    final file = await _writeImage('good.png', _documentImage());

    final result = await service.check(file);

    expect(result.isAcceptable, isTrue);
    expect(result.failureReasons, isEmpty);
    expect(result.checks.allPassed, isTrue);
    expect(result.metrics, isNotNull);
    expect(result.metrics!.width, 160);
    expect(result.metrics!.height, 160);
    expect(result.metrics!.averageBrightness, inInclusiveRange(45, 245));
    expect(result.metrics!.contrast, greaterThan(18));
    expect(result.metrics!.sharpness, greaterThan(12));
    expect(result.metrics!.strongEdgeRatio, greaterThanOrEqualTo(0.05));
    expect(result.metrics!.laplacianVariance, greaterThan(500));
    expect(result.checks.sharpnessAcceptable, isTrue);
    expect(result.checks.brightnessAcceptable, isTrue);
    expect(result.checks.contrastAcceptable, isTrue);
  });

  test('rejects a very blurry image and reports low sharpness', () async {
    final blurred = img.gaussianBlur(_documentImage(), radius: 7);
    final file = await _writeImage('blurred.png', blurred);

    final result = await service.check(file);

    expect(
      result.isAcceptable,
      isFalse,
      reason:
          'sharpness=${result.metrics!.sharpness}, '
          'strongEdgeRatio=${result.metrics!.strongEdgeRatio}, '
          'laplacianVariance=${result.metrics!.laplacianVariance}',
    );
    expect(result.metrics!.laplacianVariance, lessThan(500));
    expect(result.checks.sharpnessAcceptable, isFalse);
    expect(result.failureReasons.join(' '), contains('blurred'));
  });

  test('rejects an excessively dark image', () async {
    final file = await _writeImage(
      'dark.png',
      _documentImage(background: 20, ink: 5),
    );

    final result = await service.check(file);

    expect(result.isAcceptable, isFalse);
    expect(result.metrics!.averageBrightness, lessThan(45));
    expect(result.checks.brightnessAcceptable, isFalse);
    expect(result.failureReasons.join(' '), contains('too dark'));
  });

  test('rejects an excessively bright image', () async {
    final file = await _writeImage(
      'bright.png',
      _documentImage(background: 254, ink: 245),
    );

    final result = await service.check(file);

    expect(result.isAcceptable, isFalse);
    expect(result.metrics!.averageBrightness, greaterThan(245));
    expect(result.checks.brightnessAcceptable, isFalse);
    expect(result.failureReasons.join(' '), contains('too bright'));
  });

  test('rejects an image with poor contrast', () async {
    final file = await _writeImage(
      'low-contrast.png',
      _documentImage(background: 130, ink: 125),
    );

    final result = await service.check(file);

    expect(result.isAcceptable, isFalse);
    expect(result.metrics!.contrast, lessThan(18));
    expect(result.checks.contrastAcceptable, isFalse);
    expect(result.failureReasons.join(' '), contains('low contrast'));
  });

  test('rejects a corrupt image without throwing', () async {
    final file = File(
      '${testDirectory.path}${Platform.pathSeparator}corrupt.png',
    );
    await file.writeAsBytes([1, 2, 3, 4, 5]);

    final result = await service.check(file);

    expect(result.isAcceptable, isFalse);
    expect(result.checks.fileExists, isTrue);
    expect(result.checks.imageDecodable, isFalse);
    expect(result.metrics, isNull);
    expect(result.failureReasons, isNotEmpty);
  });

  test('rejects a missing image without throwing', () async {
    final file = File(
      '${testDirectory.path}${Platform.pathSeparator}missing.png',
    );

    final result = await service.check(file);

    expect(result.isAcceptable, isFalse);
    expect(result.checks.fileExists, isFalse);
    expect(result.metrics, isNull);
    expect(result.failureReasons.join(' '), contains('does not exist'));
  });

  test('rejects images below minimum dimensions', () async {
    final file = await _writeImage(
      'too-small.png',
      _documentImage(width: 80, height: 80),
    );

    final result = await service.check(file);

    expect(result.isAcceptable, isFalse);
    expect(result.metrics!.width, 80);
    expect(result.metrics!.height, 80);
    expect(result.checks.dimensionsValid, isFalse);
    expect(result.failureReasons.join(' '), contains('too small'));
  });

  test('returns deterministic metrics for the same image', () async {
    final file = await _writeImage('deterministic.png', _documentImage());

    final first = await service.check(file);
    final second = await service.check(file);

    expect(first.isAcceptable, second.isAcceptable);
    expect(first.checks.allPassed, second.checks.allPassed);
    expect(first.metrics!.averageBrightness, second.metrics!.averageBrightness);
    expect(first.metrics!.contrast, second.metrics!.contrast);
    expect(first.metrics!.sharpness, second.metrics!.sharpness);
  });

  test('quality checking leaves the original bytes unchanged', () async {
    final file = await _writeImage('original.png', _documentImage());
    final originalBytes = await file.readAsBytes();

    await service.check(file);

    expect(await file.readAsBytes(), originalBytes);
  });
}

img.Image _documentImage({
  int width = 160,
  int height = 160,
  int background = 225,
  int ink = 20,
}) {
  final image = img.Image(width: width, height: height, numChannels: 3);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final isTextLine =
          x >= width ~/ 8 &&
          x < width * 7 ~/ 8 &&
          y >= height ~/ 8 &&
          (y - height ~/ 8) % 20 < 5;
      final value = isTextLine ? ink : background;
      image.setPixelRgb(x, y, value, value, value);
    }
  }
  return image;
}

Future<File> _writeImage(String name, img.Image image) async {
  final file = File('${testDirectoryPath()}${Platform.pathSeparator}$name');
  await file.writeAsBytes(img.encodePng(image));
  return file;
}

String testDirectoryPath() => _currentTestDirectory.path;

late Directory _currentTestDirectory;
