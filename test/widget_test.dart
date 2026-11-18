import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
