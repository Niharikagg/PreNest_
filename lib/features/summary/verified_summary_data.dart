import '../../core/models/verified_result.dart';

class VerifiedSummaryData {
  VerifiedSummaryData.fromResults(List<VerifiedResult> results)
    : results = List<VerifiedSummaryRow>.unmodifiable(_prepareRows(results));

  final List<VerifiedSummaryRow> results;

  static List<VerifiedSummaryRow> _prepareRows(List<VerifiedResult> results) {
    final rows = <VerifiedSummaryRow>[];
    for (final result in results) {
      if (result.status != VerificationStatus.confirmed &&
          result.status != VerificationStatus.corrected) {
        throw ArgumentError('Summary data can include verified results only.');
      }
      if (result.id.trim().isEmpty ||
          result.testNameStd.trim().isEmpty ||
          result.unit.trim().isEmpty ||
          !result.value.isFinite) {
        throw ArgumentError(
          'A verified result is missing required summary data.',
        );
      }
      rows.add(
        VerifiedSummaryRow(
          testName: result.testNameStd,
          value: result.value,
          unit: result.unit,
          date: result.date,
        ),
      );
    }
    rows.sort((a, b) => a.date.compareTo(b.date));
    return rows;
  }
}

class VerifiedSummaryRow {
  const VerifiedSummaryRow({
    required this.testName,
    required this.value,
    required this.unit,
    required this.date,
  });

  final String testName;
  final double value;
  final String unit;
  final DateTime date;
}
