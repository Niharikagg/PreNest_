import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stage/stage.dart';

/// Categories of events appearing on the shared dot-coded calendar.
enum CalendarEventType {
  periodOrCycle,
  fertileWindow,
  ancVisit,
  labDue,
  uipVaccine,
  checkupReminder;

  String get displayName {
    switch (this) {
      case CalendarEventType.periodOrCycle:
        return 'Period & Cycle';
      case CalendarEventType.fertileWindow:
        return 'Fertile Window & Ovulation';
      case CalendarEventType.ancVisit:
        return 'ANC Doctor Visit';
      case CalendarEventType.labDue:
        return 'Diagnostic Lab & Scan Due';
      case CalendarEventType.uipVaccine:
        return 'Newborn UIP Vaccine';
      case CalendarEventType.checkupReminder:
        return 'Shared Checkup / Reminder';
    }
  }

  Color get color {
    switch (this) {
      case CalendarEventType.periodOrCycle:
        return const Color(0xFFE11D48); // Rose / Pink
      case CalendarEventType.fertileWindow:
        return const Color(0xFF0F766E); // Teal / Green
      case CalendarEventType.ancVisit:
        return const Color(0xFF7C3AED); // Purple
      case CalendarEventType.labDue:
        return const Color(0xFF4338CA); // Indigo
      case CalendarEventType.uipVaccine:
        return const Color(0xFFD97706); // Amber / Orange
      case CalendarEventType.checkupReminder:
        return const Color(0xFF0284C7); // Sky / Blue
    }
  }

  Color get containerColor {
    switch (this) {
      case CalendarEventType.periodOrCycle:
        return const Color(0xFFFFE4E6);
      case CalendarEventType.fertileWindow:
        return const Color(0xFFCCFBF1);
      case CalendarEventType.ancVisit:
        return const Color(0xFFF3E8FF);
      case CalendarEventType.labDue:
        return const Color(0xFFE0E7FF);
      case CalendarEventType.uipVaccine:
        return const Color(0xFFFEF3C7);
      case CalendarEventType.checkupReminder:
        return const Color(0xFFE0F2FE);
    }
  }

  IconData get icon {
    switch (this) {
      case CalendarEventType.periodOrCycle:
        return Icons.water_drop_rounded;
      case CalendarEventType.fertileWindow:
        return Icons.spa_rounded;
      case CalendarEventType.ancVisit:
        return Icons.event_note_rounded;
      case CalendarEventType.labDue:
        return Icons.biotech_rounded;
      case CalendarEventType.uipVaccine:
        return Icons.vaccines_rounded;
      case CalendarEventType.checkupReminder:
        return Icons.notifications_active_rounded;
    }
  }
}

/// Represents an individual event on the shared cross-mode calendar.
@immutable
class CalendarEvent {
  final String id;
  final DateTime date;
  final String title;
  final CalendarEventType category;
  final PregnancyStage stage;
  final String note;
  final bool isCompleted;
  final String createdBy; // e.g. 'Priya', 'Rohan', 'PreNest Guide'

  const CalendarEvent({
    required this.id,
    required this.date,
    required this.title,
    required this.category,
    required this.stage,
    this.note = '',
    this.isCompleted = false,
    this.createdBy = 'PreNest Guide',
  });

  CalendarEvent copyWith({
    String? id,
    DateTime? date,
    String? title,
    CalendarEventType? category,
    PregnancyStage? stage,
    String? note,
    bool? isCompleted,
    String? createdBy,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      category: category ?? this.category,
      stage: stage ?? this.stage,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

/// State for the shared calendar: list of events and optional active stage filter.
@immutable
class SharedCalendarState {
  final List<CalendarEvent> events;
  final PregnancyStage? filterStage; // null = show all modes
  final DateTime selectedDate;

  const SharedCalendarState({
    required this.events,
    this.filterStage,
    required this.selectedDate,
  });

  SharedCalendarState copyWith({
    List<CalendarEvent>? events,
    PregnancyStage? filterStage,
    bool clearFilterStage = false,
    DateTime? selectedDate,
  }) {
    return SharedCalendarState(
      events: events ?? this.events,
      filterStage: clearFilterStage ? null : (filterStage ?? this.filterStage),
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  /// Events matching the selected stage filter (or all if filter is null).
  List<CalendarEvent> get filteredEvents {
    if (filterStage == null) return events;
    return events.where((e) => e.stage == filterStage).toList();
  }

  /// Events occurring on a specific calendar day.
  List<CalendarEvent> eventsForDay(DateTime day) {
    return filteredEvents.where((e) {
      return e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day;
    }).toList();
  }

  /// Events occurring on the currently selected day.
  List<CalendarEvent> get selectedDayEvents => eventsForDay(selectedDate);
}

/// Riverpod Notifier managing the shared cross-mode calendar events.
class SharedCalendarNotifier extends Notifier<SharedCalendarState> {
  @override
  SharedCalendarState build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Pre-seed realistic cross-mode events spanning current and next month
    final preSeededEvents = [
      // --- Mode 1: Period Tracker / PCOS (Rose/Pink dots) ---
      CalendarEvent(
        id: 'cal_period_1',
        date: today.subtract(const Duration(days: 12)),
        title: 'Period Start (Flow Day 1)',
        category: CalendarEventType.periodOrCycle,
        stage: PregnancyStage.trying,
        note:
            'Medium flow logged. Hydration & warm herbal infusion recommended.',
        isCompleted: true,
      ),
      CalendarEvent(
        id: 'cal_period_2',
        date: today.subtract(const Duration(days: 11)),
        title: 'Period Flow Day 2',
        category: CalendarEventType.periodOrCycle,
        stage: PregnancyStage.trying,
        note: 'Flow tracking & gentle cramp relief.',
        isCompleted: true,
      ),
      CalendarEvent(
        id: 'cal_period_checkin',
        date: today.add(const Duration(days: 4)),
        title: 'Luteal Phase Wellness & Symptom Check',
        category: CalendarEventType.periodOrCycle,
        stage: PregnancyStage.trying,
        note: 'Check in on bloating, mood balance, and rest routines.',
        isCompleted: false,
      ),
      CalendarEvent(
        id: 'cal_period_next',
        date: today.add(const Duration(days: 16)),
        title: 'Estimated Next Cycle Window',
        category: CalendarEventType.periodOrCycle,
        stage: PregnancyStage.trying,
        note: 'Flexible window tracking active. Natural variations of 2–5 days are expected.',
        isCompleted: false,
      ),

      // --- Mode 2: Planning for Pregnancy (Teal/Green dots) ---
      CalendarEvent(
        id: 'cal_fertile_start',
        date: today.subtract(const Duration(days: 1)),
        title: 'Fertile Window Opens',
        category: CalendarEventType.fertileWindow,
        stage: PregnancyStage.plan,
        note: 'High conception probability window begins. Track cervical fluid signs.',
        isCompleted: true,
      ),
      CalendarEvent(
        id: 'cal_ovulation_peak',
        date: today.add(const Duration(days: 1)),
        title: 'Estimated Peak Ovulation Day',
        category: CalendarEventType.fertileWindow,
        stage: PregnancyStage.plan,
        note: 'Peak fertility indicator based on LH surge & cycle baseline.',
        isCompleted: false,
      ),
      CalendarEvent(
        id: 'cal_preconception_lab',
        date: today.add(const Duration(days: 8)),
        title: 'Preconception Lab Check: TSH & Ferritin',
        category: CalendarEventType.labDue,
        stage: PregnancyStage.plan,
        note: 'Fasting morning blood sample for thyroid, complete blood count & serum ferritin.',
        isCompleted: false,
      ),

      // --- Mode 3: Pregnant (Purple/Indigo dots) ---
      CalendarEvent(
        id: 'cal_anc_visit_2',
        date: today.add(const Duration(days: 6)),
        title: 'ANC Visit 2: TIFFA Scan & OGTT Test',
        category: CalendarEventType.ancVisit,
        stage: PregnancyStage.pregnancy,
        note: 'Mid-pregnancy anomaly ultrasound scan & oral glucose tolerance test. Fasting required for OGTT.',
        isCompleted: false,
      ),
      CalendarEvent(
        id: 'cal_scan_reminder',
        date: today.add(const Duration(days: 14)),
        title: 'Urine Albumin & BP Milestone Check',
        category: CalendarEventType.labDue,
        stage: PregnancyStage.pregnancy,
        note: 'Routine preeclampsia screening panel at neighborhood clinic or PHC.',
        isCompleted: false,
      ),
      CalendarEvent(
        id: 'cal_anc_visit_3',
        date: today.add(const Duration(days: 35)),
        title: 'ANC Visit 3: Third Trimester Growth Scan',
        category: CalendarEventType.ancVisit,
        stage: PregnancyStage.pregnancy,
        note: 'Fetal growth Doppler, amniotic fluid evaluation, and kick count routine review.',
        isCompleted: false,
      ),

      // --- Mode 4: Postpartum (Amber/Orange dots) ---
      CalendarEvent(
        id: 'cal_uip_birth',
        date: today.subtract(const Duration(days: 21)),
        title: 'UIP Birth Doses: BCG, OPV-0, Hep-B',
        category: CalendarEventType.uipVaccine,
        stage: PregnancyStage.postpartum,
        note: 'Administered at birth hospital. Recorded on MCP card.',
        isCompleted: true,
      ),
      CalendarEvent(
        id: 'cal_uip_6w',
        date: today.add(const Duration(days: 21)),
        title: 'Newborn UIP Vaccines (6 Weeks)',
        category: CalendarEventType.uipVaccine,
        stage: PregnancyStage.postpartum,
        note: 'Pentavalent-1, OPV-1, Rotavirus-1, fIPV-1, PCV-1 scheduled at pediatrician/PHC.',
        isCompleted: false,
      ),
      CalendarEvent(
        id: 'cal_postpartum_checkup',
        date: today.add(const Duration(days: 21)),
        title: 'Maternal 6-Week Postnatal Clinic Visit',
        category: CalendarEventType.ancVisit,
        stage: PregnancyStage.postpartum,
        note: 'Comprehensive maternal review: BP, hemoglobin, pelvic recovery & emotional wellness check.',
        isCompleted: false,
      ),
      CalendarEvent(
        id: 'cal_uip_10w',
        date: today.add(const Duration(days: 49)),
        title: 'Newborn UIP Vaccines (10 Weeks)',
        category: CalendarEventType.uipVaccine,
        stage: PregnancyStage.postpartum,
        note: 'Pentavalent-2, OPV-2, Rotavirus-2 due.',
        isCompleted: false,
      ),
    ];

    return SharedCalendarState(events: preSeededEvents, selectedDate: today);
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
    );
  }

  void setFilterStage(PregnancyStage? stage) {
    if (stage == null) {
      state = state.copyWith(clearFilterStage: true);
    } else {
      state = state.copyWith(filterStage: stage);
    }
  }

  void addEvent({
    required DateTime date,
    required String title,
    required CalendarEventType category,
    required PregnancyStage stage,
    String note = '',
    String createdBy = 'Partner',
  }) {
    final newEvent = CalendarEvent(
      id: 'cal_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime(date.year, date.month, date.day),
      title: title.trim(),
      category: category,
      stage: stage,
      note: note.trim(),
      isCompleted: false,
      createdBy: createdBy,
    );
    state = state.copyWith(events: [...state.events, newEvent]);
  }

  void toggleEventCompletion(String eventId) {
    state = state.copyWith(
      events: state.events.map((e) {
        if (e.id == eventId) {
          return e.copyWith(isCompleted: !e.isCompleted);
        }
        return e;
      }).toList(),
    );
  }

  void deleteEvent(String eventId) {
    state = state.copyWith(
      events: state.events.where((e) => e.id != eventId).toList(),
    );
  }
}

/// Global provider delivering the Shared Calendar state and actions.
final sharedCalendarProvider =
    NotifierProvider<SharedCalendarNotifier, SharedCalendarState>(
      SharedCalendarNotifier.new,
    );
