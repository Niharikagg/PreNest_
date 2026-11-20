import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../profile/profile_provider.dart';
import '../stage/stage.dart';
import '../stage/stage_provider.dart';
import 'media_vault_provider.dart';

class MediaVaultScreen extends ConsumerStatefulWidget {
  const MediaVaultScreen({super.key});

  @override
  ConsumerState<MediaVaultScreen> createState() => _MediaVaultScreenState();
}

class _MediaVaultScreenState extends ConsumerState<MediaVaultScreen> {
  PregnancyStage? _selectedStageFilter;

  @override
  Widget build(BuildContext context) {
    final vaultItems = ref.watch(mediaVaultProvider);
    final categoryFilter = ref.watch(vaultCategoryFilterProvider);
    final sharingFilter = ref.watch(vaultSharingFilterProvider);
    final couple = ref.watch(coupleProvider);
    final activeStage = ref.watch(stageProvider);
    final theme = Theme.of(context);

    // Apply filtering
    final filteredItems = vaultItems.where((item) {
      if (!categoryFilter.matches(item.category)) return false;
      if (sharingFilter == VaultSharingFilter.sharedOnly &&
          !item.isSharedWithPartner) {
        return false;
      }
      if (sharingFilter == VaultSharingFilter.privateOnly &&
          item.isSharedWithPartner) {
        return false;
      }
      if (_selectedStageFilter != null && item.stage != _selectedStageFilter) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Keepsake & Media Vault'),
        actions: [
          IconButton(
            tooltip: 'Security & Lock Settings',
            icon: const Icon(
              Icons.shield_rounded,
              color: AppTheme.primaryTeal,
            ),
            onPressed: () => context.push('/privacy-sync'),
          ),
          IconButton(
            tooltip: 'Add Keepsake or Record',
            icon: const Icon(Icons.add_photo_alternate_rounded),
            onPressed: () => _showAddItemSheet(context, activeStage),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              // 1. Informational & Keepsake Medical Notice Banner
              _buildClinicalNoticeBanner(),

              // 2. Filter Controls (Category Chips & Sharing Segment)
              _buildFilterSection(categoryFilter, sharingFilter, vaultItems),

              const Divider(height: 1, thickness: 1),

              // 3. Vault Media Items List
              Expanded(
                child: filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildVaultItemCard(
                            context: context,
                            item: item,
                            couple: couple,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Keepsake',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddItemSheet(context, activeStage),
      ),
    );
  }

  Widget _buildClinicalNoticeBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFF475569),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Record-Keeping & Keepsake Only',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Media files are stored for your personal memories and doctor visits. PreNest does not perform AI diagnostics on ultrasound images. Always consult a qualified radiologist.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    VaultCategoryFilter categoryFilter,
    VaultSharingFilter sharingFilter,
    List<VaultMediaItem> vaultItems,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryFilterChip(
                  filter: VaultCategoryFilter.all,
                  current: categoryFilter,
                  icon: Icons.all_inclusive_rounded,
                ),
                const SizedBox(width: 8),
                _buildCategoryFilterChip(
                  filter: VaultCategoryFilter.ultrasounds,
                  current: categoryFilter,
                  icon: Icons.sensors_rounded,
                ),
                const SizedBox(width: 8),
                _buildCategoryFilterChip(
                  filter: VaultCategoryFilter.milestonesAndVideos,
                  current: categoryFilter,
                  icon: Icons.photo_camera_back_rounded,
                ),
                const SizedBox(width: 8),
                _buildCategoryFilterChip(
                  filter: VaultCategoryFilter.medicalCopies,
                  current: categoryFilter,
                  icon: Icons.receipt_long_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Sharing status segmented toggle & stage dropdown
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: SegmentedButton<VaultSharingFilter>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    segments: [
                      ButtonSegment(
                        value: VaultSharingFilter.all,
                        label: Text(
                          'All (${vaultItems.length})',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      const ButtonSegment(
                        value: VaultSharingFilter.sharedOnly,
                        label: Text('Shared', style: TextStyle(fontSize: 11)),
                      ),
                      const ButtonSegment(
                        value: VaultSharingFilter.privateOnly,
                        label: Text('Private', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                    selected: {sharingFilter},
                    onSelectionChanged: (val) {
                      ref
                          .read(vaultSharingFilterProvider.notifier)
                          .setFilter(val.first);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Stage filter filter chip
              PopupMenuButton<PregnancyStage?>(
                tooltip: 'Filter by Stage',
                initialValue: _selectedStageFilter,
                onSelected: (stage) {
                  setState(() {
                    _selectedStageFilter = stage;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedStageFilter != null
                        ? AppTheme.primaryTealLight
                        : Colors.white,
                    border: Border.all(
                      color: _selectedStageFilter != null
                          ? AppTheme.primaryTeal
                          : AppTheme.borderLight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        size: 14,
                        color: _selectedStageFilter != null
                            ? AppTheme.primaryTealDark
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedStageFilter?.displayName ?? 'All Stages',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _selectedStageFilter != null
                              ? AppTheme.primaryTealDark
                              : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem<PregnancyStage?>(
                    value: null,
                    child: Text('All Stages'),
                  ),
                  const PopupMenuItem(
                    value: PregnancyStage.plan,
                    child: Text('Planning Stage'),
                  ),
                  const PopupMenuItem(
                    value: PregnancyStage.trying,
                    child: Text('Trying Stage'),
                  ),
                  const PopupMenuItem(
                    value: PregnancyStage.pregnancy,
                    child: Text('Pregnancy Stage'),
                  ),
                  const PopupMenuItem(
                    value: PregnancyStage.postpartum,
                    child: Text('Postpartum Stage'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterChip({
    required VaultCategoryFilter filter,
    required VaultCategoryFilter current,
    required IconData icon,
  }) {
    final isSelected = filter == current;
    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 15,
        color: isSelected ? Colors.white : AppTheme.primaryTeal,
      ),
      label: Text(
        filter.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textDark,
        ),
      ),
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryTeal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryTeal : AppTheme.borderLight,
        ),
      ),
      onSelected: (_) {
        ref.read(vaultCategoryFilterProvider.notifier).setFilter(filter);
      },
    );
  }

  Widget _buildVaultItemCard({
    required BuildContext context,
    required VaultMediaItem item,
    required CoupleState couple,
  }) {
    final theme = Theme.of(context);
    final isLockedLocked = item.isLocked;

    final Color badgeColor;
    final Color badgeBg;
    final IconData categoryIcon;

    switch (item.category) {
      case VaultCategory.ultrasoundScan:
        badgeColor = const Color(0xFF0F766E);
        badgeBg = const Color(0xFFCCFBF1);
        categoryIcon = Icons.sensors_rounded;
        break;
      case VaultCategory.milestonePhoto:
        badgeColor = const Color(0xFFE11D48);
        badgeBg = const Color(0xFFFFE4E6);
        categoryIcon = Icons.photo_camera_back_rounded;
        break;
      case VaultCategory.videoClip:
        badgeColor = const Color(0xFF0284C7);
        badgeBg = const Color(0xFFE0F2FE);
        categoryIcon = Icons.play_circle_fill_rounded;
        break;
      case VaultCategory.medicalCopy:
        badgeColor = const Color(0xFFD97706);
        badgeBg = const Color(0xFFFEF3C7);
        categoryIcon = Icons.receipt_long_rounded;
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderLight, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleItemTap(context, item),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Icon Box
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: badgeColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Icon(
                    isLockedLocked ? Icons.lock_rounded : categoryIcon,
                    color: badgeColor,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Item Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Tag & Stage & Date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category.shortTag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.stage.displayName,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.dateLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Caption preview
                    Text(
                      isLockedLocked
                          ? 'This keepsake is locked with PIN protection.'
                          : item.caption,
                      style: TextStyle(
                        fontSize: 12,
                        color: isLockedLocked
                            ? const Color(0xFF94A3B8)
                            : AppTheme.textDark.withOpacity(0.8),
                        fontStyle: isLockedLocked
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Bottom Row: Sharing Pill & Lock Status
                    Row(
                      children: [
                        // Sharing status pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: item.isSharedWithPartner
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: item.isSharedWithPartner
                                  ? const Color(0xFFBBF7D0)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.isSharedWithPartner
                                    ? Icons.people_alt_rounded
                                    : Icons.lock_person_rounded,
                                size: 12,
                                color: item.isSharedWithPartner
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.isSharedWithPartner
                                    ? 'Shared with ${couple.otherPartner.name}'
                                    : 'Private to You',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: item.isSharedWithPartner
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Lock indicator
                        if (item.isLocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 11,
                                  color: Color(0xFFBE123C),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'PIN Locked',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFBE123C),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppTheme.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleItemTap(
    BuildContext context,
    VaultMediaItem item,
  ) async {
    if (item.isLocked) {
      final security = ref.read(appSecurityServiceProvider);
      final unlocked = await security.authenticate(
        reason: 'Authenticate to view locked keepsake',
      );
      if (!unlocked || !mounted) return;
    }
    if (mounted) {
      _showItemDetailSheet(context, item);
    }
  }

  void _showItemDetailSheet(BuildContext context, VaultMediaItem currentItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, watchRef, child) {
            // Re-watch item from provider
            final allItems = watchRef.watch(mediaVaultProvider);
            final item = allItems.firstWhere(
              (it) => it.id == currentItem.id,
              orElse: () => currentItem,
            );
            final couple = watchRef.watch(coupleProvider);

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Detail Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTealLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.photo_library_rounded,
                          color: AppTheme.primaryTeal,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.category.displayName} • ${item.stage.displayName} • ${item.dateLabel}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Caption / Notes container
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Keepsake Note & Clinical Summary',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.caption,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Interactive Controls: Sharing with Partner & App Lock
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          secondary: const Icon(
                            Icons.people_alt_rounded,
                            color: AppTheme.primaryTeal,
                          ),
                          title: const Text(
                            'Share with Partner',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            item.isSharedWithPartner
                                ? 'Visible on ${couple.otherPartner.name}\'s linked account'
                                : 'Kept strictly in your personal private vault',
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          value: item.isSharedWithPartner,
                          onChanged: (_) {
                            ref
                                .read(mediaVaultProvider.notifier)
                                .toggleShare(item.id);
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          secondary: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFFBE123C),
                          ),
                          title: const Text(
                            'Require PIN Lock',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Protects this keepsake behind app security PIN',
                            style: TextStyle(fontSize: 11.5),
                          ),
                          value: item.isLocked,
                          onChanged: (_) {
                            ref
                                .read(mediaVaultProvider.notifier)
                                .toggleLock(item.id);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Bottom Action Buttons: Delete & Done
                  Row(
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                        ),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('Delete'),
                        onPressed: () {
                          ref
                              .read(mediaVaultProvider.notifier)
                              .deleteItem(item.id);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Removed "${item.title}" from vault.',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddItemSheet(BuildContext context, PregnancyStage initialStage) {
    final titleController = TextEditingController();
    final captionController = TextEditingController();
    final dateController = TextEditingController(
      text: 'Today, ${_formatToday()}',
    );
    VaultCategory selectedCategory = VaultCategory.ultrasoundScan;
    PregnancyStage selectedStage = initialStage;
    bool isSharedWithPartner = true;
    bool isLocked = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final couple = ref.watch(coupleProvider);

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          color: AppTheme.primaryTeal,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Add Keepsake or Scan Note',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Keepsake Title *',
                        hintText: 'e.g. 24-Week Scan Note, Bump Picture...',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Selector
                    DropdownButtonFormField<VaultCategory>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: VaultCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Stage Selector
                    DropdownButtonFormField<PregnancyStage>(
                      value: selectedStage,
                      decoration: const InputDecoration(
                        labelText: 'Stage Scope',
                      ),
                      items: PregnancyStage.values.map((stage) {
                        return DropdownMenuItem(
                          value: stage,
                          child: Text(stage.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => selectedStage = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Date Label
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date or Milestone Label',
                        hintText: 'e.g., 20 Nov 2026',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Caption / Notes
                    TextField(
                      controller: captionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Memories, Findings, or Doctor Notes',
                        hintText: 'Notes on measurements, feelings, heartbeat, or milestones...',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Sharing & Security Switches
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Share with ${couple.otherPartner.name}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Turn off to keep this strictly in your private view',
                        style: TextStyle(fontSize: 11.5),
                      ),
                      value: isSharedWithPartner,
                      onChanged: (v) =>
                          setSheetState(() => isSharedWithPartner = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Lock with App PIN',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Requires 4-digit PIN lock when opened',
                        style: TextStyle(fontSize: 11.5),
                      ),
                      value: isLocked,
                      onChanged: (v) => setSheetState(() => isLocked = v),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final title = titleController.text.trim();
                              if (title.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a title.'),
                                  ),
                                );
                                return;
                              }
                              ref
                                  .read(mediaVaultProvider.notifier)
                                  .addItem(
                                    title: title,
                                    category: selectedCategory,
                                    stage: selectedStage,
                                    caption: captionController.text.trim(),
                                    dateLabel: dateController.text.trim(),
                                    isSharedWithPartner: isSharedWithPartner,
                                    isLocked: isLocked,
                                  );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added "$title" to your vault!',
                                  ),
                                  backgroundColor: AppTheme.primaryTeal,
                                ),
                              );
                            },
                            child: const Text('Save Keepsake'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'No keepsakes match this filter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing category or sharing filter, or tap "Add Keepsake" below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatToday() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
