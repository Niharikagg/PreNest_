import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State representation for app security, vault lock, and offline/cloud sync.
@immutable
class VaultLockState {
  final bool appLockEnabled;
  final String pinCode;
  final bool isLocked;
  final bool offlineFirstEnabled;
  final bool autoSyncCoupleData;
  final String? errorMessage;
  final DateTime? lastLockedAt;
  final int failedPinAttempts;

  const VaultLockState({
    this.appLockEnabled = false,
    this.pinCode = '1234',
    this.isLocked = false,
    this.offlineFirstEnabled = true,
    this.autoSyncCoupleData = true,
    this.errorMessage,
    this.lastLockedAt,
    this.failedPinAttempts = 0,
  });

  VaultLockState copyWith({
    bool? appLockEnabled,
    String? pinCode,
    bool? isLocked,
    bool? offlineFirstEnabled,
    bool? autoSyncCoupleData,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastLockedAt,
    int? failedPinAttempts,
  }) {
    return VaultLockState(
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      pinCode: pinCode ?? this.pinCode,
      isLocked: isLocked ?? this.isLocked,
      offlineFirstEnabled: offlineFirstEnabled ?? this.offlineFirstEnabled,
      autoSyncCoupleData: autoSyncCoupleData ?? this.autoSyncCoupleData,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastLockedAt: lastLockedAt ?? this.lastLockedAt,
      failedPinAttempts: failedPinAttempts ?? this.failedPinAttempts,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultLockState &&
          runtimeType == other.runtimeType &&
          appLockEnabled == other.appLockEnabled &&
          pinCode == other.pinCode &&
          isLocked == other.isLocked &&
          offlineFirstEnabled == other.offlineFirstEnabled &&
          autoSyncCoupleData == other.autoSyncCoupleData &&
          errorMessage == other.errorMessage &&
          lastLockedAt == other.lastLockedAt &&
          failedPinAttempts == other.failedPinAttempts;

  @override
  int get hashCode =>
      appLockEnabled.hashCode ^
      pinCode.hashCode ^
      isLocked.hashCode ^
      offlineFirstEnabled.hashCode ^
      autoSyncCoupleData.hashCode ^
      errorMessage.hashCode ^
      lastLockedAt.hashCode ^
      failedPinAttempts.hashCode;
}

/// Riverpod Notifier for managing App Lock, PIN verification, and offline sync preferences.
class VaultLockNotifier extends Notifier<VaultLockState> {
  @override
  VaultLockState build() {
    return const VaultLockState();
  }

  /// Toggles whether app lock protection is enabled.
  void toggleAppLock(bool enabled) {
    state = state.copyWith(
      appLockEnabled: enabled,
      isLocked: enabled ? state.isLocked : false,
      clearError: true,
    );
  }

  /// Verifies entered PIN against stored code and unlocks if correct.
  bool verifyAndUnlock(String enteredPin) {
    if (enteredPin.trim() == state.pinCode.trim()) {
      state = state.copyWith(
        isLocked: false,
        failedPinAttempts: 0,
        clearError: true,
      );
      return true;
    } else {
      state = state.copyWith(
        failedPinAttempts: state.failedPinAttempts + 1,
        errorMessage: 'Incorrect PIN. Please try again (Default: 1234).',
      );
      return false;
    }
  }

  /// Locks the app immediately.
  void lockNow() {
    state = state.copyWith(
      isLocked: true,
      lastLockedAt: DateTime.now(),
      clearError: true,
    );
  }

  /// Updates PIN code after validating current PIN.
  bool updatePin({required String currentPin, required String newPin}) {
    if (currentPin.trim() != state.pinCode.trim()) {
      state = state.copyWith(errorMessage: 'Current PIN does not match.');
      return false;
    }
    if (newPin.trim().length != 4 || int.tryParse(newPin.trim()) == null) {
      state = state.copyWith(
        errorMessage: 'New PIN must be exactly 4 numeric digits.',
      );
      return false;
    }

    state = state.copyWith(
      pinCode: newPin.trim(),
      clearError: true,
      failedPinAttempts: 0,
    );
    return true;
  }

  /// Direct helper to reset PIN to default '1234' for testing.
  void resetPinToDefault() {
    state = state.copyWith(
      pinCode: '1234',
      clearError: true,
      failedPinAttempts: 0,
    );
  }

  /// Toggles offline-first local storage setting.
  void toggleOfflineFirst(bool enabled) {
    state = state.copyWith(offlineFirstEnabled: enabled);
  }

  /// Toggles partner auto-sync setting.
  void toggleAutoSync(bool enabled) {
    state = state.copyWith(autoSyncCoupleData: enabled);
  }

  /// Clears any transient error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for Vault Lock and security configuration.
final vaultLockProvider = NotifierProvider<VaultLockNotifier, VaultLockState>(
  () {
    return VaultLockNotifier();
  },
);
