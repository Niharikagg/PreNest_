import '../../core/contracts/trend_service.dart';
import '../../core/contracts/validity_engine.dart';
import '../../core/models/trend_summary.dart';
import '../../core/models/verified_result.dart';
import '../validity/default_validity_engine.dart';

class DefaultTrendService implements TrendService {
  const DefaultTrendService({
    this.validityEngine = const DefaultValidityEngine(),
  });

  final ValidityEngine validityEngine;

  @override
  TrendSummary summarize(List<VerifiedResult> results) {
    final verified = results.where(_isVerifiedAndComplete).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (verified.isEmpty) {
      return _emptySummary(
        count: 0,
        labelKey: TrendLabelKey.notEnough,
        reason: 'At least one complete, verified result is needed.',
      );
    }

    for (final result in verified) {
      final verdict = validityEngine.check(verified.first, result);
      if (!verdict.canCompare) {
        return _emptySummary(
          count: verified.length,
          labelKey: TrendLabelKey.cannotCompare,
          reason: verdict.reason,
        );
      }
    }

    final first = verified.first;
    final latest = verified.last;
    if (verified.length == 1) {
      return TrendSummary(
        count: 1,
        firstValue: first.value,
        latestValue: first.value,
        change: null,
        changePercent: null,
        positionInRange: null,
        labelKey: TrendLabelKey.firstResult,
        canCompare: true,
        reason:
            'One verified result is available; no change can be calculated.',
      );
    }

    final change = latest.value - first.value;
    final changePercent = first.value == 0
        ? null
        : (change / first.value.abs()) * 100;
    final labelKey = verified.length == 2
        ? TrendLabelKey.changeTwo
        : change > 0
        ? TrendLabelKey.movingUpSoFar
        : change < 0
        ? TrendLabelKey.movingDownSoFar
        : TrendLabelKey.steady;

    return TrendSummary(
      count: verified.length,
      firstValue: first.value,
      latestValue: latest.value,
      change: change,
      changePercent: changePercent,
      positionInRange: null,
      labelKey: labelKey,
      canCompare: true,
      reason: 'Descriptive change across compatible verified results only.',
    );
  }

  bool _isVerifiedAndComplete(VerifiedResult result) =>
      (result.status == VerificationStatus.confirmed ||
          result.status == VerificationStatus.corrected) &&
      result.id.trim().isNotEmpty &&
      result.personId.trim().isNotEmpty &&
      result.testNameStd.trim().isNotEmpty &&
      result.unit.trim().isNotEmpty &&
      result.stage.trim().isNotEmpty &&
      result.value.isFinite;

  TrendSummary _emptySummary({
    required int count,
    required TrendLabelKey labelKey,
    required String reason,
  }) => TrendSummary(
    count: count,
    firstValue: null,
    latestValue: null,
    change: null,
    changePercent: null,
    positionInRange: null,
    labelKey: labelKey,
    canCompare: false,
    reason: reason,
  );
}
