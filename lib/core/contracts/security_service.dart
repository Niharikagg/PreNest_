abstract class SecurityService {
  Future<bool> authenticate();

  Future<List<int>> getDatabaseKey();

  void lock();

  bool get isUnlocked;
}
