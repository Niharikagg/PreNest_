import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:prenest/features/reports/capture/capture_quality_check_service.dart';
import 'package:prenest/features/reports/capture/document_scanner_service.dart';
import 'package:prenest/features/reports/capture/document_scanner_test_page.dart';
import 'package:prenest/main.dart';

void main() {
  testWidgets('app opens the document scanner test page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Document scanner test'), findsOneWidget);
    expect(find.text('Scan Report'), findsOneWidget);
    expect(find.textContaining('gallery import'), findsOneWidget);
  });

  testWidgets('shows a friendly message when scanning is cancelled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DocumentScannerTestPage(
          scannerService: _FakeDocumentScannerService(null),
        ),
      ),
    );

    await tester.tap(find.text('Scan Report'));
    await tester.pumpAndSettle();

    expect(find.text('Scanning cancelled.'), findsOneWidget);
  });

  testWidgets('reports a result with no image', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DocumentScannerTestPage(
          scannerService: _FakeDocumentScannerService(
            DocumentScanResult(images: []),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Scan Report'));
    await tester.pumpAndSettle();

    expect(find.text('No scanned image was returned.'), findsOneWidget);
  });

  testWidgets('displays scanner failures', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DocumentScannerTestPage(
          scannerService: _FailingDocumentScannerService(),
        ),
      ),
    );

    await tester.tap(find.text('Scan Report'));
    await tester.pumpAndSettle();

    expect(find.text('Scanner failed for testing.'), findsOneWidget);
  });

  testWidgets('blurry capture shows Retake and no Continue', (
    WidgetTester tester,
  ) async {
    final blurry = _qualityResult(
      acceptable: false,
      sharpnessAcceptable: false,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: DocumentScannerTestPage(
          scannerService: _FakeDocumentScannerService(
            DocumentScanResult(images: const <File>[], qualityResult: blurry),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Scan Report'));
    await tester.pumpAndSettle();

    expect(find.text('Capture rejected'), findsOneWidget);
    expect(find.text('Retake'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets('clear capture shows Continue and no Retake', (
    WidgetTester tester,
  ) async {
    late Directory directory;
    late File clearImage;
    await tester.runAsync(() async {
      directory = await Directory.systemTemp.createTemp('capture-ui-test');
      clearImage = File('${directory.path}${Platform.pathSeparator}clear.jpg');
      final clearPixels = img.Image(width: 120, height: 120, numChannels: 3)
        ..setPixelRgb(20, 20, 10, 10, 10)
        ..setPixelRgb(21, 20, 240, 240, 240);
      await clearImage.writeAsBytes(img.encodeJpg(clearPixels));
    });
    addTearDown(() async {
      await tester.runAsync(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });
    });
    final clear = _qualityResult(
      acceptable: true,
      sharpnessAcceptable: true,
      imageFile: clearImage,
    );
    var continued = false;

    await tester.pumpWidget(
      MaterialApp(
        home: DocumentScannerTestPage(
          scannerService: _FakeDocumentScannerService(
            DocumentScanResult(images: [clearImage], qualityResult: clear),
          ),
          onContinue: () => continued = true,
        ),
      ),
    );

    await tester.tap(find.text('Scan Report'));
    await tester.pumpAndSettle();

    expect(find.text('JPEG result'), findsOneWidget);
    expect(find.text('Capture rejected'), findsNothing);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Retake'), findsNothing);
    await tester.tap(find.text('Continue'));
    expect(continued, isTrue);
  });
}

CaptureQualityResult _qualityResult({
  required bool acceptable,
  required bool sharpnessAcceptable,
  File? imageFile,
}) {
  final file = imageFile ?? File('real_test/blurry_real.jpg');
  return CaptureQualityResult(
    imageFile: file,
    checks: CaptureQualityChecks(
      fileExists: true,
      imageDecodable: true,
      dimensionsValid: true,
      sharpnessAcceptable: sharpnessAcceptable,
      brightnessAcceptable: acceptable,
      contrastAcceptable: acceptable,
    ),
    metrics: CaptureQualityMetrics(
      width: 4080,
      height: 3060,
      averageBrightness: acceptable ? 220 : 252,
      contrast: acceptable ? 51 : 14,
      sharpness: acceptable ? 48 : 6,
      laplacianVariance: acceptable ? 3042 : 304,
      strongEdgeRatio: acceptable ? 0.105 : 0.042,
    ),
    failureReasons: acceptable
        ? const <String>[]
        : const <String>['The image appears blurred. Please rescan.'],
  );
}

class _FakeDocumentScannerService extends DocumentScannerService {
  _FakeDocumentScannerService(this.result);

  final DocumentScanResult? result;

  @override
  Future<DocumentScanResult?> scanDocument() async => result;
}

class _FailingDocumentScannerService extends DocumentScannerService {
  @override
  Future<DocumentScanResult?> scanDocument() async {
    throw const DocumentScannerException('Scanner failed for testing.');
  }
}
