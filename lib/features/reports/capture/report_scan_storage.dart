import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

typedef SupportDirectoryProvider = Future<Directory> Function();

class ReportScanStorage {
  const ReportScanStorage({this.supportDirectoryProvider});

  final SupportDirectoryProvider? supportDirectoryProvider;

  Future<StoredReportScan?> save({
    required List<File> jpegSources,
    File? pdfSource,
  }) async {
    final images = jpegSources.where((file) => file.path.isNotEmpty).toList();
    final pdf = pdfSource != null && pdfSource.path.isNotEmpty
        ? pdfSource
        : null;
    if (images.isEmpty && pdf == null) return null;

    final Directory supportDirectory;
    try {
      supportDirectory =
          await (supportDirectoryProvider ?? getApplicationSupportDirectory)();
    } on MissingPlatformDirectoryException catch (error) {
      throw ReportScanStorageException(
        'Could not access persistent app storage: ${error.message}',
      );
    } on PlatformException catch (error) {
      throw ReportScanStorageException(
        'Could not access persistent app storage: '
        '${error.message ?? error.code}',
      );
    } on MissingPluginException {
      throw const ReportScanStorageException(
        'Persistent app storage is unavailable on this platform.',
      );
    }

    final reportsDirectory = Directory(
      _joinPath(supportDirectory.path, 'reports'),
    );
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    var scanId = 'scan_$timestamp';
    var scanDirectory = Directory(_joinPath(reportsDirectory.path, scanId));
    var suffix = 1;

    try {
      await reportsDirectory.create(recursive: true);
      while (await scanDirectory.exists()) {
        scanId = 'scan_${timestamp}_$suffix';
        scanDirectory = Directory(_joinPath(reportsDirectory.path, scanId));
        suffix++;
      }
      await scanDirectory.create();

      final savedImages = <File>[];
      for (var index = 0; index < images.length; index++) {
        final name = index == 0 ? 'original.jpg' : 'original_${index + 1}.jpg';
        savedImages.add(
          await _copyFile(
            images[index],
            File(_joinPath(scanDirectory.path, name)),
            'JPEG',
          ),
        );
      }

      final savedPdf = pdf == null
          ? null
          : await _copyFile(
              pdf,
              File(_joinPath(scanDirectory.path, 'original.pdf')),
              'PDF',
            );

      return StoredReportScan(images: savedImages, pdfFile: savedPdf);
    } on ReportScanStorageException {
      await _removeIncompleteScan(scanDirectory);
      rethrow;
    } on FileSystemException catch (error) {
      final cleanupMessage = await _removeIncompleteScan(scanDirectory);
      throw ReportScanStorageException(
        'Could not prepare persistent report storage: ${error.message}'
        '${cleanupMessage ?? ''}',
      );
    }
  }

  Future<File> _copyFile(File source, File destination, String format) async {
    try {
      return await source.copy(destination.path);
    } on FileSystemException catch (error) {
      throw ReportScanStorageException(
        'Could not copy scanned $format into persistent storage: '
        '${error.message}',
      );
    }
  }

  Future<String?> _removeIncompleteScan(Directory scanDirectory) async {
    try {
      if (await scanDirectory.exists()) {
        await scanDirectory.delete(recursive: true);
      }
      return null;
    } on FileSystemException catch (error) {
      return ' Incomplete scan cleanup failed: ${error.message}';
    }
  }

  String _joinPath(String parent, String name) =>
      '$parent${Platform.pathSeparator}$name';
}

class StoredReportScan {
  StoredReportScan({required List<File> images, this.pdfFile})
    : images = List<File>.unmodifiable(images);

  final List<File> images;
  final File? pdfFile;
}

class ReportScanStorageException implements Exception {
  const ReportScanStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}
