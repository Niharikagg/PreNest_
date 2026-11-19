import 'dart:io';
import 'dart:ui';

import '../core/contracts/extraction_service.dart';
import '../core/models/extracted_field.dart';

class MockExtractionService implements ExtractionService {
  const MockExtractionService();

  static List<ExtractedField> get defaultFields => [
    ExtractedField(
      id: 'field_1',
      testNameRaw: 'Hemoglobin (Hb)',
      testNameStd: 'Hemoglobin',
      value: 12.8,
      unit: 'g/dL',
      date: DateTime(2026, 11, 10),
      printedRange: '12.0 - 15.5',
      confidence: 0.95,
      status: ExtractionStatus.auto,
      bbox: const Rect.fromLTWH(24, 120, 280, 40),
    ),
    ExtractedField(
      id: 'field_2',
      testNameRaw: 'TSH (Thyroid Stimulating Hormone)',
      testNameStd: 'TSH',
      value: 2.1,
      unit: 'mIU/L',
      date: DateTime(2026, 11, 10),
      printedRange: '0.4 - 4.0',
      confidence: 0.92,
      status: ExtractionStatus.auto,
      bbox: const Rect.fromLTWH(24, 170, 280, 40),
    ),
    ExtractedField(
      id: 'field_3',
      testNameRaw: 'Vitamin D (25-OH Cholecalciferol)',
      testNameStd: 'Vitamin D',
      value: 22.4,
      unit: 'ng/mL',
      date: DateTime(2026, 11, 10),
      printedRange: '30.0 - 100.0',
      confidence: 0.72,
      status: ExtractionStatus.needsReview,
      bbox: const Rect.fromLTWH(24, 220, 280, 40),
    ),
    ExtractedField(
      id: 'field_4',
      testNameRaw: 'Fasting Blood Sugar (Glucose)',
      testNameStd: 'Fasting Blood Sugar',
      value: 92.0,
      unit: 'mg/dL',
      date: DateTime(2026, 11, 10),
      printedRange: '70.0 - 99.0',
      confidence: 0.88,
      status: ExtractionStatus.auto,
      bbox: const Rect.fromLTWH(24, 270, 280, 40),
    ),
    ExtractedField(
      id: 'field_5',
      testNameRaw: 'Serum Ferritin',
      testNameStd: 'Ferritin',
      value: 18.5,
      unit: 'ng/mL',
      date: DateTime(2026, 11, 10),
      printedRange: '15.0 - 150.0',
      confidence: 0.65,
      status: ExtractionStatus.needsReview,
      bbox: const Rect.fromLTWH(24, 320, 280, 40),
    ),
    ExtractedField(
      id: 'field_6',
      testNameRaw: 'Anti-Müllerian Hormone (AMH)',
      testNameStd: 'AMH',
      value: 2.8,
      unit: 'ng/mL',
      date: DateTime(2026, 11, 10),
      printedRange: '1.5 - 4.0',
      confidence: 0.94,
      status: ExtractionStatus.auto,
      bbox: const Rect.fromLTWH(24, 370, 280, 40),
    ),
  ];

  @override
  Future<List<ExtractedField>> extract(File image) async {
    // Simulated extraction latency
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return defaultFields;
  }
}
