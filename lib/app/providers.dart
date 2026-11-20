import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/contracts/extraction_service.dart';
import '../core/contracts/trend_service.dart';
import '../core/di.dart';
import '../mocks/mock_trend_service.dart';

export '../core/di.dart';

final extractionServiceProvider = Provider<ExtractionService>((ref) {
  final useMock = ref.watch(useMockExtractionProvider);
  if (useMock) {
    return ref.watch(mockExtractionServiceProvider);
  }
  return ref.watch(mlKitExtractionServiceProvider);
});

final trendServiceProvider = Provider<TrendService>((ref) {
  return const MockTrendService();
});
