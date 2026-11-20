import '../models/comparison_verdict.dart';
import '../models/verified_result.dart';

abstract class ValidityEngine {
  ComparisonVerdict check(VerifiedResult first, VerifiedResult second);
}
