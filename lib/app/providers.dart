import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/contracts/extraction_service.dart';
import '../core/contracts/trend_service.dart';
import '../mocks/mock_extraction_service.dart';
import '../mocks/mock_trend_service.dart';

final extractionServiceProvider = Provider<ExtractionService>((ref) {
  return const MockExtractionService();
});

final trendServiceProvider = Provider<TrendService>((ref) {
  return const MockTrendService();
});
