import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stage/stage.dart';

/// Presentation and data model for doctor-advised medicine and supplement reminders.
/// Non-prescriptive, non-dosing reminder for adherence and partner visibility.
@immutable
class MedicineReminder {
  final String id;
  final String name;
  final String scheduleLabel;
  final PregnancyStage? stageScope; // null represents 'all' stages
  final bool isSharedWithPartner;
  final bool takenToday;
  final String notes;
  final String partnerOwnerId; // 'primary_user', 'secondary_user', or 'all'

  const MedicineReminder({
    required this.id,
    required this.name,
    required this.scheduleLabel,
    this.stageScope,
    this.isSharedWithPartner = true,
    this.takenToday = false,
    this.notes = '',
    this.partnerOwnerId = 'primary_user',
  });

  MedicineReminder copyWith({
    String? id,
    String? name,
    String? scheduleLabel,
    PregnancyStage? stageScope,
    bool clearStageScope = false,
    bool? isSharedWithPartner,
    bool? takenToday,
    String? notes,
    String? partnerOwnerId,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduleLabel: scheduleLabel ?? this.scheduleLabel,
      stageScope: clearStageScope ? null : (stageScope ?? this.stageScope),
      isSharedWithPartner: isSharedWithPartner ?? this.isSharedWithPartner,
      takenToday: takenToday ?? this.takenToday,
      notes: notes ?? this.notes,
      partnerOwnerId: partnerOwnerId ?? this.partnerOwnerId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineReminder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          scheduleLabel == other.scheduleLabel &&
          stageScope == other.stageScope &&
          isSharedWithPartner == other.isSharedWithPartner &&
          takenToday == other.takenToday &&
          notes == other.notes &&
          partnerOwnerId == other.partnerOwnerId;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      scheduleLabel.hashCode ^
      stageScope.hashCode ^
      isSharedWithPartner.hashCode ^
      takenToday.hashCode ^
      notes.hashCode ^
      partnerOwnerId.hashCode;
}

/// Riverpod Notifier managing cross-stage medicine reminders and partner sharing.
class MedicineRemindersNotifier extends Notifier<List<MedicineReminder>> {
  @override
  List<MedicineReminder> build() {
    return const [
      MedicineReminder(
        id: 'med_folic_acid',
        name: 'Folic Acid / Preconception Multivitamin',
        scheduleLabel: 'Morning • After breakfast',
        stageScope: PregnancyStage.plan,
        isSharedWithPartner: true,
        takenToday: true,
        notes: 'Preconception neural tube development support as advised by your doctor.',
        partnerOwnerId: 'primary_user',
      ),
      MedicineReminder(
        id: 'med_pcos_inositol',
        name: 'Myo-Inositol & Vitamin D3',
        scheduleLabel: 'Morning • With water',
        stageScope: PregnancyStage.trying,
        isSharedWithPartner: true,
        takenToday: true,
        notes: 'Ovulatory rhythm & insulin sensitivity support as advised by your doctor.',
        partnerOwnerId: 'primary_user',
      ),
      MedicineReminder(
        id: 'med_iron_ifa',
        name: 'Iron & Folic Acid (IFA)',
        scheduleLabel: 'Afternoon • 2 hours post lunch',
        stageScope: PregnancyStage.pregnancy,
        isSharedWithPartner: true,
        takenToday: false,
        notes: 'Best taken with citrus or lemon water; maintain gap from milk/tea/calcium as advised by doctor.',
        partnerOwnerId: 'primary_user',
      ),
      MedicineReminder(
        id: 'med_calcium',
        name: 'Calcium & Vitamin D3',
        scheduleLabel: 'Evening • After dinner',
        stageScope: PregnancyStage.pregnancy,
        isSharedWithPartner: true,
        takenToday: false,
        notes: 'Bone & fetal skeletal support; maintain 2-3 hr gap from IFA as recommended by doctor.',
        partnerOwnerId: 'primary_user',
      ),
      MedicineReminder(
        id: 'med_postnatal_recovery',
        name: 'Postnatal Iron & Lactation Nourishment',
        scheduleLabel: 'Morning • After breakfast',
        stageScope: PregnancyStage.postpartum,
        isSharedWithPartner: true,
        takenToday: false,
        notes: 'Replenishes maternal iron stores and supports postpartum recovery as advised by doctor.',
        partnerOwnerId: 'primary_user',
      ),
      MedicineReminder(
        id: 'med_partner_vitality',
        name: 'Partner Preconception Zinc & CoQ10',
        scheduleLabel: 'Morning • With breakfast',
        stageScope: PregnancyStage.plan,
        isSharedWithPartner: true,
        takenToday: true,
        notes: 'Paternal preconception health and cellular vitality as advised by clinician.',
        partnerOwnerId: 'secondary_user',
      ),
      MedicineReminder(
        id: 'med_daily_hydration',
        name: 'Hydration & Electrolyte Care',
        scheduleLabel: 'Midday • 12:30 PM',
        stageScope: null, // Available across all modes
        isSharedWithPartner: true,
        takenToday: false,
        notes: 'Adequate fluids (2.5-3L water/coconut water/buttermilk) supporting energy and amniotic/cycle health.',
        partnerOwnerId: 'all',
      ),
    ];
  }

  /// Toggles the takenToday status for a reminder.
  void toggleTaken(String id) {
    state = [
      for (final reminder in state)
        if (reminder.id == id)
          reminder.copyWith(takenToday: !reminder.takenToday)
        else
          reminder,
    ];
  }

  /// Toggles whether a reminder is shared with the partner.
  void toggleSharedWithPartner(String id) {
    state = [
      for (final reminder in state)
        if (reminder.id == id)
          reminder.copyWith(isSharedWithPartner: !reminder.isSharedWithPartner)
        else
          reminder,
    ];
  }

  /// Adds a new doctor-advised reminder.
  void addReminder({
    required String name,
    required String scheduleLabel,
    PregnancyStage? stageScope,
    bool isSharedWithPartner = true,
    String notes = '',
    String partnerOwnerId = 'partner_priya',
  }) {
    final newReminder = MedicineReminder(
      id: 'med_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      scheduleLabel: scheduleLabel.trim(),
      stageScope: stageScope,
      isSharedWithPartner: isSharedWithPartner,
      takenToday: false,
      notes: notes.trim(),
      partnerOwnerId: partnerOwnerId,
    );

    state = [...state, newReminder];
  }

  /// Deletes a reminder by ID.
  void deleteReminder(String id) {
    state = state.where((reminder) => reminder.id != id).toList();
  }

  /// Resets daily completion status (e.g., at midnight).
  void resetDaily() {
    state = [
      for (final reminder in state) reminder.copyWith(takenToday: false),
    ];
  }
}

/// Provider for medicine and supplement reminders.
final medicineRemindersProvider =
    NotifierProvider<MedicineRemindersNotifier, List<MedicineReminder>>(() {
      return MedicineRemindersNotifier();
    });
