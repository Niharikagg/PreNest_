import 'package:flutter/foundation.dart';

enum VerificationStatus { confirmed, corrected }

@immutable
class VerifiedResult {
  final String id;
  final String personId;
  final String testNameStd;
  final double value;
  final String unit;
  final DateTime date;
  final String stage;
  final VerificationStatus status;

  const VerifiedResult({
    required this.id,
    required this.personId,
    required this.testNameStd,
    required this.value,
    required this.unit,
    required this.date,
    required this.stage,
    required this.status,
  });
}
