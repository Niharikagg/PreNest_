import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/extracted_field.dart';
import '../../core/models/verified_result.dart';
import '../cycle/cycle_tracker_provider.dart';
import '../cycle/pcos_lab_panel_provider.dart';
import '../cycle/pcos_self_check_provider.dart';
import '../insights/mood_state_insight_provider.dart';
import '../profile/profile_provider.dart';
import '../records/records_provider.dart';
import '../records/vitals_log_screen.dart';
import '../stage/stage.dart';
import '../stage/stage_provider.dart';
import '../verify/verify_controller.dart';

/// Single item in the Measured Lab Facts section.
@immutable
class LabFactItem {
  final String testName;
  final String valueWithUnit;
  final String dateStr;
  final String referenceRange;
  final String statusLabel;
  final bool isFlagged;

  const LabFactItem({
    required this.testName,
    required this.valueWithUnit,
    required this.dateStr,
    required this.referenceRange,
    required this.statusLabel,
    this.isFlagged = false,
  });
}

/// Single item in the Measured Vitals Facts section.
@immutable
class VitalFactItem {
  final String label;
  final String value;
  final String dateStr;
  final String category;
  final String? note;

  const VitalFactItem({
    required this.label,
    required this.value,
    required this.dateStr,
    required this.category,
    this.note,
  });
}

/// 6-Month Cycle & PCOD/PCOS summary data.
@immutable
class CycleSummaryData {
  final bool irregularCycleMode;
  final int averageCycleLength;
  final int currentCycleDay;
  final String lastPeriodDateStr;
  final String flowIntensity;
  final List<String> activeSymptoms;
  final int flaggedPcosCount;
  final int totalPcosCount;
  final List<String> flaggedPcosNames;
  final String patternSummary;

  const CycleSummaryData({
    required this.irregularCycleMode,
    required this.averageCycleLength,
    required this.currentCycleDay,
    required this.lastPeriodDateStr,
    required this.flowIntensity,
    required this.activeSymptoms,
    required this.flaggedPcosCount,
    required this.totalPcosCount,
    required this.flaggedPcosNames,
    required this.patternSummary,
  });
}

/// App observation item (strictly non-diagnostic).
@immutable
class AppObservationItem {
  final String category;
  final String title;
  final String detail;
  final bool isAttentionNeeded;

  const AppObservationItem({
    required this.category,
    required this.title,
    required this.detail,
    this.isAttentionNeeded = false,
  });
}

/// Uncertain or low-confidence item that requires clinical paper report verification.
@immutable
class UncertainItem {
  final String title;
  final String reason;
  final String confidencePercent;
  final String recommendation;

  const UncertainItem({
    required this.title,
    required this.reason,
    required this.confidencePercent,
    required this.recommendation,
  });
}

/// Aggregated doctor summary presentation model.
@immutable
class DoctorSummaryData {
  final String partnerName;
  final String partnerRole;
  final int partnerAge;
  final String bloodGroup;
  final String stageDisplayName;
  final String stageDescription;
  final DateTime generatedAt;
  final List<LabFactItem> measuredLabs;
  final List<VitalFactItem> measuredVitals;
  final CycleSummaryData cycleSummary;
  final List<AppObservationItem> appObservations;
  final List<UncertainItem> uncertainItems;
  final List<String> autoQuestions;
  final List<String> customQuestions;

  const DoctorSummaryData({
    required this.partnerName,
    required this.partnerRole,
    required this.partnerAge,
    required this.bloodGroup,
    required this.stageDisplayName,
    required this.stageDescription,
    required this.generatedAt,
    required this.measuredLabs,
    required this.measuredVitals,
    required this.cycleSummary,
    required this.appObservations,
    required this.uncertainItems,
    required this.autoQuestions,
    required this.customQuestions,
  });

  List<String> get allQuestions => [...autoQuestions, ...customQuestions];
}

/// Notifier allowing the user to add and remove custom questions for their doctor.
class CustomDoctorQuestionsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [
    'Are there specific preconception supplements or dosage adjustments recommended for our stage?',
  ];

  void addQuestion(String question) {
    final trimmed = question.trim();
    if (trimmed.isNotEmpty && !state.contains(trimmed)) {
      state = [...state, trimmed];
    }
  }

  void removeQuestion(int index) {
    if (index >= 0 && index < state.length) {
      final updated = List<String>.from(state)..removeAt(index);
      state = updated;
    }
  }

  void clearQuestions() {
    state = [];
  }
}

final customDoctorQuestionsProvider =
    NotifierProvider<CustomDoctorQuestionsNotifier, List<String>>(
      CustomDoctorQuestionsNotifier.new,
    );

/// Reference range lookup dictionary for standardized lab tests.
const Map<String, String> kStandardLabRanges = {
  'Hemoglobin': '12.0 – 15.5 g/dL',
  'TSH': '0.4 – 4.0 mIU/L',
  'Vitamin D': '20.0 – 50.0 ng/mL',
  'AMH': '1.0 – 4.0 ng/mL',
  'Fasting Blood Sugar': '70.0 – 99.0 mg/dL',
  'Ferritin': '15.0 – 150.0 ng/mL',
  'Semen Analysis Motility': '>= 40 %',
  'Serum Testosterone': '300.0 – 1000.0 ng/dL',
};

String _formatShortDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

/// Riverpod provider aggregating live data across all PreNest health providers into
/// a structured 5-section doctor summary model.
final doctorSummaryProvider = Provider<DoctorSummaryData>((ref) {
  final couple = ref.watch(coupleProvider);
  final activePartner = couple.activePartner;
  final stage = ref.watch(stageProvider);
  final records = ref.watch(activePartnerRecordsProvider);
  final vitals = ref.watch(vitalsLogProvider);
  final cycleState = ref.watch(cycleTrackerProvider);
  final selfCheckState = ref.watch(pcosSelfCheckProvider);
  final labPanelState = ref.watch(pcosLabPanelProvider);
  final moodInsight = ref.watch(moodStateInsightProvider);
  final verifyState = ref.watch(verifyControllerProvider);
  final customQuestions = ref.watch(customDoctorQuestionsProvider);

  // 1. MEASURED LAB & VITALS FACTS
  final measuredLabs = <LabFactItem>[];
  final seenTestNames = <String>{};

  // Pull latest verified lab records for active partner
  final grouped = <String, List<VerifiedResult>>{};
  for (final r in records) {
    grouped.putIfAbsent(r.testNameStd, () => []).add(r);
  }

  for (final entry in grouped.entries) {
    final list = entry.value..sort((a, b) => a.date.compareTo(b.date));
    final latest = list.last;
    final stdRange =
        kStandardLabRanges[latest.testNameStd] ?? 'Printed range on report';
    measuredLabs.add(
      LabFactItem(
        testName: latest.testNameStd,
        valueWithUnit: '${latest.value} ${latest.unit}',
        dateStr: _formatShortDate(latest.date),
        referenceRange: stdRange,
        statusLabel: latest.status == VerificationStatus.confirmed
            ? 'Confirmed'
            : 'Corrected',
        isFlagged: false,
      ),
    );
    seenTestNames.add(latest.testNameStd.toLowerCase());
  }

  // Pull logged PCOS lab markers if not already in measuredLabs
  for (final marker in labPanelState.loggedMarkers) {
    if (!seenTestNames.contains(marker.name.toLowerCase())) {
      final isOutside = marker.rangeStatus == PcosRangeStatus.outsideRange;
      measuredLabs.add(
        LabFactItem(
          testName: marker.name,
          valueWithUnit: '${marker.value} ${marker.activeUnit}',
          dateStr: marker.loggedDate != null
              ? _formatShortDate(marker.loggedDate!)
              : 'Logged',
          referenceRange: marker.activeReferenceRange,
          statusLabel: marker.rangeStatusLabel,
          isFlagged: isOutside,
        ),
      );
      seenTestNames.add(marker.name.toLowerCase());
    }
  }

  // Pull Vitals (latest BP & Weight)
  final measuredVitals = <VitalFactItem>[];
  if (vitals.isNotEmpty) {
    final latestVital = vitals.first;
    measuredVitals.add(
      VitalFactItem(
        label: 'Blood Pressure',
        value: '${latestVital.systolicBp}/${latestVital.diastolicBp} mmHg',
        dateStr: _formatShortDate(latestVital.recordedAt),
        category: latestVital.bpCategory,
        note: latestVital.note,
      ),
    );
    measuredVitals.add(
      VitalFactItem(
        label: 'Body Weight',
        value: '${latestVital.weightKg.toStringAsFixed(1)} kg',
        dateStr: _formatShortDate(latestVital.recordedAt),
        category: 'Logged vital',
        note: null,
      ),
    );
  }

  // 2. 6-MONTH CYCLE & PCOD/PCOS SUMMARY
  final flaggedNames = <String>[];
  for (final ind in kPcosSelfCheckIndicators) {
    if (selfCheckState.selectedIds.contains(ind.id)) {
      flaggedNames.add(ind.title);
    }
  }

  final cycleSummary = CycleSummaryData(
    irregularCycleMode: cycleState.irregularCycleMode,
    averageCycleLength: cycleState.averageCycleLength,
    currentCycleDay: cycleState.currentCycleDay,
    lastPeriodDateStr: _formatShortDate(cycleState.lastPeriodStartDate),
    flowIntensity: cycleState.flowIntensity,
    activeSymptoms: cycleState.selectedSymptoms.toList(),
    flaggedPcosCount: selfCheckState.selectedCount,
    totalPcosCount: selfCheckState.totalCount,
    flaggedPcosNames: flaggedNames,
    patternSummary: selfCheckState.patternSummary,
  );

  // 3. APP OBSERVATIONS (NON-DIAGNOSTIC)
  final observations = <AppObservationItem>[];

  // Stage milestone observation
  observations.add(
    AppObservationItem(
      category: 'Stage & Milestone',
      title: '${stage.displayName} Stage Active',
      detail: stage.description,
      isAttentionNeeded: false,
    ),
  );

  // Lab trend observation (soft-label notes without diagnostic wording)
  final outsideLabs = labPanelState.loggedMarkers
      .where((m) => m.rangeStatus == PcosRangeStatus.outsideRange)
      .toList();
  if (outsideLabs.isNotEmpty) {
    for (final lab in outsideLabs) {
      observations.add(
        AppObservationItem(
          category: 'Lab Value Observation',
          title: '${lab.name}: Value Outside Printed Range',
          detail:
              'Recorded at ${lab.value} ${lab.activeUnit} (Printed reference range: ${lab.activeReferenceRange}). '
              'Soft-label observation only — please discuss clinical correlation with your physician.',
          isAttentionNeeded: true,
        ),
      );
    }
  } else {
    observations.add(
      const AppObservationItem(
        category: 'Lab Value Observation',
        title: 'Logged Metabolic & Hormone Markers',
        detail: 'Logged parameters appear consistent with standard printed reference ranges.',
        isAttentionNeeded: false,
      ),
    );
  }

  // Current synthesized state summary from moodStateInsightProvider
  observations.add(
    AppObservationItem(
      category: 'Synthesized Well-being',
      title: 'Current State: ${moodInsight.activeMood}',
      detail:
          '${moodInsight.stateSummary}. Guidance: ${moodInsight.professionalGuidance}',
      isAttentionNeeded: false,
    ),
  );

  // 4. UNCERTAIN / NEEDS-REVIEW ITEMS
  final uncertainList = <UncertainItem>[];

  for (final field in verifyState.fields) {
    final isLowConfidence = field.confidence < 0.8;
    final isMissingDate = field.date == null;
    final isNeedsReview = field.status == ExtractionStatus.needsReview;

    if (isLowConfidence || isMissingDate || isNeedsReview) {
      final name = field.testNameStd ?? field.testNameRaw;
      final reasons = <String>[];
      if (isLowConfidence) {
        reasons.add(
          'Low OCR extraction confidence (${(field.confidence * 100).toInt()}%)',
        );
      }
      if (isMissingDate) {
        reasons.add('Missing report date');
      }
      if (isNeedsReview) {
        reasons.add('Flagged for manual review during import');
      }

      uncertainList.add(
        UncertainItem(
          title: name,
          reason: reasons.join('; '),
          confidencePercent: '${(field.confidence * 100).toInt()}%',
          recommendation:
              'Double-check value (${field.value ?? "N/A"} ${field.unit ?? ""}) against original printed paper report.',
        ),
      );
    }
  }

  if (uncertainList.isEmpty) {
    uncertainList.add(
      const UncertainItem(
        title: 'Physical Report Verification',
        reason: 'All scanned lab records currently verified on-device.',
        confidencePercent: '100%',
        recommendation: 'Always bring physical printed diagnostic reports and USG films to your consultation.',
      ),
    );
  }

  // 5. QUESTIONS TO ASK YOUR DOCTOR
  final autoQuestions = <String>[];
  final seenQ = <String>{};

  void addQ(String q) {
    final trimmed = q.trim();
    if (trimmed.isNotEmpty && !seenQ.contains(trimmed.toLowerCase())) {
      seenQ.add(trimmed.toLowerCase());
      autoQuestions.add(trimmed);
    }
  }

  // From out-of-range labs
  for (final lab in outsideLabs) {
    addQ(
      'My ${lab.name} reading was ${lab.value} ${lab.activeUnit} (printed range: ${lab.activeReferenceRange}). What follow-up evaluation or lifestyle adjustments do you advise?',
    );
  }

  // From PCOS Self-Check
  for (final q in selfCheckState.gynaecologistQuestions) {
    addQ(q);
  }

  // From Mood & Stage Insight
  for (final q in moodInsight.doctorQuestions) {
    addQ(q);
  }

  return DoctorSummaryData(
    partnerName: activePartner.name,
    partnerRole: activePartner.role,
    partnerAge: activePartner.age,
    bloodGroup: activePartner.bloodGroup,
    stageDisplayName: stage.displayName,
    stageDescription: stage.description,
    generatedAt: DateTime.now(),
    measuredLabs: measuredLabs,
    measuredVitals: measuredVitals,
    cycleSummary: cycleSummary,
    appObservations: observations,
    uncertainItems: uncertainList,
    autoQuestions: autoQuestions,
    customQuestions: customQuestions,
  );
});
