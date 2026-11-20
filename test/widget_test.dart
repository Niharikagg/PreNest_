import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:prenest/core/security/app_security_service.dart';
import 'package:prenest/core/security/biometric_authenticator.dart';
import 'package:prenest/core/security/secure_key_storage.dart';
import 'package:prenest/features/reports/capture/capture_quality_check_service.dart';
import 'package:prenest/features/reports/capture/document_scanner_service.dart';
import 'package:prenest/features/reports/capture/document_scanner_test_page.dart';
import 'package:prenest/main.dart';

void main() {
  testWidgets('App shell tabs render behind the root lock gate', (
    WidgetTester tester,
  ) async {
    final authenticator = MockBiometricAuthenticator(shouldSucceed: false);
    final service = AppSecurityService(
      authenticator: authenticator,
      secureStorage: MemorySecureKeyStorage(),
    );
    await tester.pumpWidget(
      ProviderScope(child: MyApp(securityService: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unlock PreNest'), findsOneWidget);
    expect(find.text('Timeline'), findsNothing);

    authenticator.shouldSucceed = true;
    await tester.tap(find.text('Unlock PreNest'));
    await tester.pumpAndSettle();

    expect(find.text('Timeline'), findsWidgets);
    expect(find.text('Records'), findsWidgets);
    expect(find.text('Verify'), findsWidgets);
    expect(find.text('Trends'), findsWidgets);
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
