import 'dart:io';

import 'package:flutter/material.dart';

import 'document_scanner_service.dart';

class DocumentScannerTestPage extends StatefulWidget {
  const DocumentScannerTestPage({
    super.key,
    this.scannerService = const DocumentScannerService(),
  });

  final DocumentScannerService scannerService;

  @override
  State<DocumentScannerTestPage> createState() =>
      _DocumentScannerTestPageState();
}

class _DocumentScannerTestPageState extends State<DocumentScannerTestPage> {
  bool _isScanning = false;
  bool _isStatusError = false;
  String? _statusMessage;
  DocumentScanResult? _scanResult;

  Future<void> _scanDocument() async {
    setState(() {
      _isScanning = true;
      _isStatusError = false;
      _statusMessage = null;
      _scanResult = null;
    });

    try {
      final result = await widget.scannerService.scanDocument();
      if (!mounted) return;

      setState(() {
        _scanResult = result;
        if (result == null) {
          _statusMessage = 'Scanning cancelled.';
        } else if (result.images.isEmpty) {
          _statusMessage = 'No scanned image was returned.';
        } else {
          _statusMessage = null;
        }
      });
    } on DocumentScannerException catch (error) {
      if (!mounted) return;
      setState(() {
        _statusMessage = error.message;
        _isStatusError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _scanResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Document scanner test')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Scan a report with the camera, or choose gallery import in the '
            'scanner screen.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isScanning ? null : _scanDocument,
            icon: _isScanning
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.document_scanner_outlined),
            label: const Text('Scan Report'),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _statusMessage!,
              style: TextStyle(
                color: _isStatusError
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (result != null) ...[
            const SizedBox(height: 24),
            for (final image in result.images) ...[
              const Text('JPEG result'),
              const SizedBox(height: 8),
              SizedBox(
                height: 360,
                width: double.infinity,
                child: Image.file(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text('Unable to preview this image.'),
                  ),
                ),
              ),
              SelectableText('JPEG file: ${image.path}'),
              _fileExistenceLabel('Stored JPEG exists', image),
              const SizedBox(height: 16),
            ],
            if (result.pdfFile case final pdfFile?) ...[
              const Text('PDF result'),
              SelectableText('PDF file: ${pdfFile.path}'),
              _fileExistenceLabel('Stored PDF exists', pdfFile),
              if (result.pdfPageCount case final pageCount?)
                Text('PDF pages: $pageCount'),
            ],
          ],
        ],
      ),
    );
  }

  Widget _fileExistenceLabel(String label, File file) {
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        final value = snapshot.hasError
            ? 'Error checking file: ${snapshot.error}'
            : snapshot.hasData
            ? '${snapshot.data}'
            : 'Checking...';
        return Text('$label: $value');
      },
    );
  }
}
