import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stage/stage.dart';

/// Categories for media and records stored in the Keepsake Vault.
enum VaultCategory {
  ultrasoundScan,
  milestonePhoto,
  videoClip,
  medicalCopy;

  String get displayName {
    switch (this) {
      case VaultCategory.ultrasoundScan:
        return 'Ultrasound & Scans';
      case VaultCategory.milestonePhoto:
        return 'Milestone Photos';
      case VaultCategory.videoClip:
        return 'Video Clips';
      case VaultCategory.medicalCopy:
        return 'Medical Copies';
    }
  }

  String get shortTag {
    switch (this) {
      case VaultCategory.ultrasoundScan:
        return 'Scan';
      case VaultCategory.milestonePhoto:
        return 'Photo';
      case VaultCategory.videoClip:
        return 'Video';
      case VaultCategory.medicalCopy:
        return 'Medical';
    }
  }
}

/// Filter options for vault categories.
enum VaultCategoryFilter {
  all,
  ultrasounds,
  milestonesAndVideos,
  medicalCopies;

  String get label {
    switch (this) {
      case VaultCategoryFilter.all:
        return 'All';
      case VaultCategoryFilter.ultrasounds:
        return 'Ultrasounds & Scans';
      case VaultCategoryFilter.milestonesAndVideos:
        return 'Milestones & Videos';
      case VaultCategoryFilter.medicalCopies:
        return 'Medical Copies';
    }
  }

  bool matches(VaultCategory category) {
    switch (this) {
      case VaultCategoryFilter.all:
        return true;
      case VaultCategoryFilter.ultrasounds:
        return category == VaultCategory.ultrasoundScan;
      case VaultCategoryFilter.milestonesAndVideos:
        return category == VaultCategory.milestonePhoto ||
            category == VaultCategory.videoClip;
      case VaultCategoryFilter.medicalCopies:
        return category == VaultCategory.medicalCopy;
    }
  }
}

/// Filter options for partner sharing status.
enum VaultSharingFilter {
  all,
  sharedOnly,
  privateOnly;

  String get label {
    switch (this) {
      case VaultSharingFilter.all:
        return 'All';
      case VaultSharingFilter.sharedOnly:
        return 'Shared';
      case VaultSharingFilter.privateOnly:
        return 'Private';
    }
  }
}

/// Represents an item in the Media & Keepsake Vault.
@immutable
class VaultMediaItem {
  final String id;
  final String title;
  final VaultCategory category;
  final PregnancyStage stage;
  final String caption;
  final String dateLabel;
  final bool isSharedWithPartner;
  final bool isLocked;

  const VaultMediaItem({
    required this.id,
    required this.title,
    required this.category,
    required this.stage,
    required this.caption,
    required this.dateLabel,
    required this.isSharedWithPartner,
    required this.isLocked,
  });

  VaultMediaItem copyWith({
    String? id,
    String? title,
    VaultCategory? category,
    PregnancyStage? stage,
    String? caption,
    String? dateLabel,
    bool? isSharedWithPartner,
    bool? isLocked,
  }) {
    return VaultMediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      stage: stage ?? this.stage,
      caption: caption ?? this.caption,
      dateLabel: dateLabel ?? this.dateLabel,
      isSharedWithPartner: isSharedWithPartner ?? this.isSharedWithPartner,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultMediaItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          category == other.category &&
          stage == other.stage &&
          caption == other.caption &&
          dateLabel == other.dateLabel &&
          isSharedWithPartner == other.isSharedWithPartner &&
          isLocked == other.isLocked;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      category.hashCode ^
      stage.hashCode ^
      caption.hashCode ^
      dateLabel.hashCode ^
      isSharedWithPartner.hashCode ^
      isLocked.hashCode;
}

/// Riverpod Notifier for managing items in the Media / Keepsake Vault.
class MediaVaultNotifier extends Notifier<List<VaultMediaItem>> {
  @override
  List<VaultMediaItem> build() {
    return const [
      VaultMediaItem(
        id: 'vault_01',
        title: '12-Week NT Ultrasound Scan Note',
        category: VaultCategory.ultrasoundScan,
        stage: PregnancyStage.pregnancy,
        caption: 'First clear look at our little bean! Crown-rump length measuring 5.4 cm right on schedule. Heartbeat was rhythmic and strong at 158 bpm.',
        dateLabel: '14 Oct 2026',
        isSharedWithPartner: true,
        isLocked: false,
      ),
      VaultMediaItem(
        id: 'vault_02',
        title: 'Bump Milestone Photo (16 Weeks)',
        category: VaultCategory.milestonePhoto,
        stage: PregnancyStage.pregnancy,
        caption: 'First noticeable round bump emerging in the morning light! Wearing the sunshine yellow kurti gifted by Maa.',
        dateLabel: '10 Nov 2026',
        isSharedWithPartner: true,
        isLocked: false,
      ),
      VaultMediaItem(
        id: 'vault_03',
        title: 'First Baby Kick Video Clip',
        category: VaultCategory.videoClip,
        stage: PregnancyStage.pregnancy,
        caption: 'Felt distinct flutter taps on the lower left abdomen right after warm milk. Rohan placed his hand and felt the second tiny kick!',
        dateLabel: '28 Nov 2026',
        isSharedWithPartner: true,
        isLocked: false,
      ),
      VaultMediaItem(
        id: 'vault_04',
        title: '20-Week Anomaly Scan Record Copy',
        category: VaultCategory.ultrasoundScan,
        stage: PregnancyStage.pregnancy,
        caption: 'Comprehensive mid-trimester anatomical survey completed by Dr. Sharma. Normal four-chamber cardiac view, kidney symmetry, and placenta position.',
        dateLabel: '12 Dec 2026',
        isSharedWithPartner: true,
        isLocked: false,
      ),
      VaultMediaItem(
        id: 'vault_05',
        title: 'Pre-conception Pelvic Scan Baseline',
        category: VaultCategory.ultrasoundScan,
        stage: PregnancyStage.plan,
        caption: 'Baseline pelvic ultrasound showing healthy uterine lining thickness (8.2 mm) and normal bilateral ovarian follicular reserves.',
        dateLabel: '18 May 2026',
        isSharedWithPartner: true,
        isLocked: false,
      ),
      VaultMediaItem(
        id: 'vault_06',
        title: 'Baseline Thyroid & CBC Lab Report Copy',
        category: VaultCategory.medicalCopy,
        stage: PregnancyStage.plan,
        caption: 'Pre-pregnancy wellness panel: TSH 2.1 mIU/L, Hb 12.8 g/dL, Ferritin 48 ng/mL, Blood Group B+ confirmed. All vitals in prime preconception range.',
        dateLabel: '24 May 2026',
        isSharedWithPartner: true,
        isLocked: false,
      ),
      VaultMediaItem(
        id: 'vault_07',
        title: 'Positive Ovulation Surge Strip Photo',
        category: VaultCategory.milestonePhoto,
        stage: PregnancyStage.trying,
        caption: 'Dark twin line on LH ovulation test strip on Cycle Day 14. Peak fertility window logged into cycle predictions.',
        dateLabel: '06 Aug 2026',
        isSharedWithPartner: true,
        isLocked: false,
      ),
      VaultMediaItem(
        id: 'vault_08',
        title: 'Private Reflection & Fertility Journal',
        category: VaultCategory.milestonePhoto,
        stage: PregnancyStage.trying,
        caption: 'Personal quiet reflection on remaining patient and practicing mindful yoga during the two-week wait.',
        dateLabel: '18 Aug 2026',
        isSharedWithPartner: false,
        isLocked: true,
      ),
      VaultMediaItem(
        id: 'vault_09',
        title: 'Nursery Corner & Swaddle Keepsake',
        category: VaultCategory.milestonePhoto,
        stage: PregnancyStage.pregnancy,
        caption: 'Cotton cradle and handmade muslin blankets washed and arranged with care by the sunlit window.',
        dateLabel: '05 Jan 2027',
        isSharedWithPartner: true,
        isLocked: false,
      ),
      VaultMediaItem(
        id: 'vault_10',
        title: 'Newborn Tiny Footprint Keepsake',
        category: VaultCategory.milestonePhoto,
        stage: PregnancyStage.postpartum,
        caption: 'First inky footprints stamped on the hospital discharge souvenir card. Weight 3.1 kg, healthy APGAR 9/10.',
        dateLabel: '18 Feb 2027',
        isSharedWithPartner: true,
        isLocked: false,
      ),
      VaultMediaItem(
        id: 'vault_11',
        title: 'Postnatal Recovery & Stitch Care Copy',
        category: VaultCategory.medicalCopy,
        stage: PregnancyStage.postpartum,
        caption: 'Day 7 obstetric discharge summary and sitz bath antiseptic healing instructions.',
        dateLabel: '25 Feb 2027',
        isSharedWithPartner: false,
        isLocked: true,
      ),
    ];
  }

  /// Adds a new vault item.
  void addItem({
    required String title,
    required VaultCategory category,
    required PregnancyStage stage,
    required String caption,
    required String dateLabel,
    required bool isSharedWithPartner,
    bool isLocked = false,
  }) {
    final newItem = VaultMediaItem(
      id: 'vault_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      category: category,
      stage: stage,
      caption: caption.trim(),
      dateLabel: dateLabel.trim().isEmpty ? 'Today' : dateLabel.trim(),
      isSharedWithPartner: isSharedWithPartner,
      isLocked: isLocked,
    );
    state = [newItem, ...state];
  }

  /// Toggles partner sharing for an item.
  void toggleShare(String id) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(isSharedWithPartner: !item.isSharedWithPartner)
        else
          item,
    ];
  }

  /// Toggles privacy lock for an item.
  void toggleLock(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isLocked: !item.isLocked) else item,
    ];
  }

  /// Deletes an item from the vault.
  void deleteItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

/// Provider for the Media / Keepsake Vault list.
final mediaVaultProvider =
    NotifierProvider<MediaVaultNotifier, List<VaultMediaItem>>(() {
      return MediaVaultNotifier();
    });

/// Notifier for vault category filter state.
class VaultCategoryFilterNotifier extends Notifier<VaultCategoryFilter> {
  @override
  VaultCategoryFilter build() => VaultCategoryFilter.all;

  void setFilter(VaultCategoryFilter filter) {
    state = filter;
  }
}

/// Filter state provider for active category filter.
final vaultCategoryFilterProvider =
    NotifierProvider<VaultCategoryFilterNotifier, VaultCategoryFilter>(
      VaultCategoryFilterNotifier.new,
    );

/// Notifier for vault sharing filter state.
class VaultSharingFilterNotifier extends Notifier<VaultSharingFilter> {
  @override
  VaultSharingFilter build() => VaultSharingFilter.all;

  void setFilter(VaultSharingFilter filter) {
    state = filter;
  }
}

/// Filter state provider for sharing filter (All / Shared / Private).
final vaultSharingFilterProvider =
    NotifierProvider<VaultSharingFilterNotifier, VaultSharingFilter>(
      VaultSharingFilterNotifier.new,
    );
