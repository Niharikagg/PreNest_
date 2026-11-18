import 'package:flutter/foundation.dart';

@immutable
class ComparisonVerdict {
  final bool canCompare;
  final String reason;

  const ComparisonVerdict({
    required this.canCompare,
    required this.reason,
  });
}