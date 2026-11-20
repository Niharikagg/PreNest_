import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single Antenatal Care (ANC) scheduled visit model
class AncVisit {
  final String id;
  final int visitNumber;
  final int trimester;
  final String title;
  final String weekRange;
  final String description;
  final List<String> recommendedChecks;
  final bool isCompleted;
  final DateTime? completedDate;
  final String doctorNotes;

  const AncVisit({
    required this.id,
    required this.visitNumber,
    required this.trimester,
    required this.title,
    required this.weekRange,
    required this.description,
    required this.recommendedChecks,
    this.isCompleted = false,
    this.completedDate,
    this.doctorNotes = '',
  });

  AncVisit copyWith({
    String? id,
    int? visitNumber,
    int? trimester,
    String? title,
    String? weekRange,
    String? description,
    List<String>? recommendedChecks,
    bool? isCompleted,
    DateTime? Function()? completedDate,
    String? doctorNotes,
  }) {
    return AncVisit(
      id: id ?? this.id,
      visitNumber: visitNumber ?? this.visitNumber,
      trimester: trimester ?? this.trimester,
      title: title ?? this.title,
      weekRange: weekRange ?? this.weekRange,
      description: description ?? this.description,
      recommendedChecks: recommendedChecks ?? this.recommendedChecks,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate != null
          ? completedDate()
          : this.completedDate,
      doctorNotes: doctorNotes ?? this.doctorNotes,
    );
  }
}

/// State tracking the structured ANC visits and daily micronutrient milestones
class AncPlannerState {
  final List<AncVisit> visits;
  final bool ifaTakenToday;
  final bool calciumTakenToday;
  final DateTime? ifaLoggedAt;
  final DateTime? calciumLoggedAt;

  const AncPlannerState({
    required this.visits,
    this.ifaTakenToday = false,
    this.calciumTakenToday = false,
    this.ifaLoggedAt,
    this.calciumLoggedAt,
  });

  AncPlannerState copyWith({
    List<AncVisit>? visits,
    bool? ifaTakenToday,
    bool? calciumTakenToday,
    DateTime? Function()? ifaLoggedAt,
    DateTime? Function()? calciumLoggedAt,
  }) {
    return AncPlannerState(
      visits: visits ?? this.visits,
      ifaTakenToday: ifaTakenToday ?? this.ifaTakenToday,
      calciumTakenToday: calciumTakenToday ?? this.calciumTakenToday,
      ifaLoggedAt: ifaLoggedAt != null ? ifaLoggedAt() : this.ifaLoggedAt,
      calciumLoggedAt: calciumLoggedAt != null
          ? calciumLoggedAt()
          : this.calciumLoggedAt,
    );
  }

  int get completedVisitsCount => visits.where((v) => v.isCompleted).length;
  int get totalVisitsCount => visits.length;

  double get progressFraction =>
      totalVisitsCount > 0 ? completedVisitsCount / totalVisitsCount : 0.0;
}

/// Notifier managing ANC visits and daily IFA / Calcium reminders
class AncPlannerNotifier extends Notifier<AncPlannerState> {
  @override
  AncPlannerState build() {
    final now = DateTime.now();

    final preSeededVisits = [
      AncVisit(
        id: 'anc_visit_1',
        visitNumber: 1,
        trimester: 1,
        title: 'Visit 1 — Early Registration & Baseline Screening',
        weekRange: 'Weeks 8–12',
        description: 'Baseline health assessment, official MCP registration, and fetal dating ultrasound.',
        recommendedChecks: const [
          'Registration & Mother and Child Protection (MCP) card issuance',
          'Hemoglobin (Hb) test for baseline anemia check',
          'Blood Group & Rh typing',
          'TSH (Thyroid Stimulating Hormone) screening',
          'Fasting Blood Sugar test',
          'First Dating / Viability Ultrasound Scan',
        ],
        isCompleted: true,
        completedDate: now.subtract(const Duration(days: 38)),
        doctorNotes: 'MCP Card issued. Blood Group O+ve, Hb 11.6 g/dL, TSH 1.9 mIU/L. Dating scan confirmed single active intrauterine fetus. EDD verified.',
      ),
      AncVisit(
        id: 'anc_visit_2',
        visitNumber: 2,
        trimester: 2,
        title: 'Visit 2 — Anomaly Scan & Gestational Diabetes Screening',
        weekRange: 'Weeks 14–26',
        description: 'Mid-pregnancy anatomical survey, glucose tolerance check, and initiation of daily IFA & Calcium.',
        recommendedChecks: const [
          'Anomaly / TIFFA (Targeted Imaging for Fetal Anomalies) scan (Weeks 18–20)',
          'Oral Glucose Tolerance Test (OGTT 75g) screening',
          'Maternal Blood Pressure (BP) & weight tracking',
          'Start daily IFA (Iron-Folic Acid) & Calcium supplements as advised by doctor',
        ],
        isCompleted: false,
        completedDate: null,
        doctorNotes: 'Scheduled for TIFFA scan at 19 weeks. Prescribed daily IFA (after lunch) and Calcium (with evening meal). Reminded never to ingest both at the same time.',
      ),
      AncVisit(
        id: 'anc_visit_3',
        visitNumber: 3,
        trimester: 3,
        title: 'Visit 3 — Growth Scan, Preeclampsia Check & Kick Counting',
        weekRange: 'Weeks 28–34',
        description: 'Third-trimester maternal vitals, repeat hemoglobin, fetal growth scan, and daily kick counting habit.',
        recommendedChecks: const [
          'Repeat Hemoglobin (Hb) to detect late-stage anemia',
          'Blood Pressure & Urine Albumin/Protein test (preeclampsia screening)',
          'Fetal Growth & Doppler Ultrasound scan',
          'Continue prescribed daily IFA & Calcium intake',
          'Start daily Fetal Kick Counting session (target 10 kicks in 2 hours)',
        ],
        isCompleted: false,
        completedDate: null,
        doctorNotes: 'Assess fetal position and amniotic fluid index. Re-confirm daily kick count routine using the PreNest Kick Counter tool.',
      ),
      AncVisit(
        id: 'anc_visit_4',
        visitNumber: 4,
        trimester: 3,
        title: 'Visit 4 — Birth Preparedness & Labor Safety Review',
        weekRange: 'Weeks 36–38',
        description: 'Final clinical review, presentation check, birth preparedness plan, and emergency 108 readiness.',
        recommendedChecks: const [
          'Final Blood Pressure, Maternal Weight & Fetal Presentation check',
          'Birth Preparedness Plan review: chosen delivery hospital & hospital bag checklist',
          'Confirm emergency 108 ambulance transport & backup private vehicle driver',
          'Identify and confirm compatible blood donor contact',
          'Review maternal danger signs (heavy bleeding, fluid leak, severe pain)',
        ],
        isCompleted: false,
        completedDate: null,
        doctorNotes: 'Review labor signs and 5-1-1 contraction rule. Ensure hospital bag, Aadhaar/ID, and MCP card are packed.',
      ),
    ];

    return AncPlannerState(
      visits: preSeededVisits,
      ifaTakenToday: true,
      calciumTakenToday: false,
      ifaLoggedAt: now.subtract(const Duration(hours: 3)),
      calciumLoggedAt: null,
    );
  }

  /// Toggle completion of an ANC visit
  void toggleVisit(String visitId) {
    state = state.copyWith(
      visits: state.visits.map((visit) {
        if (visit.id == visitId) {
          final nextCompleted = !visit.isCompleted;
          return visit.copyWith(
            isCompleted: nextCompleted,
            completedDate: () => nextCompleted ? DateTime.now() : null,
          );
        }
        return visit;
      }).toList(),
    );
  }

  /// Update doctor's notes for a specific ANC visit
  void updateDoctorNotes(String visitId, String notes) {
    state = state.copyWith(
      visits: state.visits.map((visit) {
        if (visit.id == visitId) {
          return visit.copyWith(doctorNotes: notes);
        }
        return visit;
      }).toList(),
    );
  }

  /// Toggle today's daily IFA intake
  void toggleIfaToday() {
    final next = !state.ifaTakenToday;
    state = state.copyWith(
      ifaTakenToday: next,
      ifaLoggedAt: () => next ? DateTime.now() : null,
    );
  }

  /// Toggle today's daily Calcium intake
  void toggleCalciumToday() {
    final next = !state.calciumTakenToday;
    state = state.copyWith(
      calciumTakenToday: next,
      calciumLoggedAt: () => next ? DateTime.now() : null,
    );
  }
}

/// Global provider for the ANC Visit Planner
final ancPlannerProvider =
    NotifierProvider<AncPlannerNotifier, AncPlannerState>(() {
      return AncPlannerNotifier();
    });
