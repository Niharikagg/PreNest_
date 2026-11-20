import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State representation for offline-first local cache and couple partner data sharing policies.
@immutable
class PrivacySyncState {
  final bool offlineFirstEnabled;
  final bool autoSyncCoupleData;

  // Explicit Partner Data-Sharing Controls
  // Defaults: Clinical & schedule data shared by default; personal/reflections private by default.
  final bool shareLabReports;
  final bool shareMedicineReminders;
  final bool shareTrendAnalysis;
  final bool sharePersonalReflections;
  final bool sharePrivateAiChats;
  final bool shareQuizPartnerHints;

  const PrivacySyncState({
    this.offlineFirstEnabled = true,
    this.autoSyncCoupleData = true,
    this.shareLabReports = true,
    this.shareMedicineReminders = true,
    this.shareTrendAnalysis = true,
    this.sharePersonalReflections = false,
    this.sharePrivateAiChats = false,
    this.shareQuizPartnerHints = false,
  });

  PrivacySyncState copyWith({
    bool? offlineFirstEnabled,
    bool? autoSyncCoupleData,
    bool? shareLabReports,
    bool? shareMedicineReminders,
    bool? shareTrendAnalysis,
    bool? sharePersonalReflections,
    bool? sharePrivateAiChats,
    bool? shareQuizPartnerHints,
  }) {
    return PrivacySyncState(
      offlineFirstEnabled: offlineFirstEnabled ?? this.offlineFirstEnabled,
      autoSyncCoupleData: autoSyncCoupleData ?? this.autoSyncCoupleData,
      shareLabReports: shareLabReports ?? this.shareLabReports,
      shareMedicineReminders:
          shareMedicineReminders ?? this.shareMedicineReminders,
      shareTrendAnalysis: shareTrendAnalysis ?? this.shareTrendAnalysis,
      sharePersonalReflections:
          sharePersonalReflections ?? this.sharePersonalReflections,
      sharePrivateAiChats: sharePrivateAiChats ?? this.sharePrivateAiChats,
      shareQuizPartnerHints:
          shareQuizPartnerHints ?? this.shareQuizPartnerHints,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacySyncState &&
          runtimeType == other.runtimeType &&
          offlineFirstEnabled == other.offlineFirstEnabled &&
          autoSyncCoupleData == other.autoSyncCoupleData &&
          shareLabReports == other.shareLabReports &&
          shareMedicineReminders == other.shareMedicineReminders &&
          shareTrendAnalysis == other.shareTrendAnalysis &&
          sharePersonalReflections == other.sharePersonalReflections &&
          sharePrivateAiChats == other.sharePrivateAiChats &&
          shareQuizPartnerHints == other.shareQuizPartnerHints;

  @override
  int get hashCode =>
      offlineFirstEnabled.hashCode ^
      autoSyncCoupleData.hashCode ^
      shareLabReports.hashCode ^
      shareMedicineReminders.hashCode ^
      shareTrendAnalysis.hashCode ^
      sharePersonalReflections.hashCode ^
      sharePrivateAiChats.hashCode ^
      shareQuizPartnerHints.hashCode;
}

/// Riverpod Notifier for managing offline sync and partner data-sharing boundaries.
class PrivacySyncNotifier extends Notifier<PrivacySyncState> {
  @override
  PrivacySyncState build() {
    return const PrivacySyncState();
  }

  /// Toggles offline-first local storage setting.
  void toggleOfflineFirst(bool enabled) {
    state = state.copyWith(offlineFirstEnabled: enabled);
  }

  /// Toggles partner auto-sync setting.
  void toggleAutoSync(bool enabled) {
    state = state.copyWith(autoSyncCoupleData: enabled);
  }

  /// Toggles sharing of lab reports & diagnostics with partner.
  void toggleShareLabReports(bool enabled) {
    state = state.copyWith(shareLabReports: enabled);
  }

  /// Toggles sharing of doctor medicine & supplement reminders.
  void toggleShareMedicineReminders(bool enabled) {
    state = state.copyWith(shareMedicineReminders: enabled);
  }

  /// Toggles sharing of trends, vitals, and cycle/stage analysis.
  void toggleShareTrendAnalysis(bool enabled) {
    state = state.copyWith(shareTrendAnalysis: enabled);
  }

  /// Toggles sharing of personal emotional reflections and journal notes.
  void toggleSharePersonalReflections(bool enabled) {
    state = state.copyWith(sharePersonalReflections: enabled);
  }

  /// Toggles sharing of private AI companion chats.
  void toggleSharePrivateAiChats(bool enabled) {
    state = state.copyWith(sharePrivateAiChats: enabled);
  }

  /// Toggles cross-partner hints from couple check-ins/quizzes.
  void toggleShareQuizPartnerHints(bool enabled) {
    state = state.copyWith(shareQuizPartnerHints: enabled);
  }

  /// Resets all partner data sharing preferences to recommended defaults.
  void resetSharingDefaults() {
    state = state.copyWith(
      shareLabReports: true,
      shareMedicineReminders: true,
      shareTrendAnalysis: true,
      sharePersonalReflections: false,
      sharePrivateAiChats: false,
      shareQuizPartnerHints: false,
    );
  }
}

/// Provider for privacy configuration and partner data-sharing rules.
final privacySyncProvider =
    NotifierProvider<PrivacySyncNotifier, PrivacySyncState>(
      PrivacySyncNotifier.new,
    );
