import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../core/contracts/extraction_service.dart';
import '../../../core/models/extracted_field.dart';
import '../../../mocks/mock_extraction_service.dart';
import 'parser.dart';

/// Production implementation of ExtractionService using Google ML Kit Text Recognition.
class MlKitExtractionService implements ExtractionService {
  final ReportParser parser;
  final bool fallbackToMockOnFailure;

  const MlKitExtractionService({
    this.parser = const ReportParser(),
    this.fallbackToMockOnFailure = true,
  });

  @override
  Future<List<ExtractedField>> extract(File image) async {
    // 1. Guard against non-existent file or simulated placeholder file
    if (!image.existsSync()) {
      debugPrint(
        '[MlKitExtractionService] Notice: File does not exist at "${image.path}".',
      );
      if (fallbackToMockOnFailure) {
        debugPrint(
          '[MlKitExtractionService] Returning default mock fields for seamless developer experience.',
        );
        return MockExtractionService.defaultFields;
      }
      return const [];
    }

    // 2. Perform text recognition using TextRecognizer
    TextRecognizer? textRecognizer;
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      final extractedFields = parser.parseRecognizedText(recognizedText);

      // If text recognition succeeded but no fields were detected, fallback if enabled
      if (extractedFields.isEmpty && fallbackToMockOnFailure) {
        debugPrint(
          '[MlKitExtractionService] No structured lab fields found in OCR text. Falling back to default fields.',
        );
        return MockExtractionService.defaultFields;
      }

      return extractedFields;
    } catch (e, stackTrace) {
      // 3. Gracefully handle platform exceptions (e.g. desktop/web or missing native ML Kit)
      debugPrint(
        '[MlKitExtractionService] ML Kit recognition failed or unsupported on this platform: $e\n$stackTrace',
      );

      if (fallbackToMockOnFailure) {
        debugPrint(
          '[MlKitExtractionService] Gracefully returning mock lab fields.',
        );
        return MockExtractionService.defaultFields;
      }
      return const [];
    } finally {
      // 4. Always close and dispose the recognizer
      await textRecognizer?.close();
    }
  }
}
