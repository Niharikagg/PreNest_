import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stage/stage.dart';
import '../stage/stage_provider.dart';

/// The 4 core PreNest journey modes.
enum PreNestMode {
  periodTracker,
  planningPregnancy,
  pregnant,
  postpartum;

  /// User-friendly title for the mode.
  String get title {
    switch (this) {
      case PreNestMode.periodTracker:
        return 'Period Tracker (PCOD/PCOS)';
      case PreNestMode.planningPregnancy:
        return 'Planning for Pregnancy';
      case PreNestMode.pregnant:
        return 'Pregnant';
      case PreNestMode.postpartum:
        return 'Postpartum';
    }
  }

  /// Concise badge label for cards and headers.
  String get badge {
    switch (this) {
      case PreNestMode.periodTracker:
        return 'Cycle & Hormones';
      case PreNestMode.planningPregnancy:
        return 'Pre-Conception';
      case PreNestMode.pregnant:
        return 'Trimester Care';
      case PreNestMode.postpartum:
        return 'Fourth Trimester';
    }
  }

  /// Descriptive summary of the clinical focus.
  String get subtitle {
    switch (this) {
      case PreNestMode.periodTracker:
        return 'Cycle, flow, symptoms, irregular-cycle mode (no stressful "late" alerts), and PCOD/PCOS hormonal support.';
      case PreNestMode.planningPregnancy:
        return 'Preconception prep & actively trying ("For Her" & "For Him" checklists, fertility & habit tracking).';
      case PreNestMode.pregnant:
        return 'Week-by-week journey, ANC planner, Danger-Sign Checker (108), Vitals, Kick Counter & Birth Plan.';
      case PreNestMode.postpartum:
        return 'Recovery checklist, EPDS mood check (Tele-MANAS 14416), newborn UIP vaccines & partner support.';
    }
  }

  /// Maps PreNestMode to the core PregnancyStage enum.
  PregnancyStage get stage {
    switch (this) {
      case PreNestMode.periodTracker:
        return PregnancyStage.trying;
      case PreNestMode.planningPregnancy:
        return PregnancyStage.plan;
      case PreNestMode.pregnant:
        return PregnancyStage.pregnancy;
      case PreNestMode.postpartum:
        return PregnancyStage.postpartum;
    }
  }

  /// Converts a PregnancyStage to the corresponding PreNestMode.
  static PreNestMode fromStage(PregnancyStage stage) {
    switch (stage) {
      case PregnancyStage.trying:
        return PreNestMode.periodTracker;
      case PregnancyStage.plan:
        return PreNestMode.planningPregnancy;
      case PregnancyStage.pregnancy:
        return PreNestMode.pregnant;
      case PregnancyStage.postpartum:
        return PreNestMode.postpartum;
    }
  }
}

/// State model managing mode selection, irregular cycle mode, and milestone notes.
@immutable
class ModeSelectionState {
  final PreNestMode? selectedMode;
  final bool irregularCycleMode;
  final String? timelineOrMilestoneNote;

  const ModeSelectionState({
    this.selectedMode,
    this.irregularCycleMode = true,
    this.timelineOrMilestoneNote,
  });

  /// Resolves the active mode safely, falling back to stage-derived mode.
  PreNestMode activeMode(PregnancyStage stageFallback) =>
      selectedMode ?? PreNestMode.fromStage(stageFallback);

  ModeSelectionState copyWith({
    PreNestMode? selectedMode,
    bool? irregularCycleMode,
    String? timelineOrMilestoneNote,
    bool clearNote = false,
  }) {
    return ModeSelectionState(
      selectedMode: selectedMode ?? this.selectedMode,
      irregularCycleMode: irregularCycleMode ?? this.irregularCycleMode,
      timelineOrMilestoneNote: clearNote
          ? null
          : (timelineOrMilestoneNote ?? this.timelineOrMilestoneNote),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModeSelectionState &&
          runtimeType == other.runtimeType &&
          selectedMode == other.selectedMode &&
          irregularCycleMode == other.irregularCycleMode &&
          timelineOrMilestoneNote == other.timelineOrMilestoneNote;

  @override
  int get hashCode =>
      selectedMode.hashCode ^
      irregularCycleMode.hashCode ^
      timelineOrMilestoneNote.hashCode;
}

/// Riverpod Notifier controlling the mode selection & metadata state.
class ModeSelectionNotifier extends Notifier<ModeSelectionState> {
  @override
  ModeSelectionState build() {
    return const ModeSelectionState();
  }

  /// Updates selectedMode and synchronizes the corresponding stage in stageProvider.
  void selectMode(PreNestMode mode) {
    state = state.copyWith(selectedMode: mode);
    try {
      ref.read(stageProvider.notifier).setStage(mode.stage);
    } catch (_) {
      // Continue gracefully if provider is mocked or running standalone
    }
  }

  /// Sets irregular cycle mode for PCOD/PCOS (avoids stressful 'late' alerts).
  void setIrregularCycleMode(bool enabled) {
    state = state.copyWith(irregularCycleMode: enabled);
  }

  /// Sets or clears milestone note (e.g. LMP date, trying vs preparing, due date, delivery note).
  void setMilestoneNote(String? note) {
    if (note == null || note.trim().isEmpty) {
      state = state.copyWith(clearNote: true);
    } else {
      state = state.copyWith(timelineOrMilestoneNote: note.trim());
    }
  }

  /// Resets state back to initial defaults.
  void resetModeSelection() {
    state = const ModeSelectionState();
  }
}

/// Riverpod provider for mode selection and mode-specific metadata.
final modeSelectionProvider =
    NotifierProvider<ModeSelectionNotifier, ModeSelectionState>(() {
      return ModeSelectionNotifier();
    });
