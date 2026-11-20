enum PregnancyStage {
  plan,
  trying,
  pregnancy,
  postpartum;

  String get displayName {
    switch (this) {
      case PregnancyStage.plan:
        return 'Planning';
      case PregnancyStage.trying:
        return 'Trying';
      case PregnancyStage.pregnancy:
        return 'Pregnancy';
      case PregnancyStage.postpartum:
        return 'Postpartum';
    }
  }

  String get description {
    switch (this) {
      case PregnancyStage.plan:
        return 'Pre-conception health, fertility baselines & lifestyle prep';
      case PregnancyStage.trying:
        return 'Cycle tracking, ovulation windows & active conception';
      case PregnancyStage.pregnancy:
        return 'Trimester vitals, scans, lab panels & maternal care';
      case PregnancyStage.postpartum:
        return 'Postnatal recovery, infant tracking & pediatric metrics';
    }
  }
}
