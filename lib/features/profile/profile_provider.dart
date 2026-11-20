import 'dart:math';

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
    this.bloodGroup = '',
    this.age = 0,
  });

  PartnerProfile copyWith({
    String? id,
    String? name,
    String? role,
    String? initials,
    String? bloodGroup,
    int? age,
  }) {
    return PartnerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      initials: initials ?? this.initials,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      age: age ?? this.age,
    );
  }
}

@immutable
class CoupleState {
  final String coupleId;
  final String coupleName;
  final String sharedGoal;
  final PartnerProfile primaryPartner;
  final PartnerProfile secondaryPartner;
  final String activePartnerId;
  final bool isOnboardingComplete;
  final String? partnerInviteCode;
  final DateTime? keyDate;

  const CoupleState({
    this.coupleId = '',
    this.coupleName = '',
    this.sharedGoal = '',
    this.primaryPartner = const PartnerProfile(
      id: 'primary_user',
      name: '',
      role: 'Her',
      initials: '',
    ),
    this.secondaryPartner = const PartnerProfile(
      id: 'secondary_user',
      name: '',
      role: 'Him',
      initials: '',
    ),
    this.activePartnerId = 'primary_user',
    this.isOnboardingComplete = false,
    this.partnerInviteCode,
    this.keyDate,
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
    bool? isOnboardingComplete,
    String? partnerInviteCode,
    DateTime? keyDate,
    bool clearKeyDate = false,
  }) {
    return CoupleState(
      coupleId: coupleId ?? this.coupleId,
      coupleName: coupleName ?? this.coupleName,
      sharedGoal: sharedGoal ?? this.sharedGoal,
      primaryPartner: primaryPartner ?? this.primaryPartner,
      secondaryPartner: secondaryPartner ?? this.secondaryPartner,
      activePartnerId: activePartnerId ?? this.activePartnerId,
      isOnboardingComplete:
          isOnboardingComplete ?? this.isOnboardingComplete,
      partnerInviteCode: partnerInviteCode ?? this.partnerInviteCode,
      keyDate: clearKeyDate ? null : (keyDate ?? this.keyDate),
    );
  }
}

class CoupleNotifier extends Notifier<CoupleState> {
  @override
  CoupleState build() {
    return const CoupleState();
  }

  void completeOnboardingForSelf({
    required String name,
    required String partnerCode,
    DateTime? keyDate,
  }) {
    final cleanName = name.trim();
    final initials = computeInitials(cleanName);
    state = state.copyWith(
      coupleId: 'couple_${DateTime.now().millisecondsSinceEpoch}',
      coupleName: cleanName,
      sharedGoal: 'Healthy fertility & reproductive health journey',
      primaryPartner: PartnerProfile(
        id: 'primary_user',
        name: cleanName,
        role: 'Her',
        initials: initials,
      ),
      activePartnerId: 'primary_user',
      isOnboardingComplete: true,
      partnerInviteCode: partnerCode,
      keyDate: keyDate,
    );
  }

  void completeOnboardingWithPartnerCode({
    required String partnerName,
    required String partnerCode,
  }) {
    final cleanName = partnerName.trim();
    final initials = computeInitials(cleanName);
    state = state.copyWith(
      coupleId: 'couple_${partnerCode.toLowerCase()}',
      coupleName: '$cleanName & Partner',
      sharedGoal: 'Shared couple care & partner support',
      secondaryPartner: PartnerProfile(
        id: 'secondary_user',
        name: cleanName,
        role: 'Him',
        initials: initials,
      ),
      activePartnerId: 'secondary_user',
      isOnboardingComplete: true,
      partnerInviteCode: partnerCode,
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

  void setPartnerInviteCode(String code) {
    state = state.copyWith(partnerInviteCode: code);
  }

  static String computeInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : 'U';
  }

  static String generate6CharPartnerCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(
      6,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }
}

final coupleProvider = NotifierProvider<CoupleNotifier, CoupleState>(() {
  return CoupleNotifier();
});
