import '../core/contracts/trend_service.dart';
import '../core/models/trend_summary.dart';
import '../core/models/verified_result.dart';

class MockTrendService implements TrendService {
  const MockTrendService();

  @override
  TrendSummary summarize(List<VerifiedResult> results) {
    if (results.isEmpty) {
      return const TrendSummary(
        count: 0,
        firstValue: null,
        latestValue: null,
        change: null,
        changePercent: null,
        positionInRange: null,
        labelKey: TrendLabelKey.notEnough,
        canCompare: false,
        reason: 'No historical test records found to compare.',
      );
    }

    if (results.length == 1) {
      final single = results.first;
      return TrendSummary(
        count: 1,
        firstValue: single.value,
        latestValue: single.value,
        change: 0.0,
        changePercent: 0.0,
        positionInRange: 0.5,
        labelKey: TrendLabelKey.firstResult,
        canCompare: true,
        reason: 'Baseline lab reading established.',
      );
    }

    final sorted = List<VerifiedResult>.from(results)
      ..sort((a, b) => a.date.compareTo(b.date));
    final first = sorted.first;
    final latest = sorted.last;
    final diff = latest.value - first.value;
    final pct = first.value != 0 ? (diff / first.value.abs()) * 100 : 0.0;

    TrendLabelKey label;
    if (sorted.length == 2) {
      label = TrendLabelKey.changeTwo;
    } else if (diff > 0.05 * first.value.abs()) {
      label = TrendLabelKey.movingUpSoFar;
    } else if (diff < -0.05 * first.value.abs()) {
      label = TrendLabelKey.movingDownSoFar;
    } else {
      label = TrendLabelKey.steady;
    }

    // Normalized position within standard lab range
    final pos = (latest.value / (first.value == 0 ? 1.0 : (first.value * 1.5)))
        .clamp(0.0, 1.0);

    return TrendSummary(
      count: sorted.length,
      firstValue: first.value,
      latestValue: latest.value,
      change: double.parse(diff.toStringAsFixed(2)),
      changePercent: double.parse(pct.toStringAsFixed(1)),
      positionInRange: double.parse(pos.toStringAsFixed(2)),
      labelKey: label,
      canCompare: true,
      reason: 'Standardized lab units across all recording dates.',
    );
  }
}
