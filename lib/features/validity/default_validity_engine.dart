import '../../core/contracts/validity_engine.dart';
import '../../core/models/comparison_verdict.dart';
import '../../core/models/verified_result.dart';

class DefaultValidityEngine implements ValidityEngine {
  const DefaultValidityEngine();

  @override
  ComparisonVerdict check(VerifiedResult first, VerifiedResult second) {
    final firstError = _validationError(first, 'First');
    if (firstError != null) {
      return ComparisonVerdict(canCompare: false, reason: firstError);
    }

    final secondError = _validationError(second, 'Second');
    if (secondError != null) {
      return ComparisonVerdict(canCompare: false, reason: secondError);
    }

    if (first.personId != second.personId) {
      return const ComparisonVerdict(
        canCompare: false,
        reason: 'Results belong to different people.',
      );
    }
    if (first.testNameStd != second.testNameStd) {
      return const ComparisonVerdict(
        canCompare: false,
        reason: 'Results are for different standardized tests.',
      );
    }
    if (first.unit != second.unit) {
      return const ComparisonVerdict(
        canCompare: false,
        reason: 'Results use different units.',
      );
    }
    if (first.stage != second.stage) {
      return const ComparisonVerdict(
        canCompare: false,
        reason: 'Results are from different stages.',
      );
    }

    return const ComparisonVerdict(
      canCompare: true,
      reason: 'Verified results match by person, test, unit, and stage.',
    );
  }

  String? _validationError(VerifiedResult result, String label) {
    if (result.id.trim().isEmpty) {
      return '$label result is missing an ID.';
    }
    if (result.personId.trim().isEmpty) {
      return '$label result is missing a person.';
    }
    if (result.testNameStd.trim().isEmpty) {
      return '$label result is missing a standardized test name.';
    }
    if (result.unit.trim().isEmpty) {
      return '$label result is missing a unit.';
    }
    if (result.stage.trim().isEmpty) {
      return '$label result is missing a stage.';
    }
    if (!result.value.isFinite) {
      return '$label result has an invalid numerical value.';
    }
    if (result.status != VerificationStatus.confirmed &&
        result.status != VerificationStatus.corrected) {
      return '$label result has not been verified.';
    }
    return null;
  }
}
