import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../profile/profile_provider.dart';
import '../stage/checklist_provider.dart';
import '../stage/stage.dart';
import '../stage/stage_provider.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  static IconData _getStageIcon(PregnancyStage stage) {
    switch (stage) {
      case PregnancyStage.plan:
        return Icons.event_note;
      case PregnancyStage.trying:
        return Icons.favorite;
      case PregnancyStage.pregnancy:
        return Icons.child_care;
      case PregnancyStage.postpartum:
        return Icons.family_restroom;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider);
    final currentStage = ref.watch(stageProvider);
    final activePartner = couple.activePartner;
    final checklistAsync = ref.watch(filteredChecklistProvider);
    final completedIds = ref.watch(completedChecklistProvider);
    final theme = Theme.of(context);

    final checklistItems = checklistAsync.asData?.value ?? [];
    final totalCount = checklistItems.length;
    final completedCount =
        checklistItems.where((it) => completedIds.contains(it.id)).length;
    final progress = totalCount == 0 ? 0.0 : (completedCount / totalCount);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Welcoming Hero Summary Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primaryContainer.withOpacity(0.4),
                          Colors.white,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              child: Text(
                                activePartner.initials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        activePartner.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          activePartner.role,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        _getStageIcon(currentStage),
                                        size: 14,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${currentStage.displayName} Phase Focus • ${couple.coupleName}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Checklist completion progress bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stage Checklist Progress',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '$completedCount of $totalCount completed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: completedCount == totalCount &&
                                        totalCount > 0
                                    ? Colors.green.shade700
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: theme.colorScheme.outlineVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress == 1.0
                                  ? Colors.green.shade600
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Stage Switcher Segmented Button
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
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Active Journey Stage',
                              style: theme.textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<PregnancyStage>(
                            segments: const [
                              ButtonSegment(
                                value: PregnancyStage.plan,
                                label: Text('Plan'),
                                icon: Icon(Icons.event_note, size: 16),
                              ),
                              ButtonSegment(
                                value: PregnancyStage.trying,
                                label: Text('Trying'),
                                icon: Icon(Icons.favorite_border, size: 16),
                              ),
                              ButtonSegment(
                                value: PregnancyStage.pregnancy,
                                label: Text('Pregnancy'),
                                icon: Icon(Icons.child_care, size: 16),
                              ),
                              ButtonSegment(
                                value: PregnancyStage.postpartum,
                                label: Text('Postpartum'),
                                icon: Icon(Icons.family_restroom, size: 16),
                              ),
                            ],
                            selected: {currentStage},
                            onSelectionChanged: (newSelection) {
                              ref
                                  .read(stageProvider.notifier)
                                  .setStage(newSelection.first);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Quick-Access Action Cards: "Danger-Sign Checker" & "Vitals Log"
                Row(
                  children: [
                    // Danger-Sign Checker Card
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/danger-signs'),
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Color(0xFFDC2626),
                                        size: 22,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 13,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Danger Signs',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Critical triage & 108 dispatch',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Vitals Log Card
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/vitals'),
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDFA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFCCFBF1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCCFBF1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.monitor_heart,
                                        color: Color(0xFF0F766E),
                                        size: 22,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 13,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Vitals Log',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Track BP & weight metrics',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Pregnancy Stage Action Cards: Kick Counter & Birth Plan
                if (currentStage == PregnancyStage.pregnancy) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Kick Counter Card
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/kick-counter'),
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDFA),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFCCFBF1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFCCFBF1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.touch_app_outlined,
                                          color: Color(0xFF0F766E),
                                          size: 22,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 13,
                                        color: Color(0xFF0F766E),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Kick Counter',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Log movements & timer',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Birth Plan Card
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/birth-plan'),
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFFFEDD5),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFEDD5),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.assignment_turned_in_outlined,
                                          color: Color(0xFFC2410C),
                                          size: 22,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 13,
                                        color: Color(0xFFC2410C),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Birth Plan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFFC2410C),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Facility, transport & JSY',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // Postpartum Stage Action Card: Postpartum Care (Mood Check & Newborn Vaccines)
                if (currentStage == PregnancyStage.postpartum) ...[
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push('/postpartum'),
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE9D5FF),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.family_restroom,
                                color: Color(0xFF7E22CE),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Postpartum Care & Support',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                      color: Color(0xFF6B21A8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Mood Check (EPDS) & Newborn Vaccines (UIP)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple.shade900
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Color(0xFF7E22CE),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // 4. Filtered Checklist Section
                checklistAsync.when(
                  data: (items) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${currentStage.displayName} Checklist',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: completedCount == totalCount &&
                                        totalCount > 0
                                    ? Colors.green.shade50
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: completedCount == totalCount &&
                                          totalCount > 0
                                      ? Colors.green.shade200
                                      : theme.colorScheme.outlineVariant,
                                ),
                              ),
                              child: Text(
                                '$completedCount of $totalCount completed',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: completedCount == totalCount &&
                                          totalCount > 0
                                      ? Colors.green.shade700
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (items.isEmpty)
                          Card(
                            elevation: 0,
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(28.0),
                              child: Center(
                                child: Text(
                                  'No checklist items configured for this stage and profile.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          )
                        else
                          ...items.map((item) {
                            final isDone = completedIds.contains(item.id);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isDone
                                      ? const Color(0xFFBBF7D0)
                                      : theme.colorScheme.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              color: isDone
                                  ? const Color(0xFFF0FDF4)
                                  : Colors.white,
                              child: CheckboxListTile(
                                value: isDone,
                                onChanged: (_) {
                                  ref
                                      .read(completedChecklistProvider.notifier)
                                      .toggle(item.id);
                                },
                                activeColor: const Color(0xFF059669),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isDone
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDone
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                secondary: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isDone
                                      ? const Color(0xFFDCFCE7)
                                      : theme.colorScheme
                                          .surfaceContainerHighest,
                                  child: Icon(
                                    isDone
                                        ? Icons.check
                                        : Icons.assignment_outlined,
                                    size: 18,
                                    color: isDone
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                              ),
                            );
                          }),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Failed to load checklist: $err'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.push('/advisor'),
      icon: const Icon(Icons.support_agent),
      label: const Text('AI Advisor'),
    ),
  );
}
}
