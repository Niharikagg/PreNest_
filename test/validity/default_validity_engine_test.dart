import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/core/models/comparison_verdict.dart';
import 'package:prenest/core/models/verified_result.dart';
import 'package:prenest/features/validity/default_validity_engine.dart';

void main() {
  const engine = DefaultValidityEngine();

  test('allows matching verified results', () {
    final verdict = engine.check(_result(id: 'a'), _result(id: 'b'));

    expect(verdict.canCompare, isTrue);
    expect(verdict.reason, isNotEmpty);
  });

  for (final mismatch in <String, ComparisonVerdict Function()>{
    'person': () =>
        engine.check(_result(id: 'a'), _result(id: 'b', personId: 'other')),
    'test': () =>
        engine.check(_result(id: 'a'), _result(id: 'b', testName: 'platelets')),
    'unit': () => engine.check(_result(id: 'a'), _result(id: 'b', unit: 'g/L')),
    'stage': () => engine.check(
      _result(id: 'a'),
      _result(id: 'b', stage: 'third_trimester'),
    ),
  }.entries) {
    test('rejects different ${mismatch.key}', () {
      final verdict = mismatch.value();
      expect(verdict.canCompare, isFalse);
      expect(verdict.reason, isNotEmpty);
    });
  }

  test('rejects invalid numbers and missing required fields', () {
    final invalidNumber = engine.check(
      _result(id: 'a', value: double.nan),
      _result(id: 'b'),
    );
    final missingStage = engine.check(
      _result(id: 'a', stage: ' '),
      _result(id: 'b'),
    );

    expect(invalidNumber.canCompare, isFalse);
    expect(invalidNumber.reason, contains('numerical'));
    expect(missingStage.canCompare, isFalse);
    expect(missingStage.reason, contains('stage'));
  });
}

VerifiedResult _result({
  required String id,
  String personId = 'person-1',
  String testName = 'hemoglobin',
  String unit = 'g/dL',
  String stage = 'first_trimester',
  double value = 12.0,
  VerificationStatus status = VerificationStatus.confirmed,
}) => VerifiedResult(
  id: id,
  personId: personId,
  testNameStd: testName,
  value: value,
  unit: unit,
  date: DateTime(2026, 1, 1),
  stage: stage,
  status: status,
);
