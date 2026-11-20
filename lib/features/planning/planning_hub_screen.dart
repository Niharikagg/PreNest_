import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import 'planning_provider.dart';

class PlanningHubScreen extends ConsumerWidget {
  const PlanningHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(planningProvider);
    final notifier = ref.read(planningProvider.notifier);
    final theme = Theme.of(context);

    // Filter preconception tasks based on partner focus
    final filteredTasks = kPreconceptionTasks.where((task) {
      if (state.partnerFocus == 'Both') return true;
      if (state.partnerFocus == 'For Her') {
        return task.targetRole == 'Her' || task.targetRole == 'Both';
      }
      if (state.partnerFocus == 'For Him') {
        return task.targetRole == 'Him' || task.targetRole == 'Both';
      }
      return true;
    }).toList();

    final taskCompletedCount = filteredTasks
        .where((t) => state.taskCompletions[t.id] ?? false)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Planning for Pregnancy Hub')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Stage Readiness Toggle: Preparing Ahead vs Actively Trying
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFBF1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.spa_outlined,
                                color: AppTheme.primaryTeal,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Conception Readiness Stage',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.isActivelyTrying
                                        ? 'Focused on cycle timing, ovulation tracking & active conception.'
                                        : 'Focusing on 3–6 month lifestyle preparation & lab baselines.',
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
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                value: false,
                                label: Text('Preparing Ahead (3–6m)'),
                                icon: Icon(
                                  Icons.calendar_month_outlined,
                                  size: 16,
                                ),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text('Actively Trying'),
                                icon: Icon(Icons.favorite_outline, size: 16),
                              ),
                            ],
                            selected: {state.isActivelyTrying},
                            onSelectionChanged: (selection) {
                              notifier.setActivelyTrying(selection.first);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Shared Partner Focus: Both, For Her, For Him
                Card(
                  elevation: 0,
                  color: const Color(0xFFF0FDFA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFF99F6E4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Partner Focus Area',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.primaryTealDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFBF1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Couple Care',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Healthy conception is a 50/50 shared journey. Filter habits and clinical checklists by focus:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryTealDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: ['Both', 'For Her', 'For Him'].map((focus) {
                            final isSelected = state.partnerFocus == focus;
                            return ChoiceChip(
                              label: Text(focus),
                              selected: isSelected,
                              selectedColor: AppTheme.primaryTeal,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textDark,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primaryTeal
                                    : const Color(0xFF99F6E4),
                              ),
                              onSelected: (_) {
                                notifier.setPartnerFocus(focus);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Daily Preconception Habits
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Habits Checklist',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.completedHabitCount} of ${state.totalHabitCount} completed today',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (state.completedHabitCount > 0)
                      TextButton(
                        onPressed: notifier.resetDailyHabits,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Reset Today',
                          style: TextStyle(fontSize: 11.5),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: state.habitProgress,
                    minHeight: 8,
                    backgroundColor: AppTheme.surfaceMuted,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      state.habitProgress == 1.0
                          ? AppTheme.successGreen
                          : AppTheme.primaryTeal,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                ...kDailyPlanningHabits.map((habit) {
                  final isDone = state.habitCompletions[habit.id] ?? false;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: isDone ? const Color(0xFFF0FDF4) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDone
                            ? const Color(0xFFBBF7D0)
                            : AppTheme.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: isDone,
                            activeColor: AppTheme.successGreen,
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? const Color(0xFFDCFCE7)
                                    : AppTheme.surfaceMuted,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                habit.icon,
                                size: 20,
                                color: isDone
                                    ? AppTheme.successGreen
                                    : AppTheme.primaryTeal,
                              ),
                            ),
                            title: Text(
                              habit.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDone
                                    ? const Color(0xFF166534)
                                    : AppTheme.textDark,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                habit.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDone
                                      ? const Color(0xFF15803D).withOpacity(0.8)
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ),
                            onChanged: (_) {
                              notifier.toggleHabit(habit.id);
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 6, bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? const Color(0xFFE8F5E9)
                                  : AppTheme.surfaceMuted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.menu_book_outlined,
                                  size: 13,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    habit.evidenceNote,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: AppTheme.textMuted,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // 4. Preconception Clinical Checklist & Lab Baselines
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preconception Clinical Baselines',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$taskCompletedCount / ${filteredTasks.length} Checked',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            taskCompletedCount == filteredTasks.length &&
                                filteredTasks.isNotEmpty
                            ? AppTheme.successGreen
                            : AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Recommended clinical assessments to evaluate with your physician before trying to conceive.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),

                ...filteredTasks.map((task) {
                  final isDone = state.taskCompletions[task.id] ?? false;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0,
                    color: isDone ? const Color(0xFFF0FDF4) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDone
                            ? const Color(0xFFBBF7D0)
                            : AppTheme.borderLight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: isDone,
                            activeColor: AppTheme.successGreen,
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: isDone
                                          ? const Color(0xFF166534)
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: task.targetRole == 'Her'
                                        ? const Color(0xFFFFE4E6)
                                        : task.targetRole == 'Him'
                                        ? const Color(0xFFE0F2FE)
                                        : const Color(0xFFCCFBF1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    task.targetRole,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: task.targetRole == 'Her'
                                          ? AppTheme.warmRoseDark
                                          : task.targetRole == 'Him'
                                          ? const Color(0xFF0369A1)
                                          : AppTheme.primaryTealDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                task.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDone
                                      ? const Color(0xFF15803D).withOpacity(0.8)
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ),
                            onChanged: (_) {
                              notifier.toggleTask(task.id);
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4, bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceMuted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 13,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    task.evidenceNote,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Gentle disclaimer note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'PreNest is strictly an informational tool. Never start, change, or stop supplements or medications '
                          'without clinical supervision. Always consult your gynecologist or healthcare professional for individualized preconception guidance.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
