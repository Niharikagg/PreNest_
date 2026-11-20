import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/profile_provider.dart';

/// Choice made by the user at the onboarding entry step.
enum SetupChoice { forMyself, partnerCode }

/// Model capturing partner-specific private intake answers.
@immutable
class PartnerIntakeData {
  final bool ageConfirmed;
  final String? ageRange;
  final List<String> goals;
  final Map<String, bool> lifestyleHabits;
  final List<String> feelings;
  final DateTime? completedAt;

  const PartnerIntakeData({
    this.ageConfirmed = false,
    this.ageRange,
    this.goals = const [],
    this.lifestyleHabits = const {
      'regularSleep': true,
      'regularExercise': false,
      'moderateCaffeine': true,
      'substanceAvoidance': true,
    },
    this.feelings = const [],
    this.completedAt,
  });

  PartnerIntakeData copyWith({
    bool? ageConfirmed,
    String? ageRange,
    List<String>? goals,
    Map<String, bool>? lifestyleHabits,
    List<String>? feelings,
    DateTime? completedAt,
  }) {
    return PartnerIntakeData(
      ageConfirmed: ageConfirmed ?? this.ageConfirmed,
      ageRange: ageRange ?? this.ageRange,
      goals: goals ?? this.goals,
      lifestyleHabits: lifestyleHabits ?? this.lifestyleHabits,
      feelings: feelings ?? this.feelings,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartnerIntakeData &&
          runtimeType == other.runtimeType &&
          ageConfirmed == other.ageConfirmed &&
          ageRange == other.ageRange &&
          listEquals(goals, other.goals) &&
          mapEquals(lifestyleHabits, other.lifestyleHabits) &&
          listEquals(feelings, other.feelings) &&
          completedAt == other.completedAt;

  @override
  int get hashCode =>
      ageConfirmed.hashCode ^
      ageRange.hashCode ^
      goals.hashCode ^
      lifestyleHabits.hashCode ^
      feelings.hashCode ^
      completedAt.hashCode;
}

/// State model representing the user's entry choice, pairing status,
/// active invite code, and private partner intake data.
@immutable
class EntryState {
  final SetupChoice? choice;
  final String? partnerCode;
  final bool isPaired;
  final String? errorMessage;
  final String? generatedInviteCode;
  final bool inviteActive;
  final PartnerIntakeData? partnerIntake;

  const EntryState({
    this.choice,
    this.partnerCode,
    this.isPaired = false,
    this.errorMessage,
    this.generatedInviteCode,
    this.inviteActive = true,
    this.partnerIntake,
  });

  EntryState copyWith({
    SetupChoice? choice,
    String? partnerCode,
    bool? isPaired,
    String? errorMessage,
    bool clearError = false,
    String? generatedInviteCode,
    bool? inviteActive,
    PartnerIntakeData? partnerIntake,
    bool clearGeneratedCode = false,
    bool clearPartnerCode = false,
    bool clearPartnerIntake = false,
  }) {
    return EntryState(
      choice: choice ?? this.choice,
      partnerCode: clearPartnerCode ? null : (partnerCode ?? this.partnerCode),
      isPaired: isPaired ?? this.isPaired,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      generatedInviteCode: clearGeneratedCode
          ? null
          : (generatedInviteCode ?? this.generatedInviteCode),
      inviteActive: inviteActive ?? this.inviteActive,
      partnerIntake: clearPartnerIntake
          ? null
          : (partnerIntake ?? this.partnerIntake),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryState &&
          runtimeType == other.runtimeType &&
          choice == other.choice &&
          partnerCode == other.partnerCode &&
          isPaired == other.isPaired &&
          errorMessage == other.errorMessage &&
          generatedInviteCode == other.generatedInviteCode &&
          inviteActive == other.inviteActive &&
          partnerIntake == other.partnerIntake;

  @override
  int get hashCode =>
      choice.hashCode ^
      partnerCode.hashCode ^
      isPaired.hashCode ^
      errorMessage.hashCode ^
      generatedInviteCode.hashCode ^
      inviteActive.hashCode ^
      partnerIntake.hashCode;
}

/// Riverpod Notifier controlling the onboarding entry & pairing flow.
class EntryNotifier extends Notifier<EntryState> {
  @override
  EntryState build() {
    return const EntryState();
  }

  /// Sets choice to 'for myself' and keeps invite active.
  void selectForMyself() {
    state = state.copyWith(
      choice: SetupChoice.forMyself,
      clearPartnerCode: true,
      isPaired: false,
      clearError: true,
    );
  }

  /// Generates a fresh 6-character alphanumeric code and sets inviteActive = true.
  void generateInviteCode() {
    final newCode = CoupleNotifier.generate6CharPartnerCode();

    state = state.copyWith(
      generatedInviteCode: newCode,
      inviteActive: true,
      clearError: true,
    );

    try {
      ref.read(coupleProvider.notifier).setPartnerInviteCode(newCode);
    } catch (_) {}
  }

  /// Clears generatedInviteCode / partnerCode, sets inviteActive = false, isPaired = false.
  void revokePairingCode() {
    state = state.copyWith(
      clearGeneratedCode: true,
      clearPartnerCode: true,
      inviteActive: false,
      isPaired: false,
      clearError: true,
    );
  }

  /// Validates a 6-character partner code, trims & uppercases it,
  /// updates state to paired, and syncs the active partner profile.
  bool pairWithCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.length != 6) {
      state = state.copyWith(
        errorMessage: 'Partner code must be exactly 6 characters.',
      );
      return false;
    }

    state = state.copyWith(
      choice: SetupChoice.partnerCode,
      partnerCode: cleanCode,
      isPaired: true,
      clearError: true,
    );

    // Sync active partner profile if applicable
    try {
      final coupleState = ref.read(coupleProvider);
      // Switch active partner to the secondary partner (e.g. Him connecting to Her profile)
      if (coupleState.secondaryPartner.id.isNotEmpty) {
        ref
            .read(coupleProvider.notifier)
            .switchPartner(coupleState.secondaryPartner.id);
      }
    } catch (_) {
      // Continue gracefully if provider is mocked or running standalone
    }

    return true;
  }

  /// Saves the partner's completed private intake data.
  void savePartnerIntake(PartnerIntakeData intake) {
    state = state.copyWith(
      partnerIntake: intake.copyWith(completedAt: DateTime.now()),
    );
  }

  /// Resets choice and pairing state back to defaults.
  void resetChoice() {
    state = const EntryState();
  }
}

/// Riverpod provider for onboarding entry state.
final entryProvider = NotifierProvider<EntryNotifier, EntryState>(() {
  return EntryNotifier();
});

/// Dedicated provider for partner intake data.
final partnerIntakeProvider = Provider<PartnerIntakeData?>((ref) {
  return ref.watch(entryProvider).partnerIntake;
});
