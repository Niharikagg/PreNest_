import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/models/extracted_field.dart';
import '../../mocks/mock_extraction_service.dart';

@immutable
class VerifyState {
  final bool isLoading;
  final List<ExtractedField> fields;
  final Uint8List? selectedImageBytes;
  final String? selectedImagePath;
  final String? statusMessage;

  const VerifyState({
    this.isLoading = false,
    this.fields = const [],
    this.selectedImageBytes,
    this.selectedImagePath,
    this.statusMessage,
  });

  VerifyState copyWith({
    bool? isLoading,
    List<ExtractedField>? fields,
    Uint8List? selectedImageBytes,
    String? selectedImagePath,
    String? statusMessage,
    bool clearImage = false,
  }) {
    return VerifyState(
      isLoading: isLoading ?? this.isLoading,
      fields: fields ?? this.fields,
      selectedImageBytes: clearImage
          ? null
          : (selectedImageBytes ?? this.selectedImageBytes),
      selectedImagePath: clearImage
          ? null
          : (selectedImagePath ?? this.selectedImagePath),
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class VerifyController extends Notifier<VerifyState> {
  @override
  VerifyState build() {
    return VerifyState(
      isLoading: false,
      fields: MockExtractionService.defaultFields,
      selectedImageBytes: null,
      selectedImagePath: null,
      statusMessage: null,
    );
  }

  /// Extracts lab parameters from an image path and image bytes.
  ///
  /// Stores [bytes] and [path], sets loading state, and calls [ExtractionService].
  /// On Web ([kIsWeb]), falls back gracefully to sample extraction with a status note
  /// to ensure Chrome continues to work without dart:io File crashes.
  Future<void> extractFromImage({
    required String path,
    required Uint8List bytes,
  }) async {
    state = state.copyWith(
      isLoading: true,
      selectedImageBytes: bytes,
      selectedImagePath: path,
      statusMessage: 'Extracting lab parameters from image...',
    );

    try {
      if (kIsWeb) {
        // Fall back gracefully on web since native ML Kit/dart:io File is unsupported
        final fallbackFields = MockExtractionService.defaultFields;
        state = state.copyWith(
          isLoading: false,
          fields: fallbackFields,
          selectedImageBytes: bytes,
          selectedImagePath: path,
          statusMessage:
              'Web preview: Sample extraction applied (Chrome demo mode)',
        );
        return;
      }

      final service = ref.read(extractionServiceProvider);
      final fields = await service.extract(File(path));
      state = state.copyWith(
        isLoading: false,
        fields: fields,
        selectedImageBytes: bytes,
        selectedImagePath: path,
        statusMessage: 'Extracted ${fields.length} lab parameters',
      );
    } catch (e, stackTrace) {
      debugPrint('[VerifyController] Extraction error: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        fields: MockExtractionService.defaultFields,
        selectedImageBytes: bytes,
        selectedImagePath: path,
        statusMessage: 'OCR fallback: Sample extraction applied',
      );
    }
  }

  /// Switches back to the demo report with default sample fields.
  Future<void> loadSampleReport() async {
    state = state.copyWith(
      isLoading: true,
      clearImage: true,
      statusMessage: 'Loading demo lab report...',
    );

    try {
      if (kIsWeb) {
        state = state.copyWith(
          isLoading: false,
          fields: MockExtractionService.defaultFields,
          clearImage: true,
          statusMessage: 'Demo lab report loaded',
        );
        return;
      }

      final service = ref.read(extractionServiceProvider);
      final fields = await service.extract(File('placeholder_lab_report.png'));
      state = state.copyWith(
        isLoading: false,
        fields: fields,
        clearImage: true,
        statusMessage: 'Demo lab report loaded',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        fields: MockExtractionService.defaultFields,
        clearImage: true,
        statusMessage: 'Demo lab report loaded',
      );
    }
  }
}

final verifyControllerProvider =
    NotifierProvider<VerifyController, VerifyState>(VerifyController.new);

final verifyProvider = verifyControllerProvider;
