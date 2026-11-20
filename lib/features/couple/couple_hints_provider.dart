import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stage/stage.dart';

/// Represents a non-raw, empathetic smart hint generated when a partner opts in.
@immutable
class SmartPartnerHint {
  final String id;
  final String fromPartnerId;
  final String fromPartnerName;
  final String hintText;
  final DateTime createdAt;
  final bool isAcknowledged;

  const SmartPartnerHint({
    required this.id,
    required this.fromPartnerId,
    required this.fromPartnerName,
    required this.hintText,
    required this.createdAt,
    this.isAcknowledged = false,
  });

  SmartPartnerHint copyWith({
    String? id,
    String? fromPartnerId,
    String? fromPartnerName,
    String? hintText,
    DateTime? createdAt,
    bool? isAcknowledged,
  }) {
    return SmartPartnerHint(
      id: id ?? this.id,
      fromPartnerId: fromPartnerId ?? this.fromPartnerId,
      fromPartnerName: fromPartnerName ?? this.fromPartnerName,
      hintText: hintText ?? this.hintText,
      createdAt: createdAt ?? this.createdAt,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartPartnerHint &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fromPartnerId == other.fromPartnerId &&
          fromPartnerName == other.fromPartnerName &&
          hintText == other.hintText &&
          createdAt == other.createdAt &&
          isAcknowledged == other.isAcknowledged;

  @override
  int get hashCode =>
      id.hashCode ^
      fromPartnerId.hashCode ^
      fromPartnerName.hashCode ^
      hintText.hashCode ^
      createdAt.hashCode ^
      isAcknowledged.hashCode;
}

/// Actionable checkup or helping reminder shared between partners.
@immutable
class PartnerCheckupReminder {
  final String id;
  final String title;
  final String
  category; // 'Checkup Prep', 'Shared Medicine Check', 'Supportive Check-in'
  final bool isCompleted;
  final PregnancyStage? stage;

  const PartnerCheckupReminder({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.stage,
  });

  PartnerCheckupReminder copyWith({
    String? id,
    String? title,
    String? category,
    bool? isCompleted,
    PregnancyStage? stage,
    bool clearStage = false,
  }) {
    return PartnerCheckupReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      stage: clearStage ? null : (stage ?? this.stage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartnerCheckupReminder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          category == other.category &&
          isCompleted == other.isCompleted &&
          stage == other.stage;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      category.hashCode ^
      isCompleted.hashCode ^
      stage.hashCode;
}

/// Stage-aware couple quiz or myth-buster item.
@immutable
class CoupleQuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final PregnancyStage stage;
  final bool isMythBuster;
  final int? correctIndex; // null for open check-ins, index for myth-busters
  final String explanation;

  const CoupleQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.stage,
    this.isMythBuster = false,
    this.correctIndex,
    this.explanation = '',
  });
}

@immutable
class CoupleHintsState {
  final SmartPartnerHint? activeSmartHint;
  final List<PartnerCheckupReminder> checkupReminders;
  final Map<String, int> quizAnswers;

  const CoupleHintsState({
    this.activeSmartHint,
    this.checkupReminders = const [],
    this.quizAnswers = const {},
  });

  CoupleHintsState copyWith({
    SmartPartnerHint? activeSmartHint,
    bool clearActiveHint = false,
    List<PartnerCheckupReminder>? checkupReminders,
    Map<String, int>? quizAnswers,
  }) {
    return CoupleHintsState(
      activeSmartHint: clearActiveHint
          ? null
          : (activeSmartHint ?? this.activeSmartHint),
      checkupReminders: checkupReminders ?? this.checkupReminders,
      quizAnswers: quizAnswers ?? this.quizAnswers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoupleHintsState &&
          runtimeType == other.runtimeType &&
          activeSmartHint == other.activeSmartHint &&
          listEquals(checkupReminders, other.checkupReminders) &&
          mapEquals(quizAnswers, other.quizAnswers);

  @override
  int get hashCode =>
      activeSmartHint.hashCode ^
      checkupReminders.hashCode ^
      quizAnswers.hashCode;
}

/// Static catalog of stage-matched quiz questions & myth-busters.
const List<CoupleQuizQuestion> kCoupleQuizCatalog = [
  // 1. Period / PCOS
  CoupleQuizQuestion(
    id: 'quiz_pcos_1',
    question: 'Myth or Fact: If cycles are irregular with PCOD/PCOS, natural conception is impossible.',
    options: ['Myth (False)', 'Fact (True)'],
    stage: PregnancyStage.trying,
    isMythBuster: true,
    correctIndex: 0,
    explanation: 'Myth! With lifestyle balance, inositol/metabolic support, and guidance from a gynecologist, many couples conceive naturally or with simple first-line care.',
  ),
  CoupleQuizQuestion(
    id: 'quiz_pcos_2',
    question: 'How can partners best support during cycle tracking?',
    options: [
      'Encourage regular sleep & join in healthy home-cooked meals',
      'Remind them constantly about cycle days',
      'Leave all tracking strictly to her alone',
      'Avoid talking about fertility altogether',
    ],
    stage: PregnancyStage.trying,
    isMythBuster: false,
    correctIndex: 0,
    explanation: 'Partners who actively participate in stress reduction, nourishing meals, and gentle daily walks make cycle care much lighter.',
  ),

  // 2. Planning
  CoupleQuizQuestion(
    id: 'quiz_plan_1',
    question: 'Myth or Fact: Only the mother-to-be needs preconception supplements and health habits.',
    options: ['Myth (False)', 'Fact (True)'],
    stage: PregnancyStage.plan,
    isMythBuster: true,
    correctIndex: 0,
    explanation: 'Myth! Paternal sperm health reflects zinc, antioxidant intake, sleep, and lifestyle habits over the preceding 74-90 days of spermatogenesis.',
  ),
  CoupleQuizQuestion(
    id: 'quiz_plan_2',
    question: 'What is the most accurate approach to identify the fertile conception window?',
    options: [
      'Assuming ovulation strictly happens on cycle day 14 for everyone',
      'Combining cervical mucus signs, LH surge indicators, and temperature trends',
      'Relying solely on a random calendar app date',
      'Waiting until the period is delayed',
    ],
    stage: PregnancyStage.plan,
    isMythBuster: false,
    correctIndex: 1,
    explanation: 'Ovulation day varies significantly across women and cycles; observing bodily fertility signs gives the truest window.',
  ),

  // 3. Pregnancy
  CoupleQuizQuestion(
    id: 'quiz_preg_1',
    question: 'Myth or Fact: During pregnancy, mothers must literally "eat for two" by doubling calorie intake.',
    options: ['Myth (False)', 'Fact (True)'],
    stage: PregnancyStage.pregnancy,
    isMythBuster: true,
    correctIndex: 0,
    explanation: 'Myth! Calorie needs only rise by about 300-350 kcal/day in the 2nd and 3rd trimesters. Nutrient density (protein, iron, calcium) matters vastly more than volume.',
  ),
  CoupleQuizQuestion(
    id: 'quiz_preg_2',
    question: 'Why do doctors commonly advise left-side resting in mid-to-late pregnancy?',
    options: [
      'It prevents compression of the inferior vena cava and optimizes blood flow to the placenta',
      'It is just an old tradition with no anatomical basis',
      'It makes labor happen immediately',
      'It is strictly required 24 hours a day',
    ],
    stage: PregnancyStage.pregnancy,
    isMythBuster: false,
    correctIndex: 0,
    explanation: 'Left-side positioning relieves uterine weight from major veins, facilitating smooth circulation to kidneys, fetus, and uterus.',
  ),

  // 4. Postpartum
  CoupleQuizQuestion(
    id: 'quiz_post_1',
    question: 'Myth or Fact: Maternal recovery is fully complete by the 6-week routine checkup.',
    options: ['Myth (False)', 'Fact (True)'],
    stage: PregnancyStage.postpartum,
    isMythBuster: true,
    correctIndex: 0,
    explanation: 'Myth! The 6-week visit is just an initial milestone. Pelvic floor recovery, hormonal rebalancing, and emotional restoration continue for months.',
  ),
  CoupleQuizQuestion(
    id: 'quiz_post_2',
    question: 'What is the best way for a partner to support during the early postpartum "fourth trimester"?',
    options: [
      'Taking ownership of feeding prep, burping, chores, and protecting her sleep blocks',
      'Expecting her to handle all infant care since she is on maternity leave',
      'Hosting lots of energetic visitors every day',
      'Waiting to be asked for every single task',
    ],
    stage: PregnancyStage.postpartum,
    isMythBuster: false,
    correctIndex: 0,
    explanation: 'Proactive partner care in meal prep, diaper changes, and sleep protection is the strongest buffer against postpartum exhaustion and distress.',
  ),
];

/// Riverpod Notifier managing couple hints, supportive quizzes, and shared checkups.
class CoupleHintsNotifier extends Notifier<CoupleHintsState> {
  @override
  CoupleHintsState build() {
    return CoupleHintsState(
      activeSmartHint: SmartPartnerHint(
        id: 'hint_seed_001',
        fromPartnerId: 'partner_priya',
        fromPartnerName: 'Priya',
        hintText: "She's leaning toward quiet rest & help with meals—offering to take care of dinner or giving her a calm wind-down tonight could mean a lot.",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isAcknowledged: false,
      ),
      checkupReminders: const [
        PartnerCheckupReminder(
          id: 'chk_anc_prep',
          title: 'Prepare 3 priority questions for the upcoming doctor visit together',
          category: 'Checkup Prep',
          isCompleted: false,
          stage: PregnancyStage.pregnancy,
        ),
        PartnerCheckupReminder(
          id: 'chk_med_check',
          title: 'Shared supplement check: Ensure daily IFA & calcium are stocked and taken',
          category: 'Shared Medicine Check',
          isCompleted: true,
          stage: null,
        ),
        PartnerCheckupReminder(
          id: 'chk_walk_checkin',
          title: 'Take a calm 15-minute screen-free evening stroll together',
          category: 'Supportive Check-in',
          isCompleted: false,
          stage: null,
        ),
        PartnerCheckupReminder(
          id: 'chk_vitals_review',
          title:
              'Review weekly blood pressure and hydration log before bedtime',
          category: 'Checkup Prep',
          isCompleted: false,
          stage: PregnancyStage.pregnancy,
        ),
        PartnerCheckupReminder(
          id: 'chk_records_file',
          title: 'Organize previous lab reports and scan file in the consultation folder',
          category: 'Checkup Prep',
          isCompleted: false,
          stage: PregnancyStage.plan,
        ),
        PartnerCheckupReminder(
          id: 'chk_postpartum_shift',
          title:
              'Coordinate nighttime newborn soothing shifts for protected rest',
          category: 'Supportive Check-in',
          isCompleted: false,
          stage: PregnancyStage.postpartum,
        ),
      ],
      quizAnswers: const {},
    );
  }

  /// Submits the supportive check-in quiz. If optInToSendHint is true,
  /// generates a supportive, non-raw partner hint.
  void submitSupportCheckIn({
    required String fromPartnerId,
    required String fromPartnerName,
    required String selectedOption,
    required bool optInToSendHint,
    required String role, // 'Her' or 'Him'
  }) {
    if (!optInToSendHint) {
      // User opted out: reflections remain private
      return;
    }

    String generatedHint;
    final isHer = role.toLowerCase().contains('her');

    if (selectedOption.contains('Quiet rest')) {
      generatedHint = isHer
          ? "She's leaning toward quiet rest & help with meals—offering to take care of dinner or giving her a calm wind-down tonight could mean a lot."
          : "He's feeling tired and could use quiet rest tonight—a relaxed evening and sharing tomorrow's chores can help him recharge.";
    } else if (selectedOption.contains('Help with meals')) {
      generatedHint = isHer
          ? "She could really use a hand with meals and household chores today—taking charge of a nourishing meal would be a huge relief."
          : "He's managing a lot of logistics today—taking initiative on a meal or running an errand together would lighten the load.";
    } else if (selectedOption.contains('Talking it through')) {
      generatedHint = isHer
          ? "She's hoping for an open, listening ear—setting aside a distraction-free 15 minutes to listen without fixing can create great comfort."
          : "He wants to stay closely involved—taking 15 minutes to share thoughts and talk through upcoming plans will bring great reassurance.";
    } else if (selectedOption.contains('walk together')) {
      generatedHint = isHer
          ? "She'd love some gentle fresh air and quiet companionship—inviting her for a calm 15-minute evening walk could lift both spirits."
          : "He'd love some unwinding time together—a gentle evening walk or relaxing tea together would be wonderful.";
    } else {
      generatedHint = isHer
          ? "She took a supportive check-in today—sharing a warm hug, checking in on hydration, and offering gentle appreciation will brighten her day."
          : "He took a supportive check-in today—expressing appreciation for his involvement and presence makes the journey feel truly shared.";
    }

    final newHint = SmartPartnerHint(
      id: 'hint_${DateTime.now().millisecondsSinceEpoch}',
      fromPartnerId: fromPartnerId,
      fromPartnerName: fromPartnerName,
      hintText: generatedHint,
      createdAt: DateTime.now(),
      isAcknowledged: false,
    );

    state = state.copyWith(activeSmartHint: newHint);
  }

  /// Records an answer to a quiz or myth-buster question.
  void answerQuizQuestion(String questionId, int optionIndex) {
    state = state.copyWith(
      quizAnswers: {...state.quizAnswers, questionId: optionIndex},
    );
  }

  /// Toggles a checkup/helping reminder completion.
  void toggleCheckupReminder(String id) {
    state = state.copyWith(
      checkupReminders: [
        for (final item in state.checkupReminders)
          if (item.id == id)
            item.copyWith(isCompleted: !item.isCompleted)
          else
            item,
      ],
    );
  }

  /// Adds a new partner checkup reminder.
  void addCheckupReminder({
    required String title,
    required String category,
    PregnancyStage? stage,
  }) {
    final newItem = PartnerCheckupReminder(
      id: 'chk_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      category: category,
      isCompleted: false,
      stage: stage,
    );
    state = state.copyWith(
      checkupReminders: [...state.checkupReminders, newItem],
    );
  }

  /// Deletes a checkup reminder.
  void deleteCheckupReminder(String id) {
    state = state.copyWith(
      checkupReminders: state.checkupReminders
          .where((item) => item.id != id)
          .toList(),
    );
  }

  /// Clears the active smart hint.
  void clearActiveHint() {
    state = state.copyWith(clearActiveHint: true);
  }

  /// Marks the active smart hint as acknowledged/read.
  void acknowledgeActiveHint() {
    if (state.activeSmartHint != null) {
      state = state.copyWith(
        activeSmartHint: state.activeSmartHint!.copyWith(isAcknowledged: true),
      );
    }
  }
}

/// Provider for couple hints, checkup reminders, and stage quizzes.
final coupleHintsProvider =
    NotifierProvider<CoupleHintsNotifier, CoupleHintsState>(() {
      return CoupleHintsNotifier();
    });
