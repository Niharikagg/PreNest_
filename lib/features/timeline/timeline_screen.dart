import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/profile_provider.dart';
import '../stage/stage.dart';
import '../stage/stage_provider.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider);
    final currentStage = ref.watch(stageProvider);
    final activePartner = couple.activePartner;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stage Switcher Segmented Button
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest
                .withOpacity(0.5),
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
                        style: Theme.of(context).textTheme.labelMedium
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
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStageIcon(currentStage),
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
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
                  const Divider(height: 24),
                  Text(
                    'Shared Goal: "${couple.sharedGoal}"',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Timeline Milestones
          Text(
            'Stage Milestones for ${activePartner.name} (${activePartner.role})',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._getMilestonesForStage(currentStage, activePartner.role).map((
            milestone,
          ) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: milestone.isDone
                      ? Colors.green.shade100
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    milestone.isDone
                        ? Icons.check
                        : Icons.radio_button_unchecked,
                    color: milestone.isDone
                        ? Colors.green.shade800
                        : Colors.grey,
                    size: 20,
                  ),
                ),
                title: Text(
                  milestone.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: milestone.isDone
                        ? TextDecoration.lineThrough
                        : null,
                    color: milestone.isDone ? Colors.grey.shade600 : null,
                  ),
                ),
                subtitle: Text(
                  milestone.subtitle,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    milestone.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

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

  static List<_MilestoneItem> _getMilestonesForStage(
    PregnancyStage stage,
    String role,
  ) {
    switch (stage) {
      case PregnancyStage.plan:
        return [
          const _MilestoneItem(
            title: 'Pre-conception Diagnostic Lab Panel',
            subtitle: 'Baseline CBC, TSH, Vitamin D, and metabolic screening',
            category: 'Diagnostics',
            isDone: true,
          ),
          const _MilestoneItem(
            title: 'Folic Acid & Micronutrient Protocol',
            subtitle: 'Daily methylfolate (400 mcg) + Vitamin D3 repletion',
            category: 'Nutrition',
            isDone: true,
          ),
          _MilestoneItem(
            title: role == 'Her'
                ? 'Reproductive Hormone Baselines (AMH, FSH)'
                : 'Male Reproductive Screening (Semen Analysis)',
            subtitle: 'Evaluating reserve markers and baseline parameters',
            category: 'Fertility',
            isDone: false,
          ),
          const _MilestoneItem(
            title: 'Lifestyle & Sleep Optimization',
            subtitle: 'Circadian alignment, gentle exercise, zero alcohol',
            category: 'Wellness',
            isDone: false,
          ),
        ];
      case PregnancyStage.trying:
        return [
          const _MilestoneItem(
            title: 'Ovulation Window Mapping',
            subtitle: 'Tracking LH surge and basal body temperature',
            category: 'Tracking',
            isDone: true,
          ),
          const _MilestoneItem(
            title: 'Peak Fertility Window Alignment',
            subtitle: 'Coordinated conception timing based on biomarker data',
            category: 'Conception',
            isDone: false,
          ),
        ];
      case PregnancyStage.pregnancy:
        return [
          const _MilestoneItem(
            title: 'First Trimester Viability Scan',
            subtitle:
                'Ultrasound confirmation and gestational age verification',
            category: 'Ultrasound',
            isDone: false,
          ),
          const _MilestoneItem(
            title: 'Maternal Blood Pressure & Glucose Checks',
            subtitle:
                'Monitoring pre-eclampsia risk & gest. diabetes baselines',
            category: 'Vitals',
            isDone: false,
          ),
        ];
      case PregnancyStage.postpartum:
        return [
          const _MilestoneItem(
            title: 'Maternal 6-Week Recovery Assessment',
            subtitle:
                'Pelvic health, wound healing and mental well-being check',
            category: 'Maternal',
            isDone: false,
          ),
          const _MilestoneItem(
            title: 'Newborn Pediatric Metabolic Screening',
            subtitle:
                'Growth percentiles, feeding metrics and immunization schedule',
            category: 'Pediatric',
            isDone: false,
          ),
        ];
    }
  }
}

class _MilestoneItem {
  final String title;
  final String subtitle;
  final String category;
  final bool isDone;

  const _MilestoneItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.isDone,
  });
}
