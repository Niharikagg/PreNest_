import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/core/models/trend_summary.dart';
import 'package:prenest/core/models/verified_result.dart';
import 'package:prenest/features/trends/default_trend_service.dart';

void main() {
  const service = DefaultTrendService();

  test('sorts compatible results and summarizes their change', () {
    final summary = service.summarize([
      _result(id: 'later', value: 15, date: DateTime(2026, 3)),
      _result(id: 'earlier', value: 10, date: DateTime(2026, 1)),
    ]);

    expect(summary.canCompare, isTrue);
    expect(summary.count, 2);
    expect(summary.firstValue, 10);
    expect(summary.latestValue, 15);
    expect(summary.change, 5);
    expect(summary.changePercent, 50);
    expect(summary.labelKey, TrendLabelKey.changeTwo);
  });

  test('returns not-enough for no verified results', () {
    final summary = service.summarize([]);

    expect(summary.canCompare, isFalse);
    expect(summary.labelKey, TrendLabelKey.notEnough);
    expect(summary.firstValue, isNull);
  });

  test('refuses results from different comparison groups', () {
    final summary = service.summarize([
      _result(id: 'one'),
      _result(id: 'two', personId: 'person-2'),
    ]);

    expect(summary.canCompare, isFalse);
    expect(summary.labelKey, TrendLabelKey.cannotCompare);
    expect(summary.reason, contains('different people'));
  });

  test('omits incomplete results and safely handles a zero baseline', () {
    final summary = service.summarize([
      _result(id: 'zero', value: 0),
      _result(id: 'next', value: 1, date: DateTime(2026, 2)),
      _result(id: 'incomplete', unit: ' ', value: 100),
    ]);

    expect(summary.count, 2);
    expect(summary.latestValue, 1);
    expect(summary.changePercent, isNull);
    expect(summary.labelKey, TrendLabelKey.changeTwo);
  });

  test('uses the first-result label without inventing a change', () {
    final summary = service.summarize([_result(id: 'only')]);

    expect(summary.labelKey, TrendLabelKey.firstResult);
    expect(summary.change, isNull);
    expect(summary.changePercent, isNull);
  });
}

VerifiedResult _result({
  required String id,
  double value = 12,
  DateTime? date,
  String personId = 'person-1',
  String testName = 'hemoglobin',
  String unit = 'g/dL',
  String stage = 'first_trimester',
  VerificationStatus status = VerificationStatus.confirmed,
}) => VerifiedResult(
  id: id,
  personId: personId,
  testNameStd: testName,
  value: value,
  unit: unit,
  date: date ?? DateTime(2026, 1),
  stage: stage,
  status: status,
);
