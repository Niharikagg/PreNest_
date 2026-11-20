import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class PartnerProfile {
  final String id;
  final String name;
  final String role; // e.g., 'Her', 'Him'
  final String initials;
  final String bloodGroup;
  final int age;

  const PartnerProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.initials,
    this.bloodGroup = 'O+',
    this.age = 29,
  });
}

@immutable
class CoupleState {
  final String coupleId;
  final String coupleName;
  final String sharedGoal;
  final PartnerProfile primaryPartner;
  final PartnerProfile secondaryPartner;
  final String activePartnerId;

  const CoupleState({
    required this.coupleId,
    required this.coupleName,
    required this.sharedGoal,
    required this.primaryPartner,
    required this.secondaryPartner,
    required this.activePartnerId,
  });

  PartnerProfile get activePartner =>
      activePartnerId == primaryPartner.id ? primaryPartner : secondaryPartner;

  PartnerProfile get otherPartner =>
      activePartnerId == primaryPartner.id ? secondaryPartner : primaryPartner;

  List<PartnerProfile> get partners => [primaryPartner, secondaryPartner];

  CoupleState copyWith({
    String? coupleId,
    String? coupleName,
    String? sharedGoal,
    PartnerProfile? primaryPartner,
    PartnerProfile? secondaryPartner,
    String? activePartnerId,
  }) {
    return CoupleState(
      coupleId: coupleId ?? this.coupleId,
      coupleName: coupleName ?? this.coupleName,
      sharedGoal: sharedGoal ?? this.sharedGoal,
      primaryPartner: primaryPartner ?? this.primaryPartner,
      secondaryPartner: secondaryPartner ?? this.secondaryPartner,
      activePartnerId: activePartnerId ?? this.activePartnerId,
    );
  }
}

class CoupleNotifier extends Notifier<CoupleState> {
  @override
  CoupleState build() {
    const priya = PartnerProfile(
      id: 'partner_priya',
      name: 'Priya',
      role: 'Her',
      initials: 'P',
      bloodGroup: 'B+',
      age: 28,
    );
    const rohan = PartnerProfile(
      id: 'partner_rohan',
      name: 'Rohan',
      role: 'Him',
      initials: 'R',
      bloodGroup: 'A+',
      age: 30,
    );

    return const CoupleState(
      coupleId: 'couple_001',
      coupleName: 'Priya & Rohan',
      sharedGoal: 'Pre-conception preparation & healthy fertility journey',
      primaryPartner: priya,
      secondaryPartner: rohan,
      activePartnerId: 'partner_priya',
    );
  }

  void switchPartner(String partnerId) {
    if (state.activePartnerId != partnerId) {
      state = state.copyWith(activePartnerId: partnerId);
    }
  }

  void togglePartner() {
    final nextId = state.activePartnerId == state.primaryPartner.id
        ? state.secondaryPartner.id
        : state.primaryPartner.id;
    state = state.copyWith(activePartnerId: nextId);
  }
}

final coupleProvider = NotifierProvider<CoupleNotifier, CoupleState>(() {
  return CoupleNotifier();
});
