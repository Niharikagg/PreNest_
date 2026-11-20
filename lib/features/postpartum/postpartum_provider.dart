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
      EpdsOption(label: 'Yes, most of the time I haven\'t been able to cope', points: 3),
      EpdsOption(label: 'Yes, sometimes I haven\'t been coping as well as usual', points: 2),
      EpdsOption(label: 'No, most of the time I have coped quite well', points: 1),
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

class PostpartumState {
  // EPDS Screening answers (0 to 9 index mapped to chosen points 0-3)
  final Map<int, int> epdsAnswers;
  // Vaccine completion records (id mapped to DateTime recorded)
  final Map<String, DateTime> vaccineRecords;

  const PostpartumState({
    required this.epdsAnswers,
    required this.vaccineRecords,
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

  PostpartumState copyWith({
    Map<int, int>? epdsAnswers,
    Map<String, DateTime>? vaccineRecords,
  }) {
    return PostpartumState(
      epdsAnswers: epdsAnswers ?? this.epdsAnswers,
      vaccineRecords: vaccineRecords ?? this.vaccineRecords,
    );
  }
}

class PostpartumNotifier extends Notifier<PostpartumState> {
  @override
  PostpartumState build() {
    final now = DateTime.now();
    return PostpartumState(
      // Pre-seed first 3 EPDS answers for smooth onboarding exploration
      epdsAnswers: const {
        0: 0,
        1: 1,
        2: 0,
      },
      // Pre-seed birth doses for demo
      vaccineRecords: {
        'bcg': now.subtract(const Duration(days: 14)),
        'opv_0': now.subtract(const Duration(days: 14)),
        'hep_b_0': now.subtract(const Duration(days: 14)),
      },
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
}

final postpartumProvider =
    NotifierProvider<PostpartumNotifier, PostpartumState>(() {
  return PostpartumNotifier();
});
