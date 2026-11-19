import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/verified_result.dart';
import '../profile/profile_provider.dart';

final initialVerifiedResults = <VerifiedResult>[
  // Priya's records (partner_priya)
  VerifiedResult(
    id: 'res_p1',
    personId: 'partner_priya',
    testNameStd: 'Hemoglobin',
    value: 11.8,
    unit: 'g/dL',
    date: DateTime(2026, 5, 10),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p2',
    personId: 'partner_priya',
    testNameStd: 'Hemoglobin',
    value: 12.2,
    unit: 'g/dL',
    date: DateTime(2026, 8, 15),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p3',
    personId: 'partner_priya',
    testNameStd: 'Hemoglobin',
    value: 12.8,
    unit: 'g/dL',
    date: DateTime(2026, 11, 10),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p4',
    personId: 'partner_priya',
    testNameStd: 'TSH',
    value: 3.4,
    unit: 'mIU/L',
    date: DateTime(2026, 5, 10),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p5',
    personId: 'partner_priya',
    testNameStd: 'TSH',
    value: 2.8,
    unit: 'mIU/L',
    date: DateTime(2026, 8, 15),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p6',
    personId: 'partner_priya',
    testNameStd: 'TSH',
    value: 2.1,
    unit: 'mIU/L',
    date: DateTime(2026, 11, 10),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p7',
    personId: 'partner_priya',
    testNameStd: 'Vitamin D',
    value: 16.0,
    unit: 'ng/mL',
    date: DateTime(2026, 5, 10),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p8',
    personId: 'partner_priya',
    testNameStd: 'Vitamin D',
    value: 19.5,
    unit: 'ng/mL',
    date: DateTime(2026, 8, 15),
    stage: 'plan',
    status: VerificationStatus.corrected,
  ),
  VerifiedResult(
    id: 'res_p9',
    personId: 'partner_priya',
    testNameStd: 'Vitamin D',
    value: 22.4,
    unit: 'ng/mL',
    date: DateTime(2026, 11, 10),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p10',
    personId: 'partner_priya',
    testNameStd: 'AMH',
    value: 2.9,
    unit: 'ng/mL',
    date: DateTime(2026, 5, 10),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p11',
    personId: 'partner_priya',
    testNameStd: 'AMH',
    value: 2.8,
    unit: 'ng/mL',
    date: DateTime(2026, 11, 10),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p12',
    personId: 'partner_priya',
    testNameStd: 'Fasting Blood Sugar',
    value: 95.0,
    unit: 'mg/dL',
    date: DateTime(2026, 8, 15),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p13',
    personId: 'partner_priya',
    testNameStd: 'Fasting Blood Sugar',
    value: 92.0,
    unit: 'mg/dL',
    date: DateTime(2026, 11, 10),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_p14',
    personId: 'partner_priya',
    testNameStd: 'Ferritin',
    value: 18.5,
    unit: 'ng/mL',
    date: DateTime(2026, 11, 10),
    stage: 'plan',
    status: VerificationStatus.corrected,
  ),

  // Rohan's records (partner_rohan)
  VerifiedResult(
    id: 'res_r1',
    personId: 'partner_rohan',
    testNameStd: 'Semen Analysis Motility',
    value: 42.0,
    unit: '%',
    date: DateTime(2026, 6, 12),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_r2',
    personId: 'partner_rohan',
    testNameStd: 'Semen Analysis Motility',
    value: 51.0,
    unit: '%',
    date: DateTime(2026, 10, 5),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_r3',
    personId: 'partner_rohan',
    testNameStd: 'Serum Testosterone',
    value: 425.0,
    unit: 'ng/dL',
    date: DateTime(2026, 6, 12),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_r4',
    personId: 'partner_rohan',
    testNameStd: 'Serum Testosterone',
    value: 490.0,
    unit: 'ng/dL',
    date: DateTime(2026, 10, 5),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_r5',
    personId: 'partner_rohan',
    testNameStd: 'Vitamin D',
    value: 23.0,
    unit: 'ng/mL',
    date: DateTime(2026, 6, 12),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_r6',
    personId: 'partner_rohan',
    testNameStd: 'Vitamin D',
    value: 34.0,
    unit: 'ng/mL',
    date: DateTime(2026, 10, 5),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
  VerifiedResult(
    id: 'res_r7',
    personId: 'partner_rohan',
    testNameStd: 'Fasting Blood Sugar',
    value: 88.0,
    unit: 'mg/dL',
    date: DateTime(2026, 10, 5),
    stage: 'plan',
    status: VerificationStatus.confirmed,
  ),
];

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
