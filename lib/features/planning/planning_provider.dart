import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanningHabit {
  final String id;
  final String title;
  final String subtitle;
  final String evidenceNote;
  final IconData icon;

  const PlanningHabit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.evidenceNote,
    required this.icon,
  });
}

class PreconceptionTask {
  final String id;
  final String targetRole; // 'Her', 'Him', 'Both'
  final String title;
  final String description;
  final String evidenceNote;

  const PreconceptionTask({
    required this.id,
    required this.targetRole,
    required this.title,
    required this.description,
    required this.evidenceNote,
  });
}

const List<PlanningHabit> kDailyPlanningHabits = [
  PlanningHabit(
    id: 'folic_acid',
    title: 'Folic acid reminder note',
    subtitle: 'Daily pre-conception baseline (400 mcg) to support neural tube development',
    evidenceNote: 'WHO & FOGSI clinical guidelines recommend starting daily folic acid 1–3 months before conception to reduce neural tube defect risk by up to 70%.',
    icon: Icons.medication_liquid_outlined,
  ),
  PlanningHabit(
    id: 'sleep',
    title: 'Sleep 7–8h',
    subtitle:
        'Restorative circadian rhythm supporting reproductive hormonal balance',
    evidenceNote: 'Circadian melatonin rhythms regulate the hypothalamic-pituitary-gonadal axis, stabilizing LH and progesterone synthesis.',
    icon: Icons.bedtime_outlined,
  ),
  PlanningHabit(
    id: 'movement',
    title: 'Movement / walk',
    subtitle: '30 mins moderate walking, yoga, or gentle physical exercise',
    evidenceNote: 'Consistent moderate physical activity enhances insulin sensitivity and pelvic perfusion without adding excessive physical stress.',
    icon: Icons.directions_walk_rounded,
  ),
  PlanningHabit(
    id: 'balanced_meals',
    title: 'Balanced meals',
    subtitle: 'Protein, leafy greens, micronutrients & whole food nourishment',
    evidenceNote: 'Diets rich in plant proteins, folate, iron, and omega-3 fatty acids are linked to improved ovulatory function and sperm quality.',
    icon: Icons.restaurant_outlined,
  ),
  PlanningHabit(
    id: 'avoid_toxins',
    title: 'Avoid tobacco/alcohol',
    subtitle:
        'Partner-wide cessation of smoking, alcohol & recreational exposure',
    evidenceNote: 'Smoking and alcohol elevate gamete oxidative stress, sperm DNA fragmentation, and early developmental risks.',
    icon: Icons.smoke_free_rounded,
  ),
];

const List<PreconceptionTask> kPreconceptionTasks = [
  PreconceptionTask(
    id: 'task_rubella',
    targetRole: 'Her',
    title: 'Rubella & Varicella Immunity Check',
    description: 'Verify IgG antibodies prior to conception with your doctor.',
    evidenceNote: 'Confirming rubella immunity before pregnancy prevents congenital rubella syndrome, as live vaccines cannot be given during pregnancy.',
  ),
  PreconceptionTask(
    id: 'task_thyroid_hb',
    targetRole: 'Her',
    title: 'Thyroid (TSH) & Hemoglobin Panel',
    description: 'Screen for subclinical hypothyroidism and anemia.',
    evidenceNote: 'Optimal pre-conception TSH (<2.5 mIU/L) and normal ferritin support regular ovulation and early embryonic implantation.',
  ),
  PreconceptionTask(
    id: 'task_dental',
    targetRole: 'Her',
    title: 'Pre-pregnancy Dental Assessment',
    description: 'Routine cleaning and checkup to address periodontal health.',
    evidenceNote: 'Active periodontal infection is associated with systemic inflammation and elevated risk of preterm labor.',
  ),
  PreconceptionTask(
    id: 'task_sperm_health',
    targetRole: 'Him',
    title: 'Sperm Health & Temperature Routine',
    description: 'Avoid prolonged saunas, hot baths, and keeping laptops directly on lap.',
    evidenceNote: 'Scrotal temperature elevation impairs spermatogenesis during the ~74-day spermatogenic cycle.',
  ),
  PreconceptionTask(
    id: 'task_him_nutrition',
    targetRole: 'Him',
    title: 'Micronutrient & Antioxidant Intake',
    description:
        'Incorporate zinc, selenium, CoQ10, and vitamin C rich whole foods.',
    evidenceNote: 'Dietary antioxidants lower semen reactive oxygen species (ROS) and support sperm motility.',
  ),
  PreconceptionTask(
    id: 'task_thalassemia',
    targetRole: 'Both',
    title: 'Thalassemia Carrier Screening (CBC & HbA2)',
    description:
        'Simple blood test for both partners to assess carrier status.',
    evidenceNote: 'Routine carrier screening identifies couples at risk for beta-thalassemia major, allowing informed reproductive choices.',
  ),
  PreconceptionTask(
    id: 'task_doctor_counseling',
    targetRole: 'Both',
    title: 'Preconception Clinical Consultation',
    description: 'Meet a gynecologist to review medical history, medications, and family tree.',
    evidenceNote: 'Clinical review ensures any chronic prescriptions (e.g. for BP, thyroid, skin) are swapped to pregnancy-safe alternatives.',
  ),
];

class PlanningState {
  final bool isActivelyTrying;
  final String partnerFocus; // 'Both', 'For Her', 'For Him'
  final Map<String, bool> habitCompletions;
  final Map<String, bool> taskCompletions;

  const PlanningState({
    this.isActivelyTrying = true,
    this.partnerFocus = 'Both',
    required this.habitCompletions,
    required this.taskCompletions,
  });

  int get completedHabitCount => habitCompletions.values.where((v) => v).length;

  int get totalHabitCount => kDailyPlanningHabits.length;

  double get habitProgress =>
      totalHabitCount == 0 ? 0.0 : (completedHabitCount / totalHabitCount);

  PlanningState copyWith({
    bool? isActivelyTrying,
    String? partnerFocus,
    Map<String, bool>? habitCompletions,
    Map<String, bool>? taskCompletions,
  }) {
    return PlanningState(
      isActivelyTrying: isActivelyTrying ?? this.isActivelyTrying,
      partnerFocus: partnerFocus ?? this.partnerFocus,
      habitCompletions: habitCompletions ?? this.habitCompletions,
      taskCompletions: taskCompletions ?? this.taskCompletions,
    );
  }
}

class PlanningNotifier extends Notifier<PlanningState> {
  @override
  PlanningState build() {
    return const PlanningState(
      isActivelyTrying: true,
      partnerFocus: 'Both',
      habitCompletions: {
        'folic_acid': true,
        'sleep': true,
        'movement': false,
        'balanced_meals': true,
        'avoid_toxins': true,
      },
      taskCompletions: {
        'task_rubella': true,
        'task_thyroid_hb': true,
        'task_dental': false,
        'task_sperm_health': true,
        'task_him_nutrition': true,
        'task_thalassemia': false,
        'task_doctor_counseling': true,
      },
    );
  }

  void setActivelyTrying(bool activelyTrying) {
    state = state.copyWith(isActivelyTrying: activelyTrying);
  }

  void setPartnerFocus(String focus) {
    state = state.copyWith(partnerFocus: focus);
  }

  void toggleHabit(String habitId) {
    final current = state.habitCompletions[habitId] ?? false;
    state = state.copyWith(
      habitCompletions: {...state.habitCompletions, habitId: !current},
    );
  }

  void resetDailyHabits() {
    state = state.copyWith(
      habitCompletions: {for (final h in kDailyPlanningHabits) h.id: false},
    );
  }

  void toggleTask(String taskId) {
    final current = state.taskCompletions[taskId] ?? false;
    state = state.copyWith(
      taskCompletions: {...state.taskCompletions, taskId: !current},
    );
  }
}

final planningProvider = NotifierProvider<PlanningNotifier, PlanningState>(() {
  return PlanningNotifier();
});
