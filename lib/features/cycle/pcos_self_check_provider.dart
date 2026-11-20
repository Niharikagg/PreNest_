import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Presentation and content model for a single PCOD/PCOS self-check indicator.
class PcosIndicator {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const PcosIndicator({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// The 7 key clinical self-check indicators for PCOD/PCOS.
const List<PcosIndicator> kPcosSelfCheckIndicators = [
  PcosIndicator(
    id: 'irregular_cycles',
    title: 'Irregular, infrequent, or missed cycles',
    subtitle: 'Cycles longer than 35 days, unpredictable intervals, or missing cycles entirely.',
    icon: Icons.calendar_month_outlined,
  ),
  PcosIndicator(
    id: 'hormonal_acne',
    title: 'Persistent or hormonal acne',
    subtitle: 'Stubborn or cystic breakouts particularly along the jawline, chin, or upper back.',
    icon: Icons.flare_outlined,
  ),
  PcosIndicator(
    id: 'excess_hair',
    title: 'Excess facial or body hair',
    subtitle: 'Hirsutism patterns: coarse or dark hair growth on upper lip, chin, chest, or abdomen.',
    icon: Icons.face_retouching_natural_outlined,
  ),
  PcosIndicator(
    id: 'hair_thinning',
    title: 'Hair thinning or increased hair fall',
    subtitle: 'Noticeable hair shedding or widening part line (androgenic scalp thinning pattern).',
    icon: Icons.spa_outlined,
  ),
  PcosIndicator(
    id: 'weight_gain',
    title: 'Sudden or unexplained weight gain',
    subtitle: 'Difficulty managing body weight or central abdominal fat gain despite consistent nutrition.',
    icon: Icons.monitor_weight_outlined,
  ),
  PcosIndicator(
    id: 'dark_skin_patches',
    title: 'Darkened skin patches (neck, underarms, or folds)',
    subtitle: 'Velvety skin discoloration (Acanthosis nigricans) commonly associated with insulin resistance.',
    icon: Icons.wb_shade_outlined,
  ),
  PcosIndicator(
    id: 'fatigue_cravings',
    title: 'Persistent fatigue or frequent sugar cravings',
    subtitle: 'Energy dips after meals, persistent fatigue, or intense cravings for carbohydrates.',
    icon: Icons.battery_alert_outlined,
  ),
];

/// Immutable state holding the user's checked indicator IDs.
class PcosSelfCheckState {
  final Set<String> selectedIds;

  const PcosSelfCheckState({this.selectedIds = const {}});

  int get selectedCount => selectedIds.length;
  int get totalCount => kPcosSelfCheckIndicators.length;
  bool get hasSelected => selectedIds.isNotEmpty;

  bool get isOvulatoryPattern => selectedIds.contains('irregular_cycles');

  bool get isHyperandrogenismPattern =>
      selectedIds.contains('hormonal_acne') ||
      selectedIds.contains('excess_hair') ||
      selectedIds.contains('hair_thinning');

  bool get isMetabolicPattern =>
      selectedIds.contains('weight_gain') ||
      selectedIds.contains('dark_skin_patches') ||
      selectedIds.contains('fatigue_cravings');

  /// Non-diagnostic pattern summary text.
  String get patternSummary {
    if (selectedIds.isEmpty) {
      return 'No indicators currently selected. Check any symptoms you have experienced over the past 3–6 months to prepare an organized question list for your gynaecologist.';
    }

    final patterns = <String>[];
    if (isOvulatoryPattern) patterns.add('Cycle irregularity');
    if (isHyperandrogenismPattern) patterns.add('Androgen-related signs');
    if (isMetabolicPattern) patterns.add('Metabolic/Insulin signs');

    final patternStr = patterns.join(', ');
    return '$selectedCount of $totalCount indicators noted ($patternStr). PreNest does not diagnose conditions; use this organized checklist to guide your next doctor consultation.';
  }

  /// Rule-based questions dynamically tailored to the checked indicators.
  List<String> get gynaecologistQuestions {
    final questions = <String>[];

    // Baseline questions (always included for comprehensive clinical dialogue)
    questions.add(
      'How can I systematically track my cycle length and symptom patterns to help guide our management plan?',
    );
    questions.add(
      'What personalized dietary, exercise, and sleep modifications would best support my hormone balance?',
    );

    // Rule 1: Cycle irregularities
    if (isOvulatoryPattern) {
      questions.add(
        'Given my irregular or missed cycles, do you recommend a pelvic ultrasound (USG) to evaluate ovarian morphology and endometrial thickness?',
      );
    }

    // Rule 2: Hyperandrogenic signs (acne, hirsutism, hair thinning)
    if (isHyperandrogenismPattern) {
      questions.add(
        'Would you advise testing androgen markers (such as Total & Free Testosterone, DHEA-S, and LH/FSH ratio) to evaluate for androgen excess?',
      );
    }

    // Rule 3: Metabolic indicators (dark skin, weight gain, fatigue/cravings)
    if (isMetabolicPattern) {
      questions.add(
        'Should we check fasting insulin, fasting blood glucose, and HbA1c to screen for insulin resistance or metabolic factors?',
      );
      if (selectedIds.contains('dark_skin_patches')) {
        questions.add(
          'Could the darkened skin patches on my neck or underarms be linked to insulin sensitivity (Acanthosis nigricans)?',
        );
      }
    }

    // Rule 4: Hair thinning or fatigue specifically
    if (selectedIds.contains('hair_thinning') ||
        selectedIds.contains('fatigue_cravings')) {
      questions.add(
        'Could we check my thyroid function (TSH) and micronutrient baselines (such as Vitamin D3, B12, and Ferritin) to rule out other causes of hair loss and fatigue?',
      );
    }

    // Rule 5: Both ovulatory & hyperandrogenic features flagged
    if (isOvulatoryPattern && isHyperandrogenismPattern) {
      questions.add(
        'Do my symptoms align with the international Rotterdam diagnostic criteria for PCOD/PCOS, and what clinical tests should we prioritize first?',
      );
    }

    return questions;
  }

  PcosSelfCheckState copyWith({Set<String>? selectedIds}) {
    return PcosSelfCheckState(selectedIds: selectedIds ?? this.selectedIds);
  }
}

/// Riverpod State Notifier managing PCOD/PCOS Symptom Self-Check selections.
class PcosSelfCheckNotifier extends Notifier<PcosSelfCheckState> {
  @override
  PcosSelfCheckState build() {
    // Pre-seed with 2 realistic indicators so initial views are informative and demonstrate dynamic questions
    return const PcosSelfCheckState(
      selectedIds: {'irregular_cycles', 'hormonal_acne'},
    );
  }

  void toggleIndicator(String id) {
    final updated = Set<String>.from(state.selectedIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(selectedIds: updated);
  }

  void setIndicator(String id, bool selected) {
    final updated = Set<String>.from(state.selectedIds);
    if (selected) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    state = state.copyWith(selectedIds: updated);
  }

  void reset() {
    state = const PcosSelfCheckState(selectedIds: {});
  }
}

/// Riverpod provider for the PCOD/PCOS Symptom Self-Check state.
final pcosSelfCheckProvider =
    NotifierProvider<PcosSelfCheckNotifier, PcosSelfCheckState>(
      PcosSelfCheckNotifier.new,
    );
