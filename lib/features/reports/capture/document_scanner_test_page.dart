import 'dart:io';

import 'package:flutter/material.dart';

import 'capture_quality_check_service.dart';
import 'document_scanner_service.dart';

class DocumentScannerTestPage extends StatefulWidget {
  const DocumentScannerTestPage({
    super.key,
    this.scannerService = const DocumentScannerService(),
    this.onContinue,
  });

  final DocumentScannerService scannerService;
  final VoidCallback? onContinue;

  @override
  State<DocumentScannerTestPage> createState() =>
      _DocumentScannerTestPageState();
}

class _DocumentScannerTestPageState extends State<DocumentScannerTestPage> {
  bool _isScanning = false;
  bool _isStatusError = false;
  String? _statusMessage;
  DocumentScanResult? _scanResult;
  CaptureQualityResult? _qualityResult;
  final Map<String, Future<bool>> _fileExistenceChecks = {};

  Future<void> _scanDocument() async {
    setState(() {
      _isScanning = true;
      _isStatusError = false;
      _statusMessage = null;
      _scanResult = null;
      _qualityResult = null;
    });

    try {
      final result = await widget.scannerService.scanDocument();
      if (!mounted) return;

      setState(() {
        _scanResult = result;
        _qualityResult = result?.qualityResult;
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
      bottomNavigationBar: result == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isScanning
                      ? null
                      : _qualityResult?.isAcceptable == true
                      ? widget.onContinue
                      : _scanDocument,
                  icon: Icon(
                    _qualityResult?.isAcceptable == true
                        ? Icons.arrow_forward
                        : Icons.camera_alt_outlined,
                  ),
                  label: Text(
                    _qualityResult?.isAcceptable == true
                        ? 'Continue'
                        : 'Retake',
                  ),
                ),
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Scan a report with the camera, or choose gallery import in the '
            'scanner screen.',
          ),
          const SizedBox(height: 16),
          if (_scanResult == null)
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
            if (_qualityResult != null && !_qualityResult!.isAcceptable) ...[
              Text(
                'Capture rejected',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              for (final reason in _qualityResult!.failureReasons) Text(reason),
            ] else if (result.images.isNotEmpty) ...[
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
        ],
      ),
    );
  }

  Widget _fileExistenceLabel(String label, File file) {
    return FutureBuilder<bool>(
      future: _fileExistenceChecks.putIfAbsent(file.path, () => file.exists()),
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
