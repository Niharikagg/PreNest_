import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single contraction log entry
class ContractionEntry {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final int? intervalSeconds; // Time since previous contraction started
  final String intensity; // Mild, Moderate, Strong

  const ContractionEntry({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    this.intervalSeconds,
    required this.intensity,
  });
}

/// State for the contraction timer
class ContractionTimerState {
  final bool isTiming;
  final DateTime? currentStartTime;
  final String selectedIntensity;
  final List<ContractionEntry> history;

  const ContractionTimerState({
    required this.isTiming,
    this.currentStartTime,
    required this.selectedIntensity,
    required this.history,
  });

  ContractionTimerState copyWith({
    bool? isTiming,
    DateTime? Function()? currentStartTime,
    String? selectedIntensity,
    List<ContractionEntry>? history,
  }) {
    return ContractionTimerState(
      isTiming: isTiming ?? this.isTiming,
      currentStartTime: currentStartTime != null
          ? currentStartTime()
          : this.currentStartTime,
      selectedIntensity: selectedIntensity ?? this.selectedIntensity,
      history: history ?? this.history,
    );
  }

  /// Total number of logged contractions
  int get totalLogged => history.length;

  /// Average duration of contractions in seconds
  double get avgDurationSeconds {
    if (history.isEmpty) return 0.0;
    final total = history.fold<int>(0, (sum, e) => sum + e.durationSeconds);
    return total / history.length;
  }

  /// Average interval between contractions in seconds
  double get avgIntervalSeconds {
    final validIntervals = history
        .where((e) => e.intervalSeconds != null && e.intervalSeconds! > 0)
        .map((e) => e.intervalSeconds!)
        .toList();

    if (validIntervals.isEmpty) return 0.0;
    final total = validIntervals.fold<int>(0, (sum, val) => sum + val);
    return total / validIntervals.length;
  }
}

/// Notifier managing contraction timing sessions and history
class ContractionTimerNotifier extends Notifier<ContractionTimerState> {
  @override
  ContractionTimerState build() {
    final now = DateTime.now();

    // Pre-seed 3 realistic sample entries so demo summaries & list look populated
    // Sample 3 (earliest): 28 mins ago, 48s duration
    // Sample 2: 21 mins ago (~7 min interval), 55s duration
    // Sample 1 (latest): 15 mins ago (~6 min interval), 58s duration
    final start3 = now.subtract(const Duration(minutes: 28));
    final end3 = start3.add(const Duration(seconds: 48));

    final start2 = now.subtract(const Duration(minutes: 21));
    final end2 = start2.add(const Duration(seconds: 55));
    final interval2 = start2.difference(start3).inSeconds;

    final start1 = now.subtract(const Duration(minutes: 15));
    final end1 = start1.add(const Duration(seconds: 58));
    final interval1 = start1.difference(start2).inSeconds;

    final sampleEntries = [
      ContractionEntry(
        id: 'contraction_sample_003',
        startTime: start1,
        endTime: end1,
        durationSeconds: 58,
        intervalSeconds: interval1,
        intensity: 'Moderate',
      ),
      ContractionEntry(
        id: 'contraction_sample_002',
        startTime: start2,
        endTime: end2,
        durationSeconds: 55,
        intervalSeconds: interval2,
        intensity: 'Moderate',
      ),
      ContractionEntry(
        id: 'contraction_sample_001',
        startTime: start3,
        endTime: end3,
        durationSeconds: 48,
        intervalSeconds: null, // First contraction in sequence
        intensity: 'Mild',
      ),
    ];

    return ContractionTimerState(
      isTiming: false,
      currentStartTime: null,
      selectedIntensity: 'Moderate',
      history: sampleEntries,
    );
  }

  /// Start a new contraction timing session
  void startContraction() {
    state = state.copyWith(
      isTiming: true,
      currentStartTime: () => DateTime.now(),
    );
  }

  /// Stop the active contraction, compute duration and interval, and append to history
  void stopContraction() {
    if (!state.isTiming || state.currentStartTime == null) return;

    final now = DateTime.now();
    final start = state.currentStartTime!;
    final duration = now.difference(start).inSeconds;
    final safeDuration = duration < 1 ? 1 : duration;

    // Interval is measured from the previous contraction's start time to this contraction's start time
    int? interval;
    if (state.history.isNotEmpty) {
      interval = start.difference(state.history.first.startTime).inSeconds;
      if (interval < 0) interval = null;
    }

    final newEntry = ContractionEntry(
      id: 'contraction_${DateTime.now().millisecondsSinceEpoch}',
      startTime: start,
      endTime: now,
      durationSeconds: safeDuration,
      intervalSeconds: interval,
      intensity: state.selectedIntensity,
    );

    state = state.copyWith(
      isTiming: false,
      currentStartTime: () => null,
      history: [newEntry, ...state.history],
    );
  }

  /// Update the selected intensity chip (Mild, Moderate, Strong)
  void setIntensity(String intensity) {
    state = state.copyWith(selectedIntensity: intensity);
  }

  /// Delete a single entry from history
  void deleteEntry(String id) {
    state = state.copyWith(
      history: state.history.where((entry) => entry.id != id).toList(),
    );
  }

  /// Clear all logged contractions
  void clearHistory() {
    state = state.copyWith(history: []);
  }
}

/// Global provider for the contraction timer
final contractionTimerProvider =
    NotifierProvider<ContractionTimerNotifier, ContractionTimerState>(() {
      return ContractionTimerNotifier();
    });
