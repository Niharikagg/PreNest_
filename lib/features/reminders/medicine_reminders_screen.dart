import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/profile_provider.dart';
import '../stage/stage.dart';
import '../stage/stage_provider.dart';
import 'medicine_reminders_provider.dart';

class MedicineRemindersScreen extends ConsumerStatefulWidget {
  const MedicineRemindersScreen({super.key});

  @override
  ConsumerState<MedicineRemindersScreen> createState() =>
      _MedicineRemindersScreenState();
}

class _MedicineRemindersScreenState
    extends ConsumerState<MedicineRemindersScreen> {
  // Filter: null means show all stages, otherwise filter by specific PregnancyStage
  PregnancyStage? _filterStage;
  bool _showOnlyCurrentStage = true;

  @override
  Widget build(BuildContext context) {
    final couple = ref.watch(coupleProvider);
    final currentStage = ref.watch(stageProvider);
    final allReminders = ref.watch(medicineRemindersProvider);
    final activePartner = couple.activePartner;
    final otherPartner = couple.otherPartner;
    final theme = Theme.of(context);

    // Apply partner data sharing filter:
    // Shared reminders (isSharedWithPartner == true) are visible to both.
    // Private reminders are only visible to the owner.
    final partnerVisibleReminders = allReminders.where((r) {
      if (r.isSharedWithPartner) return true;
      if (r.partnerOwnerId == 'all') return true;
      return r.partnerOwnerId == activePartner.id;
    }).toList();

    // Stage filter:
    final effectiveStage = _showOnlyCurrentStage
        ? (_filterStage ?? currentStage)
        : _filterStage;

    final displayedReminders = partnerVisibleReminders.where((r) {
      if (effectiveStage == null) return true;
      // Reminders with stageScope == null apply to all stages
      return r.stageScope == null || r.stageScope == effectiveStage;
    }).toList();

    final takenCount = displayedReminders.where((r) => r.takenToday).length;
    final totalCount = displayedReminders.length;
    final progress = totalCount > 0 ? (takenCount / totalCount) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medicine & Supplement Reminders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${activePartner.name} (${activePartner.role}) • ${currentStage.displayName}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            onPressed: () {
              ref.read(coupleProvider.notifier).togglePartner();
            },
            icon: const Icon(Icons.switch_account_outlined, size: 16),
            label: Text(
              'View as ${otherPartner.name}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Mandatory gentle clinical advisory banner
              Card(
                elevation: 0,
                color: const Color(0xFFF0FDF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFBBF7D0), width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        color: Color(0xFF15803D),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Doctor-Advised Schedule Companion',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF166534),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Reminders help you stay on schedule with what your doctor has advised—never self-adjust doses without consulting your doctor.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Adherence Summary Card
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFFCCFBF1),
                                child: const Icon(
                                  Icons.medication_rounded,
                                  size: 18,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Today's Schedule Adherence",
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _showOnlyCurrentStage
                                        ? '${currentStage.displayName} stage focus'
                                        : 'All registered stages',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: takenCount == totalCount && totalCount > 0
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$takenCount / $totalCount Taken',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    takenCount == totalCount && totalCount > 0
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFF0F766E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0
                                ? const Color(0xFF059669)
                                : const Color(0xFF0F766E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Shared reminders are visible on both ${couple.coupleName} dashboards.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      selected: _showOnlyCurrentStage,
                      label: Text(
                        'Current Stage (${currentStage.displayName})',
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _showOnlyCurrentStage = selected;
                          if (selected) {
                            _filterStage = currentStage;
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: !_showOnlyCurrentStage && _filterStage == null,
                      label: const Text('All Stages'),
                      onSelected: (selected) {
                        setState(() {
                          _showOnlyCurrentStage = false;
                          _filterStage = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...PregnancyStage.values.map((stage) {
                      final isSelected =
                          !_showOnlyCurrentStage && _filterStage == stage;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(stage.displayName),
                          onSelected: (selected) {
                            setState(() {
                              _showOnlyCurrentStage = false;
                              _filterStage = selected ? stage : null;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Reminders list
              if (displayedReminders.isEmpty)
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 36,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No reminders for this filter.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...displayedReminders.map((reminder) {
                  return _buildReminderCard(
                    context,
                    reminder,
                    theme,
                    otherPartner,
                  );
                }),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    MedicineReminder reminder,
    ThemeData theme,
    PartnerProfile otherPartner,
  ) {
    final isDone = reminder.takenToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDone ? const Color(0xFFF8FAFC) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDone
              ? const Color(0xFFBBF7D0)
              : theme.colorScheme.outlineVariant,
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Taken toggle checkbox button
                IconButton(
                  onPressed: () {
                    ref
                        .read(medicineRemindersProvider.notifier)
                        .toggleTaken(reminder.id);
                  },
                  icon: Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isDone
                        ? const Color(0xFF059669)
                        : theme.colorScheme.outline,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reminder.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDone
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          // Stage pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: reminder.stageScope != null
                                  ? const Color(0xFFE0F2FE)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              reminder.stageScope?.displayName ?? 'All Modes',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: reminder.stageScope != null
                                    ? const Color(0xFF0369A1)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reminder.scheduleLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (reminder.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reminder.notes,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 6),
            Row(
              children: [
                // Partner sharing indicator & toggle
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    ref
                        .read(medicineRemindersProvider.notifier)
                        .toggleSharedWithPartner(reminder.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          reminder.isSharedWithPartner
                              ? Icons.favorite_rounded
                              : Icons.lock_outline_rounded,
                          size: 14,
                          color: reminder.isSharedWithPartner
                              ? const Color(0xFFE11D48)
                              : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          reminder.isSharedWithPartner
                              ? 'Shared with ${otherPartner.name}'
                              : 'Private to you',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: reminder.isSharedWithPartner
                                ? const Color(0xFFBE123C)
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Delete button
                IconButton(
                  tooltip: 'Delete reminder',
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.grey.shade500,
                  onPressed: () {
                    ref
                        .read(medicineRemindersProvider.notifier)
                        .deleteReminder(reminder.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final scheduleController = TextEditingController();
    final notesController = TextEditingController();
    PregnancyStage? selectedStage = ref.read(stageProvider);
    bool isShared = true;
    final activePartnerId = ref.read(coupleProvider).activePartner.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                    MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Medicine / Supplement',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              Navigator.of(bottomSheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Doctor-advised reminder only. Never self-adjust medications.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medicine / Supplement Name',
                        hintText: 'e.g., Folic acid, IFA, Calcium, Inositol',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: scheduleController,
                      decoration: const InputDecoration(
                        labelText: 'Schedule / Timing',
                        hintText: 'e.g., Morning • After breakfast',
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Quick schedule chips
                    Wrap(
                      spacing: 8,
                      children:
                          [
                            'Morning • After breakfast',
                            'Afternoon • Post lunch',
                            'Evening • After dinner',
                            'Night • Before bedtime',
                          ].map((preset) {
                            return ActionChip(
                              label: Text(
                                preset,
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  scheduleController.text = preset;
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<PregnancyStage?>(
                      value: selectedStage,
                      decoration: const InputDecoration(
                        labelText: 'Applicable Stage',
                      ),
                      items: [
                        const DropdownMenuItem<PregnancyStage?>(
                          value: null,
                          child: Text('All Journey Stages'),
                        ),
                        ...PregnancyStage.values.map(
                          (s) => DropdownMenuItem<PregnancyStage?>(
                            value: s,
                            child: Text(s.displayName),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          selectedStage = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Doctor Advice / Absorption Note',
                        hintText: 'e.g., Take with lemon water, keep 2h gap from calcium',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Share with partner',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Displays on both partner dashboards for supportive adherence',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      value: isShared,
                      activeColor: const Color(0xFF0F766E),
                      onChanged: (val) {
                        setModalState(() {
                          isShared = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) return;
                          final schedule =
                              scheduleController.text.trim().isEmpty
                              ? 'Daily as advised'
                              : scheduleController.text.trim();

                          ref
                              .read(medicineRemindersProvider.notifier)
                              .addReminder(
                                name: nameController.text.trim(),
                                scheduleLabel: schedule,
                                stageScope: selectedStage,
                                isSharedWithPartner: isShared,
                                notes: notesController.text.trim(),
                                partnerOwnerId: activePartnerId,
                              );
                          Navigator.of(bottomSheetContext).pop();
                        },
                        child: const Text('Save Reminder'),
                      ),
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
}
