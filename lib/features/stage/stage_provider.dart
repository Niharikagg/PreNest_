import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'stage.dart';

class StageNotifier extends Notifier<PregnancyStage> {
  @override
  PregnancyStage build() => PregnancyStage.plan;

  void setStage(PregnancyStage stage) {
    state = stage;
  }
}

final stageProvider = NotifierProvider<StageNotifier, PregnancyStage>(() {
  return StageNotifier();
});
