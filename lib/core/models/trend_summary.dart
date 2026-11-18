import 'package:flutter/foundation.dart';

enum TrendLabelKey {
  firstResult,
  changeTwo,
  movingUpSoFar,
  movingDownSoFar,
  steady,
  notEnough,
  cannotCompare,
}

@immutable
class TrendSummary {
  final int count;
  final double? firstValue;
  final double? latestValue;
  final double? change;
  final double? changePercent;
  final double? positionInRange;
  final TrendLabelKey labelKey;
  final bool canCompare;
  final String reason;

  const TrendSummary({
    required this.count,
    required this.firstValue,
    required this.latestValue,
    required this.change,
    required this.changePercent,
    required this.positionInRange,
    required this.labelKey,
    required this.canCompare,
    required this.reason,
  });
}