import 'dart:ui';

import 'package:flutter/foundation.dart';

enum ExtractionStatus { auto, needsReview }

@immutable
class ExtractedField {
  final String id;
  final String testNameRaw;
  final String? testNameStd;
  final double? value;
  final String? unit;
  final DateTime? date;
  final String? printedRange;
  final double confidence;
  final ExtractionStatus status;
  final Rect? bbox;

  const ExtractedField({
    required this.id,
    required this.testNameRaw,
    required this.testNameStd,
    required this.value,
    required this.unit,
    required this.date,
    required this.printedRange,
    required this.confidence,
    required this.status,
    required this.bbox,
  }) : assert(confidence >= 0.0 && confidence <= 1.0);
}
