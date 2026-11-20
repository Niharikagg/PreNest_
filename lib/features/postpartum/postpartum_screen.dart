import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/tts_service.dart';
import 'postpartum_provider.dart';

class PostpartumScreen extends ConsumerWidget {
  const PostpartumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t('Postpartum Care', currentLang)),
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryTeal,
            indicatorWeight: 3,
            labelColor: AppTheme.primaryTeal,
            unselectedLabelColor: AppTheme.textMuted,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12.5,
            ),
            tabs: [
              Tab(
                icon: Icon(Icons.favorite_outline, size: 19),
                text: 'Mood Check (EPDS)',
              ),
              Tab(
                icon: Icon(Icons.vaccines_outlined, size: 19),
                text: 'Newborn Vaccines (UIP)',
              ),
              Tab(
                icon: Icon(Icons.healing_outlined, size: 19),
                text: 'Recovery & Feeding',
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Prominent Collapsible Setup & Recovery Header Card
            const _PostpartumSetupHeader(),
            const Expanded(
              child: TabBarView(
                children: [
                  _EpdsTab(),
                  _VaccineTrackerTab(),
                  _RecoveryAndFeedingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SETUP & RECOVERY HEADER CARD (COMPACT / EXPANDABLE)
// ==========================================
class _PostpartumSetupHeader extends ConsumerStatefulWidget {
  const _PostpartumSetupHeader();

  @override
  ConsumerState<_PostpartumSetupHeader> createState() =>
      _PostpartumSetupHeaderState();
}

class _PostpartumSetupHeaderState
    extends ConsumerState<_PostpartumSetupHeader> {
  bool _isExpanded = false;

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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Future<void> _selectDeliveryDate(
    BuildContext context,
    DateTime currentDate,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      helpText: 'Select Baby\'s Delivery Date',
      confirmText: 'Save',
    );
    if (picked != null) {
      ref.read(postpartumProvider.notifier).updateDeliveryDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postpartumProvider);
    final notifier = ref.read(postpartumProvider.notifier);
    final deliveryDate = state.deliveryDate ?? DateTime.now();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD97706).withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Summary Bar with Expand/Collapse Toggle
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.child_care_rounded,
                          color: Color(0xFFD97706),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.babyAgeLabel,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '${state.birthType} • ${state.feedingStyle}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isExpanded ? 'Hide' : 'Edit Setup',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: const Color(0xFFB45309),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable Setup Controls
              if (_isExpanded) ...[
                const Divider(height: 1, color: Color(0xFFFEF3C7)),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Delivery Date Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery Date',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                'Calculates baby\'s age & recovery stage',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFB45309),
                              side: const BorderSide(color: Color(0xFFFDE68A)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () =>
                                _selectDeliveryDate(context, deliveryDate),
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                            ),
                            label: Text(
                              _formatDate(deliveryDate),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 2. Birth Type Selector
                      const Text(
                        'Birth Type (Adapts Recovery Checklist)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'Vaginal Delivery',
                              label: Text('Vaginal Delivery'),
                              icon: Icon(Icons.favorite_border, size: 16),
                            ),
                            ButtonSegment(
                              value: 'C-Section',
                              label: Text('C-Section'),
                              icon: Icon(Icons.healing_outlined, size: 16),
                            ),
                          ],
                          selected: {state.birthType},
                          onSelectionChanged: (val) {
                            notifier.updateBirthType(val.first);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. Feeding Style Chips
                      const Text(
                        'Feeding Style Support',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children:
                            ['Exclusive Breastfeeding', 'Mixed', 'Formula'].map(
                              (style) {
                                final isSelected = state.feedingStyle == style;
                                return ChoiceChip(
                                  label: Text(style),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    notifier.updateFeedingStyle(style);
                                  },
                                  selectedColor: const Color(0xFFFEF3C7),
                                  backgroundColor: AppTheme.scaffoldBg,
                                  labelStyle: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? const Color(0xFF92400E)
                                        : AppTheme.textDark,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? const Color(0xFFD97706)
                                        : AppTheme.borderLight,
                                  ),
                                );
                              },
                            ).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: Mood Check (EPDS Screening)
// ==========================================
class _EpdsTab extends ConsumerWidget {
  const _EpdsTab();

  void _showTeleManasDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.phone_in_talk,
          color: AppTheme.warmRose,
          size: 40,
        ),
        title: const Text('Tele-MANAS Support (14416)'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tele-MANAS is the Government of India\'s 24/7 free, confidential mental health helpline.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
            SizedBox(height: 10),
            Text(
              'Toll-Free Numbers:\n'
              '• 14416 (Dedicated short code)\n'
              '• 1800-891-4416\n\n'
              'Available across all states in multiple regional languages with certified counsellors and psychologists.',
              style: TextStyle(fontSize: 12.5, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.warmRose),
            icon: const Icon(Icons.phone),
            label: const Text('Call 14416'),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Simulated dial to Tele-MANAS helpline (14416).',
                  ),
                  backgroundColor: AppTheme.warmRose,
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postpartumProvider);
    final notifier = ref.read(postpartumProvider.notifier);
    final theme = Theme.of(context);

    final answeredCount = state.epdsAnswers.length;
    final totalQuestions = kEpdsQuestions.length;
    final score = state.totalEpdsScore;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mandatory Non-Diagnostic Screening Disclaimer
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
                      Icons.info_outline,
                      size: 18,
                      color: AppTheme.textMuted,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is a screening tool for self-reflection, not a medical diagnosis. '
                        'Emotional ups and downs are common after childbirth. Please consult your doctor, midwife, or a mental health professional for any concerns.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Computed Score Result Card
              _buildResultCard(
                context,
                state,
                answeredCount,
                totalQuestions,
                score,
              ),
              const SizedBox(height: 20),

              // Questions List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edinburgh Postnatal Depression Scale',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (answeredCount > 0)
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text(
                        'Reset',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        notifier.resetEpds();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 10 EPDS Questions
              ...kEpdsQuestions.asMap().entries.map((entry) {
                final idx = entry.key;
                final q = entry.value;
                final selectedPoints = state.epdsAnswers[idx];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: selectedPoints != null
                          ? AppTheme.primaryTeal.withOpacity(0.4)
                          : AppTheme.borderLight,
                      width: selectedPoints != null ? 1.5 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.prompt,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: q.options.map((opt) {
                            final isSelected = selectedPoints == opt.points;
                            return ChoiceChip(
                              label: Text(opt.label),
                              selected: isSelected,
                              onSelected: (_) {
                                notifier.answerEpdsQuestion(idx, opt.points);
                              },
                              selectedColor: AppTheme.primaryTealLight,
                              backgroundColor: AppTheme.scaffoldBg,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppTheme.primaryTealDark
                                    : AppTheme.textDark,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primaryTeal
                                    : AppTheme.borderLight,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    PostpartumState state,
    int answeredCount,
    int totalQuestions,
    int score,
  ) {
    if (state.isEpdsHighRisk) {
      return Card(
        elevation: 0,
        color: const Color(0xFFFEF2F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score: $score / 30 • Warm Support Alert',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.hasSelfHarmThought
                              ? 'You indicated experiencing thoughts of self-harm, or your score is elevated ($score/30). You do not have to carry this alone. Please speak with your doctor, a loved one, or connect with the 24/7 Tele-MANAS helpline right now.'
                              : 'Your score ($score/30) indicates that you may be experiencing symptoms of postpartum depression or significant distress. We strongly encourage talking to your doctor, obstetrician, or a counsellor.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF7F1D1D),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.warmRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.phone_in_talk, size: 18),
                label: const Text(
                  'Tele-MANAS Mental Health Helpline (14416)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showTeleManasDialog(context),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Always consult your doctor or healthcare provider for medical guidance.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isEpdsModerateRisk) {
      return Card(
        elevation: 0,
        color: const Color(0xFFFFFBEB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFDE68A), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sentiment_neutral_rounded,
                  color: Color(0xFFD97706),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score: $score / 30 • Mild to Moderate Stress',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your score suggests you may be having a challenging time adjusting. '
                      'It is a good idea to check in with your doctor, midwife, or a counsellor soon. '
                      'Share how you are feeling with your partner or family.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF78350F),
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

    return Card(
      elevation: 0,
      color: const Color(0xFFF0FDF4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFBBF7D0)),
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
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sentiment_satisfied_alt_rounded,
                    color: Color(0xFF059669),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score: $score / 30 • Reassuring Mood Score',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        answeredCount < totalQuestions
                            ? '$answeredCount of $totalQuestions questions answered'
                            : 'All questions completed',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Your responses reflect a reassuring range. Remember to prioritize restful sleep when the baby sleeps, '
              'stay hydrated, and accept practical support from your partner and family. If feelings ever change, consult your doctor.',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF064E3B),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TAB 2: Newborn Vaccine Tracker (UIP)
// ==========================================
class _VaccineTrackerTab extends ConsumerWidget {
  const _VaccineTrackerTab();

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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postpartumProvider);
    final notifier = ref.read(postpartumProvider.notifier);
    final theme = Theme.of(context);

    int totalVaccines = 0;
    for (final group in kUipVaccineSchedule) {
      totalVaccines += group.vaccines.length;
    }
    final completedCount = state.vaccineRecords.length;
    final progress = totalVaccines > 0 ? (completedCount / totalVaccines) : 0.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: const Color(0xFFF0FDFA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF99F6E4)),
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
                              color: const Color(0xFFCCFBF1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.vaccines_rounded,
                              color: AppTheme.primaryTeal,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'India UIP Immunization Progress',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.primaryTealDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$completedCount of $totalVaccines doses recorded',
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
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
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
              const SizedBox(height: 12),

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
                        'Vaccine schedules can vary based on baby\'s birth weight, gestational age, and regional health advisories. '
                        'Always confirm exact immunization dates and batches with your paediatrician or your Mother and Child Protection (MCP) card.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ...kUipVaccineSchedule.map((group) {
                final groupDoneCount = group.vaccines
                    .where((v) => state.vaccineRecords.containsKey(v.id))
                    .length;
                final allGroupDone = groupDoneCount == group.vaccines.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: AppTheme.primaryTeal,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              group.ageGroup,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: allGroupDone
                                ? const Color(0xFFECFDF5)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: allGroupDone
                                  ? const Color(0xFFA7F3D0)
                                  : AppTheme.borderLight,
                            ),
                          ),
                          child: Text(
                            '$groupDoneCount / ${group.vaccines.length} Done',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: allGroupDone
                                  ? AppTheme.successGreen
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...group.vaccines.map((v) {
                      final isCompleted = state.vaccineRecords.containsKey(
                        v.id,
                      );
                      final completedDate = state.vaccineRecords[v.id];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        color: isCompleted
                            ? const Color(0xFFF0FDF4)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isCompleted
                                ? const Color(0xFFBBF7D0)
                                : AppTheme.borderLight,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: isCompleted,
                          activeColor: AppTheme.successGreen,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          title: Row(
                            children: [
                              Text(
                                v.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isCompleted
                                      ? const Color(0xFF166534)
                                      : AppTheme.textDark,
                                ),
                              ),
                              if (isCompleted && completedDate != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _formatDate(completedDate),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              v.details,
                              style: TextStyle(
                                fontSize: 12,
                                color: isCompleted
                                    ? const Color(0xFF15803D).withOpacity(0.8)
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ),
                          onChanged: (_) {
                            notifier.toggleVaccine(v.id);
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                  ],
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 3: Recovery & Breastfeeding Guidance
// ==========================================
class _RecoveryAndFeedingTab extends ConsumerWidget {
  const _RecoveryAndFeedingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postpartumProvider);
    final notifier = ref.read(postpartumProvider.notifier);
    final currentLang = ref.watch(languageProvider);
    final tts = ref.read(ttsServiceProvider);
    final theme = Theme.of(context);

    // Filter recovery checklist items based on birth type
    final isCSection = state.birthType == 'C-Section';
    final filteredTips = kPostpartumRecoveryTips.where((tip) {
      if (isCSection && tip.isVaginalOnly) return false;
      if (!isCSection && tip.isCSectionOnly) return false;
      return true;
    }).toList();

    final completedTipsCount = filteredTips
        .where((t) => state.completedRecoveryTips.contains(t.id))
        .length;
    final totalTipsCount = filteredTips.length;
    final recoveryProgress = totalTipsCount > 0
        ? (completedTipsCount / totalTipsCount)
        : 0.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SECTION 1: Tailored Physical Recovery Checklist Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.healing_rounded,
                          color: Color(0xFFD97706),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${state.birthType} Checklist',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: completedTipsCount == totalTipsCount
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: completedTipsCount == totalTipsCount
                            ? const Color(0xFFA7F3D0)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Text(
                      '$completedTipsCount / $totalTipsCount Completed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: completedTipsCount == totalTipsCount
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: recoveryProgress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFFEF3C7),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completedTipsCount == totalTipsCount
                        ? AppTheme.successGreen
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Checklist Cards
              ...filteredTips.map((tip) {
                final isDone = state.completedRecoveryTips.contains(tip.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: isDone ? const Color(0xFFF0FDF4) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isDone
                          ? const Color(0xFFBBF7D0)
                          : AppTheme.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: isDone,
                                activeColor: AppTheme.successGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (_) {
                                  notifier.toggleRecoveryTip(tip.id);
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tip.title,
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
                                      IconButton(
                                        icon: const Icon(
                                          Icons.volume_up_outlined,
                                          size: 18,
                                        ),
                                        tooltip: 'Read Aloud',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        visualDensity: VisualDensity.compact,
                                        color: AppTheme.primaryTeal,
                                        onPressed: () {
                                          tts.speak(
                                            '${tip.title}. ${tip.description}',
                                            currentLang,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tip.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.35,
                                      color: isDone
                                          ? const Color(0xFF15803D)
                                                .withOpacity(0.85)
                                          : AppTheme.textDark.withOpacity(0.85),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceMuted,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          tip.source,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 18),

              // SECTION 2: Breastfeeding Support Guidance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppTheme.primaryTeal,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Breastfeeding & Lactation Support',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.feedingStyle,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTealDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Breastfeeding Guidance Cards
              ...kBreastfeedingGuidanceList.map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryTeal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.volume_up_outlined,
                                size: 20,
                              ),
                              tooltip: 'Read Aloud',
                              color: AppTheme.primaryTeal,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                tts.speak(
                                  '${item.title}. ${item.subtitle}. ${item.body}. Actionable tip: ${item.actionableTip}',
                                  currentLang,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.body,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Actionable Tip Pill
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF99F6E4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 16,
                                color: AppTheme.primaryTeal,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.actionableTip,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryTealDark,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Source attribution
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceMuted,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Source: ${item.source}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),

              // Mandatory Non-Diagnostic Clinical Safety Disclaimer
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
                        'PreNest postpartum recovery tips and breastfeeding guidance are educational and informational only. '
                        'PreNest does not diagnose, prescribe, or provide medical dosing. '
                        'Always consult your obstetrician, pediatrician, or an International Board Certified Lactation Consultant (IBCLC) for clinical concerns.',
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
    );
  }
}
