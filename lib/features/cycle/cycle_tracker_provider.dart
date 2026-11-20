import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available symptom tracking tags for Cycle & PCOD/PCOS.
const List<String> kAvailablePcosSymptoms = [
  'Cramps',
  'Bloating',
  'Fatigue',
  'Acne',
  'Mood shifts',
  'Pelvic discomfort',
  'Hair thinning',
];

/// Flow intensity levels.
const List<String> kFlowLevels = ['Spotting', 'Light', 'Medium', 'Heavy'];

class CycleTrackerState {
  final DateTime lastPeriodStartDate;
  final int averageCycleLength;
  final bool irregularCycleMode;
  final Set<String> selectedSymptoms;
  final String flowIntensity;
  final String hormoneNotes;

  const CycleTrackerState({
    required this.lastPeriodStartDate,
    this.averageCycleLength = 28,
    this.irregularCycleMode = true,
    required this.selectedSymptoms,
    this.flowIntensity = 'Medium',
    this.hormoneNotes = '',
  });

  /// Days elapsed since the start of the last logged period.
  int get daysSinceLastPeriod {
    final now = DateTime.now();
    final difference = now.difference(lastPeriodStartDate).inDays;
    return difference >= 0 ? difference : 0;
  }

  /// Current cycle day (Day 1 being start date).
  int get currentCycleDay => daysSinceLastPeriod + 1;

  /// Friendly clinical reassurance message tailored to irregular vs regular tracking.
  String get cycleReassuranceMessage {
    if (irregularCycleMode) {
      return 'Flexible cycle window active. With PCOD/PCOS, cycle lengths vary naturally (often 32–45+ days). '
          'PreNest tracks your symptoms and patterns without stressful countdowns or "late" alerts.';
    }
    final remainingDays = averageCycleLength - daysSinceLastPeriod;
    if (remainingDays > 0) {
      return 'Approx. $remainingDays days until next expected cycle window based on your $averageCycleLength-day average.';
    } else {
      return 'Within your estimated cycle window. Note: variations of several days are completely normal.';
    }
  }

  CycleTrackerState copyWith({
    DateTime? lastPeriodStartDate,
    int? averageCycleLength,
    bool? irregularCycleMode,
    Set<String>? selectedSymptoms,
    String? flowIntensity,
    String? hormoneNotes,
  }) {
    return CycleTrackerState(
      lastPeriodStartDate: lastPeriodStartDate ?? this.lastPeriodStartDate,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      irregularCycleMode: irregularCycleMode ?? this.irregularCycleMode,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      hormoneNotes: hormoneNotes ?? this.hormoneNotes,
    );
  }
}

class CycleTrackerNotifier extends Notifier<CycleTrackerState> {
  @override
  CycleTrackerState build() {
    final now = DateTime.now();
    // Pre-seed with period start 12 days ago for a realistic active cycle day display
    return CycleTrackerState(
      lastPeriodStartDate: now.subtract(const Duration(days: 12)),
      averageCycleLength: 28,
      irregularCycleMode: true,
      selectedSymptoms: {'Bloating', 'Fatigue'},
      flowIntensity: 'Medium',
      hormoneNotes: 'TSH: 2.1 mIU/L, HbA1c: 5.4% (Reviewed at annual metabolic wellness visit)',
    );
  }

  void setLastPeriodStartDate(DateTime date) {
    state = state.copyWith(lastPeriodStartDate: date);
  }

  void setAverageCycleLength(int length) {
    if (length >= 21 && length <= 60) {
      state = state.copyWith(averageCycleLength: length);
    }
  }

  void setIrregularCycleMode(bool enabled) {
    state = state.copyWith(irregularCycleMode: enabled);
  }

  void toggleSymptom(String symptom) {
    final updated = Set<String>.from(state.selectedSymptoms);
    if (updated.contains(symptom)) {
      updated.remove(symptom);
    } else {
      updated.add(symptom);
    }
    state = state.copyWith(selectedSymptoms: updated);
  }

  void clearSymptoms() {
    state = state.copyWith(selectedSymptoms: <String>{});
  }

  void setFlowIntensity(String flow) {
    state = state.copyWith(flowIntensity: flow);
  }

  void setHormoneNotes(String notes) {
    state = state.copyWith(hormoneNotes: notes.trim());
  }
}

final cycleTrackerProvider =
    NotifierProvider<CycleTrackerNotifier, CycleTrackerState>(() {
      return CycleTrackerNotifier();
    });
