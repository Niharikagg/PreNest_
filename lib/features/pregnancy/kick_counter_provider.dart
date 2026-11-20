import 'package:flutter_riverpod/flutter_riverpod.dart';

class KickSession {
  final String id;
  final DateTime date;
  final Duration duration;
  final int count;

  const KickSession({
    required this.id,
    required this.date,
    required this.duration,
    required this.count,
  });
}

class KickCounterState {
  final bool isActive;
  final DateTime? startTime;
  final int kickCount;
  final List<DateTime> kickTimestamps;
  final List<KickSession> sessions;

  const KickCounterState({
    required this.isActive,
    this.startTime,
    required this.kickCount,
    required this.kickTimestamps,
    required this.sessions,
  });

  KickCounterState copyWith({
    bool? isActive,
    DateTime? Function()? startTime,
    int? kickCount,
    List<DateTime>? kickTimestamps,
    List<KickSession>? sessions,
  }) {
    return KickCounterState(
      isActive: isActive ?? this.isActive,
      startTime: startTime != null ? startTime() : this.startTime,
      kickCount: kickCount ?? this.kickCount,
      kickTimestamps: kickTimestamps ?? this.kickTimestamps,
      sessions: sessions ?? this.sessions,
    );
  }
}

class KickCounterNotifier extends Notifier<KickCounterState> {
  @override
  KickCounterState build() {
    final now = DateTime.now();
    return KickCounterState(
      isActive: false,
      startTime: null,
      kickCount: 0,
      kickTimestamps: const [],
      sessions: [
        KickSession(
          id: 'kick_session_002',
          date: now.subtract(const Duration(days: 1, hours: 3)),
          duration: const Duration(minutes: 34),
          count: 10,
        ),
        KickSession(
          id: 'kick_session_001',
          date: now.subtract(const Duration(days: 2, hours: 6)),
          duration: const Duration(minutes: 42),
          count: 10,
        ),
      ],
    );
  }

  void startSession() {
    state = state.copyWith(
      isActive: true,
      startTime: () => DateTime.now(),
      kickCount: 0,
      kickTimestamps: [],
    );
  }

  void recordKick() {
    if (!state.isActive) {
      // Auto-start if tapped while inactive
      final now = DateTime.now();
      state = state.copyWith(
        isActive: true,
        startTime: () => now,
        kickCount: 1,
        kickTimestamps: [now],
      );
      return;
    }

    final now = DateTime.now();
    final updated = [...state.kickTimestamps, now];
    state = state.copyWith(
      kickCount: state.kickCount + 1,
      kickTimestamps: updated,
    );
  }

  void resetSession() {
    state = state.copyWith(
      isActive: false,
      startTime: () => null,
      kickCount: 0,
      kickTimestamps: [],
    );
  }

  void saveSession() {
    if (state.kickCount == 0) return;

    final start = state.startTime ?? DateTime.now();
    final duration = DateTime.now().difference(start);
    // Ensure at least a few seconds duration
    final safeDuration = duration.inSeconds < 1 ? const Duration(seconds: 1) : duration;

    final newSession = KickSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      date: start,
      duration: safeDuration,
      count: state.kickCount,
    );

    state = state.copyWith(
      isActive: false,
      startTime: () => null,
      kickCount: 0,
      kickTimestamps: [],
      sessions: [newSession, ...state.sessions],
    );
  }

  void removeSession(String id) {
    state = state.copyWith(
      sessions: state.sessions.where((s) => s.id != id).toList(),
    );
  }
}

final kickCounterProvider =
    NotifierProvider<KickCounterNotifier, KickCounterState>(() {
  return KickCounterNotifier();
});
