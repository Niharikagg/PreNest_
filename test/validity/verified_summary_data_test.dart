import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/core/models/verified_result.dart';
import 'package:prenest/features/summary/verified_summary_data.dart';

void main() {
  test('prepares date-sorted rows with only verified test details', () {
    final summary = VerifiedSummaryData.fromResults([
      _result(id: 'later', date: DateTime(2026, 2)),
      _result(id: 'earlier', date: DateTime(2026, 1)),
    ]);

    expect(
      summary.results.map((row) => row.testName),
      everyElement('test_name'),
    );
    expect(summary.results.first.value, 1);
    expect(summary.results.first.unit, 'unit');
    expect(summary.results.first.date, DateTime(2026, 1));
  });

  test('rejects incomplete results', () {
    expect(
      () => VerifiedSummaryData.fromResults([
        _result(id: 'incomplete', unit: ' '),
      ]),
      throwsArgumentError,
    );
  });
}

VerifiedResult _result({
  required String id,
  DateTime? date,
  String unit = 'unit',
  VerificationStatus status = VerificationStatus.corrected,
}) => VerifiedResult(
  id: id,
  personId: 'person-1',
  testNameStd: 'test_name',
  value: id == 'earlier' ? 1 : 2,
  unit: unit,
  date: date ?? DateTime(2026, 1),
  stage: 'stage',
  status: status,
);
