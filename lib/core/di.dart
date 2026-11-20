import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/reports/extraction/mlkit_extractor.dart';
import '../features/reports/extraction/normaliser.dart';
import '../features/reports/extraction/parser.dart';
import '../mocks/mock_extraction_service.dart';
import 'contracts/extraction_service.dart';

/// Provider for clinical lab test dictionary matching and confidence scoring.
final normaliserProvider = Provider<LabNormaliser>((ref) {
  return const LabNormaliser();
});

/// Provider for layout-aware parser of OCR blocks, rows, and candidate test values.
final reportParserProvider = Provider<ReportParser>((ref) {
  final normaliser = ref.watch(normaliserProvider);
  return ReportParser(normaliser: normaliser);
});

/// Production ML Kit extraction service with graceful fallback.
final mlKitExtractionServiceProvider = Provider<ExtractionService>((ref) {
  final parser = ref.watch(reportParserProvider);
  return MlKitExtractionService(parser: parser, fallbackToMockOnFailure: true);
});

/// Mock extraction service provider.
final mockExtractionServiceProvider = Provider<ExtractionService>((ref) {
  return const MockExtractionService();
});

/// Notifier to toggle mock extraction mode if needed for testing or simulation.
class UseMockExtractionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setUseMock(bool value) => state = value;
  void toggle() => state = !state;
}

final useMockExtractionProvider =
    NotifierProvider<UseMockExtractionNotifier, bool>(
      UseMockExtractionNotifier.new,
    );
