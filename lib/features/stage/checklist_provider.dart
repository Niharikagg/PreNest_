import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/profile_provider.dart';
import 'stage.dart';
import 'stage_provider.dart';

class StageChecklistItem {
  final String id;
  final PregnancyStage stage;
  final String title;
  final String description;
  final bool isForHim;
  final bool isForHer;
  final String sourceLink;

  const StageChecklistItem({
    required this.id,
    required this.stage,
    required this.title,
    required this.description,
    required this.isForHim,
    required this.isForHer,
    required this.sourceLink,
  });

  factory StageChecklistItem.fromJson(Map<String, dynamic> json) {
    return StageChecklistItem(
      id: json['id'] as String,
      stage: PregnancyStage.values.byName(json['stage'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      isForHim: json['isForHim'] as bool,
      isForHer: json['isForHer'] as bool,
      sourceLink: json['sourceLink'] as String? ?? '',
    );
  }
}

class CompletedChecklistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String itemId) {
    if (state.contains(itemId)) {
      state = {...state}..remove(itemId);
    } else {
      state = {...state, itemId};
    }
  }

  void markCompleted(String itemId) {
    state = {...state, itemId};
  }

  void markIncomplete(String itemId) {
    state = {...state}..remove(itemId);
  }

  bool isCompleted(String itemId) => state.contains(itemId);
}

final completedChecklistProvider =
    NotifierProvider<CompletedChecklistNotifier, Set<String>>(() {
  return CompletedChecklistNotifier();
});

final stageChecklistsProvider =
    FutureProvider<List<StageChecklistItem>>((ref) async {
  final jsonString =
      await rootBundle.loadString('assets/content/stage_checklists.json');
  final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
  return jsonList
      .map((item) => StageChecklistItem.fromJson(item as Map<String, dynamic>))
      .toList();
});

final filteredChecklistProvider =
    Provider<AsyncValue<List<StageChecklistItem>>>((ref) {
  final checklistsAsync = ref.watch(stageChecklistsProvider);
  final currentStage = ref.watch(stageProvider);
  final couple = ref.watch(coupleProvider);
  final activePartner = couple.activePartner;
  final isHer = activePartner.role.trim().toLowerCase() == 'her';

  return checklistsAsync.whenData((items) {
    return items.where((item) {
      final matchesStage = item.stage == currentStage;
      final matchesPartner = isHer ? item.isForHer : item.isForHim;
      return matchesStage && matchesPartner;
    }).toList();
  });
});
