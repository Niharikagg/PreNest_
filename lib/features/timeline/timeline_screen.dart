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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Stage Switcher Segmented Button at top
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Active Journey Stage',
                        style: theme.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
          const SizedBox(height: 16),

          // Current Stage Overview Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStageIcon(currentStage),
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${currentStage.displayName} Phase Focus',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              currentStage.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Viewing for: ${activePartner.name} (${activePartner.role})',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        couple.coupleName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Quick-Access Action Cards: "Danger-Sign Checker" & "Vitals Log (BP & Weight)"
          Text(
            'Quick-Access Care Tools',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Danger-Sign Checker Card
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/danger-signs'),
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.error.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.colorScheme.error,
                                  size: 22,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Danger-Sign Checker',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Critical symptoms & 108 emergency triage',
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
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.monitor_heart,
                                  color: theme.colorScheme.primary,
                                  size: 22,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Vitals Log',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track blood pressure & weight metrics',
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
          const SizedBox(height: 24),

          // 3. Filtered Checklist Section
          checklistAsync.when(
            data: (items) {
              final totalCount = items.length;
              final completedCount =
                  items.where((it) => completedIds.contains(it.id)).length;
              final progress =
                  totalCount == 0 ? 0.0 : (completedCount / totalCount);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${currentStage.displayName} Checklist (${activePartner.name})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '$completedCount of $totalCount done',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: completedCount == totalCount && totalCount > 0
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0
                            ? Colors.green.shade600
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(24.0),
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
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDone
                                ? Colors.green.shade200
                                : Colors.grey.shade200,
                          ),
                        ),
                        color: isDone
                            ? Colors.green.shade50.withOpacity(0.4)
                            : theme.colorScheme.surface,
                        child: CheckboxListTile(
                          value: isDone,
                          onChanged: (_) {
                            ref
                                .read(completedChecklistProvider.notifier)
                                .toggle(item.id);
                          },
                          activeColor: Colors.green.shade600,
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isDone ? Colors.grey.shade600 : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          secondary: CircleAvatar(
                            radius: 16,
                            backgroundColor: isDone
                                ? Colors.green.shade100
                                : theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              isDone ? Icons.check : Icons.assignment_outlined,
                              size: 18,
                              color: isDone
                                  ? Colors.green.shade800
                                  : Colors.grey.shade700,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      );
                    }),
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
    );
  }
}
