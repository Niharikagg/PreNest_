import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../core/models/extracted_field.dart';
import '../../core/models/verified_result.dart';
import '../profile/profile_provider.dart';
import '../records/records_provider.dart';
import '../stage/stage_provider.dart';
import 'verify_controller.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _FieldEditModel {
  final ExtractedField original;
  final TextEditingController nameController;
  final TextEditingController valueController;
  final TextEditingController unitController;
  final TextEditingController rangeController;

  _FieldEditModel({required this.original})
    : nameController = TextEditingController(
        text: original.testNameStd ?? original.testNameRaw,
      ),
      valueController = TextEditingController(
        text: original.value != null ? original.value.toString() : '',
      ),
      unitController = TextEditingController(text: original.unit ?? ''),
      rangeController = TextEditingController(
        text: original.printedRange ?? '',
      );

  void dispose() {
    nameController.dispose();
    valueController.dispose();
    unitController.dispose();
    rangeController.dispose();
  }
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<_FieldEditModel> _editModels = [];

  @override
  void initState() {
    super.initState();
    final initialFields = ref.read(verifyControllerProvider).fields;
    if (initialFields.isEmpty) {
      ref.read(verifyControllerProvider.notifier).loadSampleReport();
    } else {
      _editModels = initialFields
          .map((f) => _FieldEditModel(original: f))
          .toList();
    }
  }

  void _updateEditModels(List<ExtractedField> fields) {
    for (final model in _editModels) {
      model.dispose();
    }
    _editModels = fields.map((f) => _FieldEditModel(original: f)).toList();
  }

  @override
  void dispose() {
    for (final model in _editModels) {
      model.dispose();
    }
    super.dispose();
  }

  Future<void> _scanDocument() async {
    try {
      final scanner = ref.read(documentScannerServiceProvider);
      final scanResult = await scanner.scanDocument();

      if (!mounted) return;

      if (scanResult == null) {
        // Scanning was cancelled by user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document scanning cancelled.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Check capture quality checks
      if (scanResult.qualityResult != null &&
          !scanResult.qualityResult!.isAcceptable) {
        final reasons = scanResult.qualityResult!.failureReasons.join('\n');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Capture rejected:\n$reasons'),
            backgroundColor: const Color(0xFFBE123C),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Camera Fallback',
              textColor: Colors.white,
              onPressed: () => _pickImage(ImageSource.camera),
            ),
          ),
        );
        return;
      }

      if (scanResult.images.isNotEmpty) {
        final imageFile = scanResult.images.first;
        final Uint8List bytes = await imageFile.readAsBytes();
        if (!mounted) return;

        final controller = ref.read(verifyControllerProvider.notifier);
        await controller.extractFromImage(path: imageFile.path, bytes: bytes);
        return;
      }

      // No image produced; fallback gracefully to camera picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No scanned image was returned. Opening camera fallback...',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      await _pickImage(ImageSource.camera);
    } catch (e) {
      debugPrint(
        '[VerifyScreen] Document scanner unavailable or failed: $e. Falling back to camera...',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanner unavailable ($e). Falling back to camera...'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      await _pickImage(ImageSource.camera);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (picked == null) {
        // User cancelled picker
        return;
      }

      final Uint8List bytes = await picked.readAsBytes();
      if (!mounted) return;

      final controller = ref.read(verifyControllerProvider.notifier);
      await controller.extractFromImage(path: picked.path, bytes: bytes);
    } catch (e) {
      debugPrint('[VerifyScreen] Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _loadSampleReport() {
    ref.read(verifyControllerProvider.notifier).loadSampleReport();
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final activePartner = ref.read(coupleProvider).activePartner;
    final currentStage = ref.read(stageProvider);

    final results = <VerifiedResult>[];
    for (final model in _editModels) {
      final parsedValue =
          double.tryParse(model.valueController.text.trim()) ?? 0.0;
      final isModified =
          parsedValue != model.original.value ||
          model.unitController.text.trim() != (model.original.unit ?? '');

      results.add(
        VerifiedResult(
          id: 'res_${DateTime.now().millisecondsSinceEpoch}_${model.original.id}',
          personId: activePartner.id,
          testNameStd: model.nameController.text.trim(),
          value: parsedValue,
          unit: model.unitController.text.trim(),
          date: model.original.date ?? DateTime.now(),
          stage: currentStage.name,
          status: isModified
              ? VerificationStatus.corrected
              : VerificationStatus.confirmed,
        ),
      );
    }

    ref.read(recordsProvider.notifier).addVerifiedResults(results);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Confirmed and saved ${results.length} verified lab tests for ${activePartner.name} (${activePartner.role})!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePartner = ref.watch(coupleProvider).activePartner;
    final stage = ref.watch(stageProvider);
    final theme = Theme.of(context);
    final verifyState = ref.watch(verifyControllerProvider);

    ref.listen<VerifyState>(verifyControllerProvider, (previous, next) {
      if ((previous?.isLoading == true && !next.isLoading) ||
          previous?.fields != next.fields) {
        setState(() {
          _updateEditModels(next.fields);
        });
      }
    });

    if (verifyState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              verifyState.statusMessage ??
                  'Extracting lab parameters via OCR...',
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        final topActionBar = Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OCR Verification & Review',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Patient: ${activePartner.name} [${activePartner.role}] • Stage: ${stage.displayName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _onConfirm,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Confirm'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );

        if (isWide) {
          return Column(
            children: [
              topActionBar,
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildReportViewer(context, verifyState),
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    Expanded(flex: 6, child: _buildFieldsList(context)),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              topActionBar,
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 380,
                            child: _buildReportViewer(context, verifyState),
                          ),
                          const SizedBox(height: 16),
                          _buildFieldsList(context, shrinkWrap: true),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _onConfirm,
                            icon: const Icon(Icons.done_all),
                            label: const Text('Confirm & Save All Records'),
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildReportViewer(BuildContext context, VerifyState verifyState) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with zoom indicator and Camera/Gallery/Demo controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.zoom_in, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        verifyState.selectedImageBytes != null
                            ? 'Lab Report Image (Pinch/Scroll to Zoom)'
                            : 'Original Lab Report (Pinch/Scroll to Zoom)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (verifyState.statusMessage != null)
                      Flexible(
                        child: Text(
                          verifyState.statusMessage!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _scanDocument,
                      icon: const Icon(Icons.document_scanner, size: 16),
                      label: const Text('Scan Document'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined, size: 16),
                      label: const Text('Camera'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.science_outlined, size: 16),
                      label: const Text(
                        'Demo Sample',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: _loadSampleReport,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFFBFBFD),
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(32),
                minScale: 0.8,
                maxScale: 3.5,
                child: Center(
                  child: verifyState.selectedImageBytes != null
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.memory(
                            verifyState.selectedImageBytes!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.broken_image_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to display image preview',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : _buildSampleReportPlaceholder(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleReportPlaceholder(BuildContext context) {
    final activePartner = ref.watch(coupleProvider).activePartner;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      width: 440,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lab Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_hospital,
                  color: Colors.blue.shade800,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APEX CLINICAL DIAGNOSTICS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue.shade900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Pre-Conception & Maternal Wellness Panel',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1.5),
          // Patient details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patient: ${activePartner.name} (${activePartner.role})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Text('Date: 10-Nov-2026', style: TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Age/Sex: ${activePartner.age} Y / ${activePartner.role == 'Her' ? 'F' : 'M'}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              Text(
                'Sample: Serum / Whole Blood',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey.shade100,
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Investigation',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Observed',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Unit',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Reference',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Extracted lines in the simulated document
          ..._editModels.map((m) {
            final isLowConf = m.original.confidence < 0.8;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: isLowConf
                    ? Colors.amber.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: isLowConf
                    ? Border.all(color: Colors.amber.shade600, width: 1)
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      m.original.testNameRaw,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      m.original.value?.toString() ?? '--',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isLowConf
                            ? Colors.amber.shade900
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      m.original.unit ?? '',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      m.original.printedRange ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lab Director: Dr. K. Mehta, MD (Path)',
                  style: TextStyle(fontSize: 10),
                ),
                Text(
                  'Status: Final Authorized',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsList(BuildContext context, {bool shrinkWrap = false}) {
    return Form(
      key: _formKey,
      child: ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: shrinkWrap
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _editModels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final model = _editModels[index];
          final isLowConfidence = model.original.confidence < 0.8;
          final theme = Theme.of(context);

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isLowConfidence
                  ? const BorderSide(color: Color(0xFFF59E0B), width: 1.5)
                  : BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
            ),
            color: isLowConfidence ? const Color(0xFFFFFBEB) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Confidence banner
                  if (isLowConfidence)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade400),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amber.shade900,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Low confidence, please verify (${(model.original.confidence * 100).toInt()}%)',
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'High confidence (${(model.original.confidence * 100).toInt()}%)',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Original name tag
                  Text(
                    'Raw OCR: "${model.original.testNameRaw}"',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),

                  // Standardized name field
                  TextFormField(
                    controller: model.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Standardized Test Name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Value, Unit, Reference Range row
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: model.valueController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Value',
                            border: const OutlineInputBorder(),
                            isDense: true,
                            fillColor: isLowConfidence
                                ? Colors.amber.shade50
                                : null,
                            filled: isLowConfidence,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(val.trim()) == null) {
                              return 'Invalid #';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: model.unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: model.rangeController,
                          decoration: const InputDecoration(
                            labelText: 'Ref Range',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
