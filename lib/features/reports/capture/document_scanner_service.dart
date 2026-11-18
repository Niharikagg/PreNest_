import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

import 'report_scan_storage.dart';

class DocumentScannerService {
  const DocumentScannerService({this.storage = const ReportScanStorage()});

  final ReportScanStorage storage;

  Future<DocumentScanResult?> scanDocument() async {
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg, DocumentFormat.pdf},
        pageLimit: 1,
        mode: ScannerMode.full,
        isGalleryImport: true,
      ),
    );

    try {
      final result = await scanner.scanDocument();
      final imageFiles = (result.images ?? const <String>[])
          .where((path) => path.isNotEmpty)
          .map(File.new)
          .toList(growable: false);
      final pdfPath = result.pdf?.uri;
      final storedScan = await storage.save(
        jpegSources: imageFiles,
        pdfSource: pdfPath == null || pdfPath.isEmpty ? null : File(pdfPath),
      );

      return DocumentScanResult(
        images: storedScan?.images ?? const <File>[],
        pdfFile: storedScan?.pdfFile,
        pdfPageCount: storedScan?.pdfFile == null
            ? null
            : result.pdf?.pageCount,
      );
    } on PlatformException catch (error) {
      if (error.code == 'DocumentScanner' &&
          error.message == 'Operation cancelled') {
        return null;
      }
      throw DocumentScannerException(
        error.message ?? 'Document scanner failed (${error.code}).',
      );
    } on MissingPluginException {
      throw const DocumentScannerException(
        'Document scanner is unavailable on this platform.',
      );
    } on ReportScanStorageException catch (error) {
      throw DocumentScannerException(error.message);
    } on TypeError {
      throw const DocumentScannerException(
        'Document scanner returned an unexpected result.',
      );
    } finally {
      try {
        await scanner.close();
      } on PlatformException catch (error) {
        throw DocumentScannerException(
          error.message ?? 'Could not release the document scanner.',
        );
      } on MissingPluginException {
        throw const DocumentScannerException(
          'Document scanner is unavailable on this platform.',
        );
      }
    }
  }
}

class DocumentScanResult {
  DocumentScanResult({
    required List<File> images,
    this.pdfFile,
    this.pdfPageCount,
  }) : images = List<File>.unmodifiable(images);

  final List<File> images;
  final File? pdfFile;
  final int? pdfPageCount;
}

class DocumentScannerException implements Exception {
  const DocumentScannerException(this.message);

  final String message;

  @override
  String toString() => message;
}
