import '../models/trend_summary.dart';
import '../models/verified_result.dart';

abstract class TrendService {
  TrendSummary summarize(List<VerifiedResult> results);
}
