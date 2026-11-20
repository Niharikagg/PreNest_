import '../models/verified_result.dart';

abstract class SyncService {
  Future<void> syncVerifiedResults(List<VerifiedResult> results);
}
