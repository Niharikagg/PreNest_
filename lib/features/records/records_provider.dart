import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/verified_result.dart';
import '../profile/profile_provider.dart';

/// Clean initial verified lab results list (empty on fresh install).
final initialVerifiedResults = <VerifiedResult>[];

class RecordsNotifier extends Notifier<List<VerifiedResult>> {
  @override
  List<VerifiedResult> build() {
    return List<VerifiedResult>.from(initialVerifiedResults);
  }

  void addVerifiedResults(List<VerifiedResult> newResults) {
    state = [...state, ...newResults];
  }
}

final recordsProvider = NotifierProvider<RecordsNotifier, List<VerifiedResult>>(
  () {
    return RecordsNotifier();
  },
);

final activePartnerRecordsProvider = Provider<List<VerifiedResult>>((ref) {
  final records = ref.watch(recordsProvider);
  final activePartnerId = ref.watch(coupleProvider).activePartnerId;
  return records.where((r) => r.personId == activePartnerId).toList();
});
