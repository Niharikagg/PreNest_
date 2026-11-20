import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/tts_service.dart';
import 'anc_planner_provider.dart';

class AncPlannerScreen extends ConsumerWidget {
  const AncPlannerScreen({super.key});

  String _formatDate(DateTime dt) {
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
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $hour:$minute $period';
  }

  void _showEditNotesDialog(
    BuildContext context,
    WidgetRef ref,
    AncVisit visit,
  ) {
    final controller = TextEditingController(text: visit.doctorNotes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Doctor\'s Notes — ${visit.weekRange}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Record observations, advice, or scan findings shared during your appointment:',
              style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. Normal BP 110/70, Hb 12.1, fetal heartbeat 142 bpm...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(ancPlannerProvider.notifier)
                  .updateDoctorNotes(visit.id, controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save Notes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ancPlannerProvider);
    final notifier = ref.read(ancPlannerProvider.notifier);
    final currentLang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    // Group visits by trimester
    final t1Visits = state.visits.where((v) => v.trimester == 1).toList();
    final t2Visits = state.visits.where((v) => v.trimester == 2).toList();
    final t3Visits = state.visits.where((v) => v.trimester == 3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t('ANC Visit Planner', currentLang)),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_outlined),
            tooltip: AppStrings.t('Read aloud', currentLang),
            onPressed: () {
              ref
                  .read(ttsServiceProvider)
                  .speak(
                    'Antenatal Care Visit Planner. Tracks 4 recommended clinical checkups across trimesters '
                    'and daily Iron and Calcium intake. Always confirm schedules with your doctor or MCP card.',
                    currentLang,
                  );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Dedicated Daily IFA & Calcium Milestone Card (Non-Dosing Reminder)
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color(0xFF0F766E),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
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
                                Icons.medication_liquid_rounded,
                                color: AppTheme.primaryTeal,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Daily IFA & Calcium Tracker',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          'Today\'s Goal',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.successGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Doctor-advised daily micronutrient habits',
                                    style: TextStyle(
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

                        // Important Absorption Guidance Callout
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 17,
                                color: Color(0xFFD97706),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Absorption Guideline: Take Iron (IFA) and Calcium at least 2 hours apart with water. '
                                  'Never swallow them together or with tea/milk, as Calcium reduces Iron absorption. Non-dosing reminder; always follow your doctor\'s prescription.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF92400E),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Two Checkboxes: IFA & Calcium
                        Row(
                          children: [
                            // IFA Checkbox Card
                            Expanded(
                              child: InkWell(
                                onTap: () => notifier.toggleIfaToday(),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: state.ifaTakenToday
                                        ? const Color(0xFFF0FDF4)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: state.ifaTakenToday
                                          ? const Color(0xFF86EFAC)
                                          : AppTheme.borderLight,
                                      width: state.ifaTakenToday ? 1.4 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        state.ifaTakenToday
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                  .radio_button_unchecked_rounded,
                                        color: state.ifaTakenToday
                                            ? AppTheme.successGreen
                                            : AppTheme.textMuted,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Daily IFA (Iron)',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              state.ifaTakenToday
                                                  ? 'Logged today'
                                                  : 'Tap to log',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: state.ifaTakenToday
                                                    ? AppTheme.successGreen
                                                    : AppTheme.textMuted,
                                                fontWeight: state.ifaTakenToday
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Calcium Checkbox Card
                            Expanded(
                              child: InkWell(
                                onTap: () => notifier.toggleCalciumToday(),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: state.calciumTakenToday
                                        ? const Color(0xFFF0FDF4)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: state.calciumTakenToday
                                          ? const Color(0xFF86EFAC)
                                          : AppTheme.borderLight,
                                      width: state.calciumTakenToday ? 1.4 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        state.calciumTakenToday
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                  .radio_button_unchecked_rounded,
                                        color: state.calciumTakenToday
                                            ? AppTheme.successGreen
                                            : AppTheme.textMuted,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Daily Calcium',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              state.calciumTakenToday
                                                  ? 'Logged today'
                                                  : 'Tap to log',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: state.calciumTakenToday
                                                    ? AppTheme.successGreen
                                                    : AppTheme.textMuted,
                                                fontWeight:
                                                    state.calciumTakenToday
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Schedule Progress & Guidance Banner
                Card(
                  elevation: 0,
                  color: const Color(0xFFF0FDFA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF99F6E4), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFBF1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: AppTheme.primaryTeal,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Government of India (MoHFW) & WHO Schedule',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: AppTheme.primaryTealDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'PreNest organizes the 4 essential Antenatal Care checkups by trimester. '
                                    'Always confirm exact appointment dates, scans, and lab orders with your obstetrician or MCP card.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.grey.shade800,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${state.completedVisitsCount} of ${state.totalVisitsCount} Visits Logged',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTealDark,
                              ),
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.warmRose,
                                side: const BorderSide(
                                  color: Color(0xFFFECDD3),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: const Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                              ),
                              label: const Text(
                                'Danger Signs',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () => context.push('/danger-signs'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: state.progressFraction,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFCCFBF1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // 3. Trimester 1 Section
                _buildTrimesterHeader(
                  title: 'Trimester 1 (Weeks 1–13)',
                  subtitle: 'Early Registration & Baseline Organogenesis',
                  badge: 'Weeks 8–12',
                  accentColor: const Color(0xFF0F766E),
                  containerColor: const Color(0xFFCCFBF1),
                ),
                const SizedBox(height: 10),
                ...t1Visits.map(
                  (visit) => _buildVisitCard(
                    context: context,
                    ref: ref,
                    visit: visit,
                    accentColor: const Color(0xFF0F766E),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Trimester 2 Section
                _buildTrimesterHeader(
                  title: 'Trimester 2 (Weeks 14–27)',
                  subtitle: 'TIFFA Scan, Glucose Tolerance & Growth',
                  badge: 'Weeks 14–26',
                  accentColor: const Color(0xFF0284C7),
                  containerColor: const Color(0xFFE0F2FE),
                ),
                const SizedBox(height: 10),
                ...t2Visits.map(
                  (visit) => _buildVisitCard(
                    context: context,
                    ref: ref,
                    visit: visit,
                    accentColor: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Trimester 3 Section
                _buildTrimesterHeader(
                  title: 'Trimester 3 (Weeks 28–40)',
                  subtitle:
                      'Preeclampsia Check, Fetal Kicks & Birth Preparedness',
                  badge: 'Weeks 28–38',
                  accentColor: const Color(0xFF7C3AED),
                  containerColor: const Color(0xFFF3E8FF),
                ),
                const SizedBox(height: 10),
                ...t3Visits.map(
                  (visit) => _buildVisitCard(
                    context: context,
                    ref: ref,
                    visit: visit,
                    accentColor: const Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 24),

                // 6. Gentle Clinical Disclaimer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Informational screening only. Never diagnose, prescribe, or give dosing. Always confirm schedules, ultrasound scan dates, and supplements with your obstetrician, ANM, or MCP card.',
                          style: TextStyle(
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
        ),
      ),
    );
  }

  Widget _buildTrimesterHeader({
    required String title,
    required String subtitle,
    required String badge,
    required Color accentColor,
    required Color containerColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitCard({
    required BuildContext context,
    required WidgetRef ref,
    required AncVisit visit,
    required Color accentColor,
  }) {
    final notifier = ref.read(ancPlannerProvider.notifier);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: visit.isCompleted
              ? const Color(0xFF86EFAC)
              : AppTheme.borderLight,
          width: visit.isCompleted ? 1.4 : 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Visit Number, Week Range, Completion Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: visit.isCompleted
                        ? const Color(0xFFDCFCE7)
                        : accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    visit.weekRange,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: visit.isCompleted
                          ? const Color(0xFF15803D)
                          : accentColor,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => notifier.toggleVisit(visit.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          visit.isCompleted
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          color: visit.isCompleted
                              ? AppTheme.successGreen
                              : AppTheme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          visit.isCompleted ? 'Completed' : 'Mark Done',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: visit.isCompleted
                                ? AppTheme.successGreen
                                : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title & Description
            Text(
              visit.title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                decoration: visit.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              visit.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                height: 1.35,
              ),
            ),

            if (visit.isCompleted && visit.completedDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.event_available_rounded,
                    size: 14,
                    color: AppTheme.successGreen,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Completed: ${_formatDate(visit.completedDate!)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Recommended Clinical Checks
            const Text(
              'Recommended Tests & Assessments:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            ...visit.recommendedChecks.map(
              (check) => Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        check,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF334155),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Related Clinical Tool Button (e.g. Kick Counter, Birth Plan)
            if (visit.visitNumber == 3) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0284C7),
                  side: const BorderSide(color: Color(0xFFBAE6FD)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => context.push('/kick-counter'),
                icon: const Icon(Icons.touch_app_rounded, size: 14),
                label: const Text(
                  'Open Fetal Kick Counter',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ] else if (visit.visitNumber == 4) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                  side: const BorderSide(color: Color(0xFFDDD6FE)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => context.push('/birth-plan'),
                icon: const Icon(Icons.assignment_turned_in_rounded, size: 14),
                label: const Text(
                  'Open Birth Preparedness Plan',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Doctor Notes Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 15,
                            color: AppTheme.primaryTeal,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Doctor / Clinical Notes',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTealDark,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => _showEditNotesDialog(context, ref, visit),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 12,
                                color: AppTheme.primaryTeal,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    visit.doctorNotes.isNotEmpty ? visit.doctorNotes : 'No notes logged yet. Tap Edit to record doctor advice, scan values, or questions.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: visit.doctorNotes.isNotEmpty
                          ? const Color(0xFF1E293B)
                          : AppTheme.textMuted,
                      fontStyle: visit.doctorNotes.isNotEmpty
                          ? FontStyle.normal
                          : FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
