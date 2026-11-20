import 'package:flutter_riverpod/flutter_riverpod.dart';

class BirthPlanState {
  final String facilityName;
  final String facilityPhone;
  final String transportName;
  final String transportPhone;
  final String donorName;
  final String donorBloodGroup;
  final String donorPhone;
  final Map<String, bool> checklist;

  const BirthPlanState({
    required this.facilityName,
    required this.facilityPhone,
    required this.transportName,
    required this.transportPhone,
    required this.donorName,
    required this.donorBloodGroup,
    required this.donorPhone,
    required this.checklist,
  });

  BirthPlanState copyWith({
    String? facilityName,
    String? facilityPhone,
    String? transportName,
    String? transportPhone,
    String? donorName,
    String? donorBloodGroup,
    String? donorPhone,
    Map<String, bool>? checklist,
  }) {
    return BirthPlanState(
      facilityName: facilityName ?? this.facilityName,
      facilityPhone: facilityPhone ?? this.facilityPhone,
      transportName: transportName ?? this.transportName,
      transportPhone: transportPhone ?? this.transportPhone,
      donorName: donorName ?? this.donorName,
      donorBloodGroup: donorBloodGroup ?? this.donorBloodGroup,
      donorPhone: donorPhone ?? this.donorPhone,
      checklist: checklist ?? this.checklist,
    );
  }
}

class BirthPlanNotifier extends Notifier<BirthPlanState> {
  @override
  BirthPlanState build() {
    return const BirthPlanState(
      facilityName: 'District Women\'s Hospital & Maternity Center',
      facilityPhone: '+91 94123 45678',
      transportName: 'Ramesh Sharma (Dedicated Emergency Auto/Cab)',
      transportPhone: '108 / +91 98765 12345',
      donorName: 'Suresh Patel (Brother-in-law)',
      donorBloodGroup: 'B+ Positive',
      donorPhone: '+91 98111 22334',
      checklist: {
        'mcp_card': true,
        'aadhaar_id': true,
        'lab_reports': true,
        'hospital_bag': false,
        'emergency_funds': true,
      },
    );
  }

  void updateFacility({required String name, required String phone}) {
    state = state.copyWith(facilityName: name, facilityPhone: phone);
  }

  void updateTransport({required String name, required String phone}) {
    state = state.copyWith(transportName: name, transportPhone: phone);
  }

  void updateDonor({
    required String name,
    required String bloodGroup,
    required String phone,
  }) {
    state = state.copyWith(
      donorName: name,
      donorBloodGroup: bloodGroup,
      donorPhone: phone,
    );
  }

  void toggleChecklistItem(String key) {
    final current = state.checklist[key] ?? false;
    state = state.copyWith(
      checklist: {...state.checklist, key: !current},
    );
  }
}

final birthPlanProvider =
    NotifierProvider<BirthPlanNotifier, BirthPlanState>(() {
  return BirthPlanNotifier();
});
