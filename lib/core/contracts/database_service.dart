import '../models/verified_result.dart';

abstract class DatabaseService {
  Future<void> saveVerified(List<VerifiedResult> results);

  Future<List<VerifiedResult>> getByPerson(String personId);
}