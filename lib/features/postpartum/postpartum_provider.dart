import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpdsOption {
  final String label;
  final int points;

  const EpdsOption({required this.label, required this.points});
}

class EpdsQuestion {
  final int id;
  final String prompt;
  final List<EpdsOption> options;

  const EpdsQuestion({
    required this.id,
    required this.prompt,
    required this.options,
  });
}

const List<EpdsQuestion> kEpdsQuestions = [
  EpdsQuestion(
    id: 1,
    prompt: '1. I have been able to laugh and see the funny side of things:',
    options: [
      EpdsOption(label: 'As much as I always could', points: 0),
      EpdsOption(label: 'Not quite so much now', points: 1),
      EpdsOption(label: 'Definitely not so much now', points: 2),
      EpdsOption(label: 'Not at all', points: 3),
    ],
  ),
  EpdsQuestion(
    id: 2,
    prompt: '2. I have looked forward with enjoyment to things:',
    options: [
      EpdsOption(label: 'As much as I ever did', points: 0),
      EpdsOption(label: 'Rather less than I used to', points: 1),
      EpdsOption(label: 'Definitely less than I used to', points: 2),
      EpdsOption(label: 'Hardly at all', points: 3),
    ],
  ),
  EpdsQuestion(
    id: 3,
    prompt: '3. I have blamed myself unnecessarily when things went wrong:',
    options: [
      EpdsOption(label: 'Yes, most of the time', points: 3),
      EpdsOption(label: 'Yes, some of the time', points: 2),
      EpdsOption(label: 'Not very often', points: 1),
      EpdsOption(label: 'No, never', points: 0),
    ],
  ),
  EpdsQuestion(
    id: 4,
    prompt: '4. I have been anxious or worried for no good reason:',
    options: [
      EpdsOption(label: 'No, not at all', points: 0),
      EpdsOption(label: 'Hardly ever', points: 1),
      EpdsOption(label: 'Yes, sometimes', points: 2),
      EpdsOption(label: 'Yes, very often', points: 3),
    ],
  ),
  EpdsQuestion(
    id: 5,
    prompt: '5. I have felt scared or panicky for no very good reason:',
    options: [
      EpdsOption(label: 'Yes, quite a lot', points: 3),
      EpdsOption(label: 'Yes, sometimes', points: 2),
      EpdsOption(label: 'No, not much', points: 1),
      EpdsOption(label: 'No, not at all', points: 0),
    ],
  ),
  EpdsQuestion(
    id: 6,
    prompt: '6. Things have been getting on top of me:',
    options: [
      EpdsOption(
        label: 'Yes, most of the time I haven\'t been able to cope',
        points: 3,
      ),
      EpdsOption(
        label: 'Yes, sometimes I haven\'t been coping as well as usual',
        points: 2,
      ),
      EpdsOption(
        label: 'No, most of the time I have coped quite well',
        points: 1,
      ),
      EpdsOption(label: 'No, have been coping as well as ever', points: 0),
    ],
  ),
  EpdsQuestion(
    id: 7,
    prompt: '7. I have been so unhappy that I have had difficulty sleeping:',
    options: [
      EpdsOption(label: 'Yes, most of the time', points: 3),
      EpdsOption(label: 'Yes, sometimes', points: 2),
      EpdsOption(label: 'Not very often', points: 1),
      EpdsOption(label: 'No, not at all', points: 0),
    ],
  ),
  EpdsQuestion(
    id: 8,
    prompt: '8. I have felt sad or miserable:',
    options: [
      EpdsOption(label: 'Yes, most of the time', points: 3),
      EpdsOption(label: 'Yes, quite often', points: 2),
      EpdsOption(label: 'Not very often', points: 1),
      EpdsOption(label: 'No, not at all', points: 0),
    ],
  ),
  EpdsQuestion(
    id: 9,
    prompt: '9. I have been so unhappy that I have been crying:',
    options: [
      EpdsOption(label: 'Yes, most of the time', points: 3),
      EpdsOption(label: 'Yes, quite often', points: 2),
      EpdsOption(label: 'Only occasionally', points: 1),
      EpdsOption(label: 'No, never', points: 0),
    ],
  ),
  EpdsQuestion(
    id: 10,
    prompt: '10. The thought of harming myself has occurred to me:',
    options: [
      EpdsOption(label: 'Yes, quite often', points: 3),
      EpdsOption(label: 'Sometimes', points: 2),
      EpdsOption(label: 'Hardly ever', points: 1),
      EpdsOption(label: 'Never', points: 0),
    ],
  ),
];

class VaccineItem {
  final String id;
  final String name;
  final String details;

  const VaccineItem({
    required this.id,
    required this.name,
    required this.details,
  });
}

class VaccineGroup {
  final String ageGroup;
  final List<VaccineItem> vaccines;

  const VaccineGroup({required this.ageGroup, required this.vaccines});
}

const List<VaccineGroup> kUipVaccineSchedule = [
  VaccineGroup(
    ageGroup: 'At Birth',
    vaccines: [
      VaccineItem(
        id: 'bcg',
        name: 'BCG',
        details: 'Bacillus Calmette-Guérin (Tuberculosis protection)',
      ),
      VaccineItem(
        id: 'opv_0',
        name: 'OPV-0',
        details: 'Oral Polio Vaccine (Birth dose)',
      ),
      VaccineItem(
        id: 'hep_b_0',
        name: 'Hepatitis B (Birth dose)',
        details: 'Within 24 hours of birth to prevent vertical transmission',
      ),
    ],
  ),
  VaccineGroup(
    ageGroup: '6 Weeks',
    vaccines: [
      VaccineItem(
        id: 'opv_1',
        name: 'OPV-1',
        details: 'Oral Polio Vaccine 1st primary dose',
      ),
      VaccineItem(
        id: 'penta_1',
        name: 'Pentavalent-1',
        details: 'Protects against Diphtheria, Pertussis, Tetanus, Hep B & Hib',
      ),
      VaccineItem(
        id: 'rota_1',
        name: 'Rotavirus-1',
        details: 'RVV oral drops for severe rotavirus diarrhea protection',
      ),
      VaccineItem(
        id: 'fipv_1',
        name: 'fIPV-1',
        details: 'Fractional Inactivated Polio Vaccine 1st dose (Intradermal)',
      ),
      VaccineItem(
        id: 'pcv_1',
        name: 'PCV-1',
        details: 'Pneumococcal Conjugate Vaccine 1st dose',
      ),
    ],
  ),
  VaccineGroup(
    ageGroup: '10 Weeks',
    vaccines: [
      VaccineItem(
        id: 'opv_2',
        name: 'OPV-2',
        details: 'Oral Polio Vaccine 2nd dose',
      ),
      VaccineItem(
        id: 'penta_2',
        name: 'Pentavalent-2',
        details: '2nd dose (DPT, Hepatitis B, Hib)',
      ),
      VaccineItem(
        id: 'rota_2',
        name: 'Rotavirus-2',
        details: 'Rotavirus oral drops 2nd dose',
      ),
    ],
  ),
  VaccineGroup(
    ageGroup: '14 Weeks',
    vaccines: [
      VaccineItem(
        id: 'opv_3',
        name: 'OPV-3',
        details: 'Oral Polio Vaccine 3rd dose',
      ),
      VaccineItem(
        id: 'penta_3',
        name: 'Pentavalent-3',
        details: '3rd dose (DPT, Hepatitis B, Hib)',
      ),
      VaccineItem(
        id: 'rota_3',
        name: 'Rotavirus-3',
        details: 'Rotavirus oral drops 3rd dose',
      ),
      VaccineItem(
        id: 'fipv_2',
        name: 'fIPV-2',
        details: 'Fractional Inactivated Polio Vaccine 2nd dose',
      ),
      VaccineItem(
        id: 'pcv_2',
        name: 'PCV-2',
        details: 'Pneumococcal Conjugate Vaccine 2nd dose',
      ),
    ],
  ),
];

/// Postpartum physical recovery checklist item adapting to birth type.
class PostpartumRecoveryTip {
  final String id;
  final String title;
  final String description;
  final String clinicalRationale;
  final String source;
  final bool isCSectionOnly;
  final bool isVaginalOnly;

  const PostpartumRecoveryTip({
    required this.id,
    required this.title,
    required this.description,
    required this.clinicalRationale,
    required this.source,
    this.isCSectionOnly = false,
    this.isVaginalOnly = false,
  });
}

const List<PostpartumRecoveryTip> kPostpartumRecoveryTips = [
  // Vaginal Delivery Specific Tips
  PostpartumRecoveryTip(
    id: 'vaginal_rest',
    title: 'Pelvic Rest & Gentle Diaphragmatic Breathing',
    description: 'Rest horizontally whenever baby sleeps. Focus on gentle diaphragmatic breathing to release intra-abdominal pressure. Await physician clearance before starting active pelvic floor exercises.',
    clinicalRationale: 'Promotes natural perineal tissue healing and avoids excessive downward pelvic organ strain.',
    source: 'WHO Postnatal Care & ACOG Guidelines',
    isVaginalOnly: true,
  ),
  PostpartumRecoveryTip(
    id: 'vaginal_perineal',
    title: 'Perineal Care & Warm Sitz Baths',
    description: 'Cleanse with warm water using a peri-rinse bottle after urination. Short warm sitz baths (10–15 min) or chilled witch hazel pads help soothe soreness and promote comfort.',
    clinicalRationale: 'Maintains hygiene, reduces bacterial contamination risk, and improves localized circulation for faster tissue repair.',
    source: 'MoHFW Maternal Health Division & ICMR',
    isVaginalOnly: true,
  ),
  PostpartumRecoveryTip(
    id: 'vaginal_lochia',
    title: 'Lochia Flow & Color Monitoring',
    description: 'Vaginal discharge should gradually transition from bright red (rubra) to pinkish-brown (serosa) and creamy white (alba). Use maternity pads; avoid tampons or menstrual cups.',
    clinicalRationale: 'Ensures uterine involution is proceeding normally and prevents introducing pathogens into the healing uterine cavity.',
    source: 'WHO Postnatal Guidelines',
    isVaginalOnly: true,
  ),

  // C-Section Specific Tips
  PostpartumRecoveryTip(
    id: 'csection_incision',
    title: 'Surgical Incision Hygiene & Monitoring',
    description: 'Keep the incision clean and completely dry. Pat gently with a sterile towel after showering. Inspect daily for redness, increasing tenderness, abnormal warmth, or oozing.',
    clinicalRationale: 'Significantly minimizes surgical site infection (SSI) risk and prevents suture dehiscence.',
    source: 'WHO Guidelines for Cesarean Section Care',
    isCSectionOnly: true,
  ),
  PostpartumRecoveryTip(
    id: 'csection_lifting',
    title: 'Strict Weight Restriction (Lifting Limit)',
    description: 'Avoid lifting anything heavier than your newborn baby for the first 4 to 6 weeks. Avoid steep stair climbing and strenuous core bending.',
    clinicalRationale: 'Protects the healing fascial layers and deep rectus abdominal sutures during initial collagen cross-linking.',
    source: 'ACOG Postpartum Recovery Protocol',
    isCSectionOnly: true,
  ),
  PostpartumRecoveryTip(
    id: 'csection_ambulation',
    title: 'Gentle Frequent Ambulation (Short Walks)',
    description: 'Engage in frequent, short, gentle walks around the home starting early. Avoid prolonged bed rest while awake.',
    clinicalRationale: 'Reduces the risk of postpartum deep vein thrombosis (DVT) and stimulates bowel motility to relieve trapped abdominal gas.',
    source: 'MoHFW India Postoperative Clinical Advisory',
    isCSectionOnly: true,
  ),
  PostpartumRecoveryTip(
    id: 'csection_splinting',
    title: 'Abdominal Splinting for Sneezes & Coughs',
    description: 'Gently press a soft pillow firmly against your lower abdomen whenever you need to cough, sneeze, or laugh.',
    clinicalRationale: 'Absorbs sudden surges in intra-abdominal pressure, protecting incision edges from acute tension.',
    source: 'ACOG Clinical Guidance',
    isCSectionOnly: true,
  ),

  // Universal Checks for Both Birth Types
  PostpartumRecoveryTip(
    id: 'universal_checkup',
    title: 'Routine 6-Week Postnatal Maternal Checkup',
    description: 'Schedule your comprehensive postpartum clinic visit at 6 weeks with your obstetrician or primary health center (PHC) to assess blood pressure, hemoglobin, and healing.',
    clinicalRationale: 'Critical for catching delayed postpartum hypertension, persistent anemia, or pelvic floor dysfunction early.',
    source: 'MoHFW Postnatal Care Guidelines & WHO',
  ),
  PostpartumRecoveryTip(
    id: 'universal_hydration',
    title: 'Nourishing Hydration & Bowel Regularity',
    description: 'Drink 2.5–3 liters of warm water, jeera water, and traditional broths daily. Include fiber-rich vegetables, prunes, and whole grains to prevent straining.',
    clinicalRationale: 'Prevents constipation-induced pelvic floor straining and supports healthy milk synthesis.',
    source: 'ICMR-National Institute of Nutrition (NIN)',
  ),
  PostpartumRecoveryTip(
    id: 'universal_danger_redflags',
    title: 'Postpartum Red-Flag Awareness',
    description: 'Seek emergency medical evaluation if you experience: fever over 100.4°F (38°C), soaking a sanitary pad in under 1 hour, foul-smelling discharge, sudden severe headache with blurry vision, or one-sided calf pain.',
    clinicalRationale: 'Early triage for postpartum hemorrhage, endometritis, severe preeclampsia, or pulmonary embolism saves lives.',
    source: 'MoHFW 108 Emergency Protocol & WHO',
  ),
];

/// Structured informational guidance cards for breastfeeding support.
class BreastfeedingGuidanceItem {
  final String id;
  final String title;
  final String subtitle;
  final String body;
  final String actionableTip;
  final String source;

  const BreastfeedingGuidanceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.actionableTip,
    required this.source,
  });
}

const List<BreastfeedingGuidanceItem> kBreastfeedingGuidanceList = [
  BreastfeedingGuidanceItem(
    id: 'bf_latch',
    title: 'Painless Latch & Positioning Basics',
    subtitle: 'Asymmetric latch, wide open mouth, and tummy-to-tummy alignment',
    body: 'Breastfeeding should feel comfortable without persistent pinching. Bring baby to the breast (not breast to baby), ensuring baby\'s chin rests deep against the breast with their nose clear. Aim the nipple towards the baby\'s nose so they tilt their head back and open wide like a yawn, taking a large mouthful of the lower areola. Look for puffed cheeks and rhythmic, steady swallowing.',
    actionableTip: 'If feeding feels painful or pinched, break suction gently by inserting a clean pinky finger into the corner of baby\'s mouth before attempting to re-latch.',
    source: 'WHO & UNICEF Infant and Young Child Feeding (IYCF)',
  ),
  BreastfeedingGuidanceItem(
    id: 'bf_cues',
    title: 'Recognizing Early Hunger Cues',
    subtitle: 'Feed on demand: rooting, lip smacking, and hand-to-mouth signs',
    body: 'Newborns feed 8 to 12 times per 24 hours. Feeding at the very first signs of hunger creates a calmer latch. Early cues include stirring, turning the head side to side searching for the breast (rooting), licking lips, and bringing little fists to the mouth. Crying is a late hunger cue that causes agitation; soothing baby first with gentle skin-to-skin touch makes latching significantly easier.',
    actionableTip: 'Watch the baby, not the clock. Frequent nursing directly stimulates prolactin and oxytocin, establishing a robust long-term milk supply.',
    source: 'MoHFW India National Health Mission & WHO',
  ),
  BreastfeedingGuidanceItem(
    id: 'bf_nutrition',
    title: 'Maternal Hydration & Wholesome Indian Foods',
    subtitle:
        'Warm fluids, galactagogues, iron, and traditional nourishing meals',
    body: 'Producing breast milk requires ample fluids and adequate calories. Keep a warm bottle of water or jeera-infused water right beside your nursing station. Traditional Indian home-cooked foods such as methi (fenugreek), daliya (broken wheat), moong dal khichdi, ragi porridge, and drumstick leaves (moringa) provide essential bioavailable iron, calcium, and complex carbohydrates.',
    actionableTip: 'Take a sip of water each time you nurse. Avoid skipping meals or restricting calories during the fourth trimester recovery phase.',
    source: 'ICMR-National Institute of Nutrition (NIN)',
  ),
  BreastfeedingGuidanceItem(
    id: 'bf_when_to_seek_help',
    title: 'When to Consult a Lactation Specialist or Doctor',
    subtitle: 'Spotting nursing challenges early for mother & infant wellbeing',
    body:
        'Never hesitate to seek guidance from an International Board Certified Lactation Consultant (IBCLC) or pediatrician if you encounter:\n'
        '• Persistent sharp nipple pain or cracked, bleeding tissue beyond the first 10 seconds of latch.\n'
        '• Hard, hot, tender breast lumps accompanied by fever or flu-like chills (signs of mastitis).\n'
        '• Baby producing fewer than 6 pale wet diapers per day after day 5.\n'
        '• Baby appearing unusually sleepy, lethargic, or showing signs of poor weight gain.',
    actionableTip: 'One timely consultation with a lactation consultant can resolve posture and latch difficulties in a single session.',
    source: 'ACOG Clinical Guidance & WHO Guidelines',
  ),
];

class PostpartumState {
  // EPDS Screening answers (0 to 9 index mapped to chosen points 0-3)
  final Map<int, int> epdsAnswers;
  // Vaccine completion records (id mapped to DateTime recorded)
  final Map<String, DateTime> vaccineRecords;
  // Delivery setup
  final DateTime? deliveryDate;
  final String birthType; // 'Vaginal Delivery' or 'C-Section'
  final String feedingStyle; // 'Exclusive Breastfeeding', 'Mixed', or 'Formula'
  // Tailored recovery checklist completed IDs
  final Set<String> completedRecoveryTips;

  const PostpartumState({
    required this.epdsAnswers,
    required this.vaccineRecords,
    this.deliveryDate,
    this.birthType = 'Vaginal Delivery',
    this.feedingStyle = 'Exclusive Breastfeeding',
    this.completedRecoveryTips = const {},
  });

  int get totalEpdsScore {
    return epdsAnswers.values.fold(0, (sum, val) => sum + val);
  }

  bool get isEpdsComplete {
    return epdsAnswers.length == 10;
  }

  int get q10Score => epdsAnswers[9] ?? 0;

  bool get hasSelfHarmThought => q10Score > 0;

  bool get isEpdsHighRisk => totalEpdsScore >= 13 || hasSelfHarmThought;

  bool get isEpdsModerateRisk =>
      !isEpdsHighRisk && totalEpdsScore >= 10 && totalEpdsScore <= 12;

  /// Computed days elapsed since baby's delivery date.
  int get babyAgeInDays {
    if (deliveryDate == null) return 21;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deliv = DateTime(
      deliveryDate!.year,
      deliveryDate!.month,
      deliveryDate!.day,
    );
    final diff = today.difference(deliv).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Computed postpartum week (1-indexed).
  int get postpartumWeek {
    return (babyAgeInDays / 7).floor() + 1;
  }

  /// Formatted baby age summary label.
  String get babyAgeLabel {
    final days = babyAgeInDays;
    final dayStr = days == 1 ? '1 day' : '$days days';
    return 'Postpartum Week $postpartumWeek • Baby is $dayStr old';
  }

  /// Summary tag for birth type and feeding style.
  String get summaryLabel {
    return '$birthType • $feedingStyle';
  }

  PostpartumState copyWith({
    Map<int, int>? epdsAnswers,
    Map<String, DateTime>? vaccineRecords,
    DateTime? deliveryDate,
    String? birthType,
    String? feedingStyle,
    Set<String>? completedRecoveryTips,
  }) {
    return PostpartumState(
      epdsAnswers: epdsAnswers ?? this.epdsAnswers,
      vaccineRecords: vaccineRecords ?? this.vaccineRecords,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      birthType: birthType ?? this.birthType,
      feedingStyle: feedingStyle ?? this.feedingStyle,
      completedRecoveryTips:
          completedRecoveryTips ?? this.completedRecoveryTips,
    );
  }
}

class PostpartumNotifier extends Notifier<PostpartumState> {
  @override
  PostpartumState build() {
    final now = DateTime.now();
    return PostpartumState(
      // Pre-seed first 3 EPDS answers for smooth onboarding exploration
      epdsAnswers: const {0: 0, 1: 1, 2: 0},
      // Pre-seed birth doses for demo
      vaccineRecords: {
        'bcg': now.subtract(const Duration(days: 14)),
        'opv_0': now.subtract(const Duration(days: 14)),
        'hep_b_0': now.subtract(const Duration(days: 14)),
      },
      // Default to ~21 days ago for demo smoothness
      deliveryDate: now.subtract(const Duration(days: 21)),
      birthType: 'Vaginal Delivery',
      feedingStyle: 'Exclusive Breastfeeding',
      completedRecoveryTips: const {'vaginal_rest'},
    );
  }

  void answerEpdsQuestion(int questionIndex, int points) {
    state = state.copyWith(
      epdsAnswers: {...state.epdsAnswers, questionIndex: points},
    );
  }

  void resetEpds() {
    state = state.copyWith(epdsAnswers: {});
  }

  void toggleVaccine(String id) {
    final updated = Map<String, DateTime>.from(state.vaccineRecords);
    if (updated.containsKey(id)) {
      updated.remove(id);
    } else {
      updated[id] = DateTime.now();
    }
    state = state.copyWith(vaccineRecords: updated);
  }

  void updateDeliveryDate(DateTime date) {
    state = state.copyWith(deliveryDate: date);
  }

  void updateBirthType(String type) {
    state = state.copyWith(birthType: type);
  }

  void updateFeedingStyle(String style) {
    state = state.copyWith(feedingStyle: style);
  }

  void toggleRecoveryTip(String tipId) {
    final updated = Set<String>.from(state.completedRecoveryTips);
    if (updated.contains(tipId)) {
      updated.remove(tipId);
    } else {
      updated.add(tipId);
    }
    state = state.copyWith(completedRecoveryTips: updated);
  }
}

final postpartumProvider =
    NotifierProvider<PostpartumNotifier, PostpartumState>(() {
      return PostpartumNotifier();
    });
