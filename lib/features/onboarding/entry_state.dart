import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/profile_provider.dart';

/// Choice made by the user at the onboarding entry step.
enum SetupChoice { forMyself, partnerCode }

/// State model representing the user's entry choice and pairing status.
@immutable
class EntryState {
  final SetupChoice? choice;
  final String? partnerCode;
  final bool isPaired;
  final String? errorMessage;

  const EntryState({
    this.choice,
    this.partnerCode,
    this.isPaired = false,
    this.errorMessage,
  });

  EntryState copyWith({
    SetupChoice? choice,
    String? partnerCode,
    bool? isPaired,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EntryState(
      choice: choice ?? this.choice,
      partnerCode: partnerCode ?? this.partnerCode,
      isPaired: isPaired ?? this.isPaired,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      choice.hashCode ^
      partnerCode.hashCode ^
      isPaired.hashCode ^
      errorMessage.hashCode;
}

/// Riverpod Notifier controlling the onboarding entry & pairing flow.
class EntryNotifier extends Notifier<EntryState> {
  @override
  EntryState build() {
    return const EntryState();
  }

  /// Sets choice to 'for myself' and clears partner pairing.
  void selectForMyself() {
    state = const EntryState(
      choice: SetupChoice.forMyself,
      partnerCode: null,
      isPaired: false,
      errorMessage: null,
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

    state = EntryState(
      choice: SetupChoice.partnerCode,
      partnerCode: cleanCode,
      isPaired: true,
      errorMessage: null,
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

  /// Resets choice and pairing state back to defaults.
  void resetChoice() {
    state = const EntryState();
  }
}

/// Riverpod provider for onboarding entry state.
final entryProvider = NotifierProvider<EntryNotifier, EntryState>(() {
  return EntryNotifier();
});
