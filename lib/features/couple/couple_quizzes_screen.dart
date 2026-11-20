import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/profile_provider.dart';
import '../stage/stage.dart';
import '../stage/stage_provider.dart';
import 'couple_hints_provider.dart';

class CoupleQuizzesScreen extends ConsumerStatefulWidget {
  const CoupleQuizzesScreen({super.key});

  @override
  ConsumerState<CoupleQuizzesScreen> createState() =>
      _CoupleQuizzesScreenState();
}

class _CoupleQuizzesScreenState extends ConsumerState<CoupleQuizzesScreen> {
  // Check-in state
  String? _selectedSupportOption;
  bool _optInToSendHint = true;
  bool _justSubmittedCheckIn = false;

  // Selected stage filter for quizzes
  PregnancyStage? _filterStage;

  @override
  Widget build(BuildContext context) {
    final couple = ref.watch(coupleProvider);
    final currentStage = ref.watch(stageProvider);
    final hintsState = ref.watch(coupleHintsProvider);
    final activePartner = couple.activePartner;
    final otherPartner = couple.otherPartner;
    final theme = Theme.of(context);

    final activeHint = hintsState.activeSmartHint;
    final effectiveStage = _filterStage ?? currentStage;

    // Filter quiz questions for the selected stage
    final stageQuestions = kCoupleQuizCatalog
        .where((q) => q.stage == effectiveStage)
        .toList();

    // Filter checkup reminders (null stage applies to all stages)
    final stageCheckups = hintsState.checkupReminders.where((c) {
      return c.stage == null || c.stage == currentStage;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Couple Quizzes & Smart Hints',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${activePartner.name} (${activePartner.role}) • ${couple.coupleName}',
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
              setState(() {
                _justSubmittedCheckIn = false;
              });
            },
            icon: const Icon(Icons.switch_account_outlined, size: 16),
            label: Text(
              'Switch to ${otherPartner.name}',
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
              // 1. Active Smart Hint Card (if present)
              if (activeHint != null) ...[
                _buildActiveHintBanner(
                  context,
                  activeHint,
                  activePartner,
                  theme,
                ),
                const SizedBox(height: 14),
              ],

              // 2. Daily Partner Support Check-In Card
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFFE11D48).withOpacity(0.3),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFFFE4E6),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 18,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Support Check-In for ${activePartner.name}",
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "What would support you most right now?",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 4 Support Options
                      ...[
                        'Quiet rest',
                        'Help with meals/chores',
                        'Talking it through',
                        'A calm walk together',
                      ].map((opt) {
                        final isSelected = _selectedSupportOption == opt;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE11D48)
                                  : theme.colorScheme.outlineVariant,
                              width: isSelected ? 1.5 : 1,
                            ),
                            color: isSelected
                                ? const Color(0xFFFFF1F2)
                                : Colors.white,
                          ),
                          child: RadioListTile<String>(
                            dense: true,
                            value: opt,
                            groupValue: _selectedSupportOption,
                            activeColor: const Color(0xFFE11D48),
                            title: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFFBE123C)
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _selectedSupportOption = val;
                                _justSubmittedCheckIn = false;
                              });
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 10),

                      // Opt-in toggle to send hint
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _optInToSendHint
                                  ? Icons.share_rounded
                                  : Icons.lock_outline_rounded,
                              size: 16,
                              color: _optInToSendHint
                                  ? const Color(0xFF0F766E)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Send a gentle hint to my partner?',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    _optInToSendHint
                                        ? 'Converts into a supportive, gentle nudge for ${otherPartner.name}'
                                        : 'Stays completely private in your personal reflection log',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _optInToSendHint,
                              activeColor: const Color(0xFF0F766E),
                              onChanged: (val) {
                                setState(() {
                                  _optInToSendHint = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _selectedSupportOption == null
                              ? null
                              : () {
                                  ref
                                      .read(coupleHintsProvider.notifier)
                                      .submitSupportCheckIn(
                                        fromPartnerId: activePartner.id,
                                        fromPartnerName: activePartner.name,
                                        selectedOption: _selectedSupportOption!,
                                        optInToSendHint: _optInToSendHint,
                                        role: activePartner.role,
                                      );

                                  setState(() {
                                    _justSubmittedCheckIn = true;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color(0xFF0F766E),
                                      content: Text(
                                        _optInToSendHint
                                            ? 'Gentle hint shared with ${otherPartner.name}!'
                                            : 'Check-in saved privately for yourself.',
                                      ),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: Text(
                            _optInToSendHint
                                ? 'Submit & Share Gentle Hint'
                                : 'Save Privately',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE11D48),
                          ),
                        ),
                      ),

                      if (_justSubmittedCheckIn) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: Color(0xFF16A34A),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _optInToSendHint
                                      ? 'Smart hint generated! Switch to ${otherPartner.name} to see how it appears on their dashboard & AI Advisor.'
                                      : 'Saved as private. Your partner will not see this hint.',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF15803D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 3. Shared Checkup & Helping Reminders Section
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
                                backgroundColor: const Color(0xFFE0F2FE),
                                child: const Icon(
                                  Icons.checklist_rtl_rounded,
                                  size: 18,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Shared Checkup & Helping Reminders',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 20,
                            ),
                            color: const Color(0xFF0F766E),
                            tooltip: 'Add reminder',
                            onPressed: () =>
                                _showAddCheckupDialog(context, currentStage),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Visible for both partners to coordinate visits, record filing, and shared care.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (stageCheckups.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'No checkup reminders currently set.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...stageCheckups.map((checkup) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: checkup.isCompleted
                                  ? const Color(0xFFF8FAFC)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: checkup.isCompleted
                                    ? const Color(0xFFBBF7D0)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: CheckboxListTile(
                              dense: true,
                              value: checkup.isCompleted,
                              activeColor: const Color(0xFF059669),
                              onChanged: (_) {
                                ref
                                    .read(coupleHintsProvider.notifier)
                                    .toggleCheckupReminder(checkup.id);
                              },
                              title: Text(
                                checkup.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: checkup.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: checkup.isCompleted
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              subtitle: Text(
                                checkup.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              secondary: IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                color: Colors.grey.shade400,
                                onPressed: () {
                                  ref
                                      .read(coupleHintsProvider.notifier)
                                      .deleteCheckupReminder(checkup.id);
                                },
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 4. Stage-Matched Couple Quizzes & Myth-Busters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stage Quizzes & Myth-Busters',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<PregnancyStage>(
                    value: effectiveStage,
                    underline: const SizedBox(),
                    items: PregnancyStage.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          s.displayName,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _filterStage = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...stageQuestions.map((q) {
                final answeredIndex = hintsState.quizAnswers[q.id];
                return _buildQuizQuestionCard(context, q, answeredIndex, theme);
              }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveHintBanner(
    BuildContext context,
    SmartPartnerHint activeHint,
    PartnerProfile activePartner,
    ThemeData theme,
  ) {
    final isFromSelf = activeHint.fromPartnerId == activePartner.id;

    return Card(
      elevation: 0,
      color: const Color(0xFFFFF1F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFFDA4AF), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: Color(0xFFE11D48),
                ),
                const SizedBox(width: 8),
                Text(
                  isFromSelf
                      ? 'Your Active Smart Hint for Partner'
                      : 'Gentle Hint from ${activeHint.fromPartnerName}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBE123C),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  color: const Color(0xFFBE123C),
                  tooltip: 'Dismiss hint',
                  onPressed: () {
                    ref.read(coupleHintsProvider.notifier).clearActiveHint();
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              activeHint.hintText,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF881337),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.privacy_tip_outlined,
                  size: 12,
                  color: Color(0xFFBE123C),
                ),
                const SizedBox(width: 4),
                Text(
                  isFromSelf
                      ? 'Derived from your opt-in check-in to guide your partner gently'
                      : 'Opted-in supportive nudge to make caring effortless',
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF9F1239),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizQuestionCard(
    BuildContext context,
    CoupleQuizQuestion question,
    int? selectedOptionIndex,
    ThemeData theme,
  ) {
    final hasAnswered = selectedOptionIndex != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: question.isMythBuster
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    question.isMythBuster ? 'Myth-Buster' : 'Couple Insight',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: question.isMythBuster
                          ? const Color(0xFFB45309)
                          : const Color(0xFF0F766E),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  question.stage.displayName,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(question.options.length, (idx) {
              final isSelected = selectedOptionIndex == idx;
              final isCorrect = question.correctIndex == idx;

              Color borderColor = const Color(0xFFE2E8F0);
              Color bgColor = Colors.white;

              if (hasAnswered) {
                if (question.isMythBuster) {
                  if (isCorrect) {
                    borderColor = const Color(0xFF16A34A);
                    bgColor = const Color(0xFFF0FDF4);
                  } else if (isSelected && !isCorrect) {
                    borderColor = const Color(0xFFDC2626);
                    bgColor = const Color(0xFFFEF2F2);
                  }
                } else if (isSelected) {
                  borderColor = theme.colorScheme.primary;
                  bgColor = theme.colorScheme.primaryContainer.withOpacity(0.3);
                }
              }

              return InkWell(
                onTap: () {
                  ref
                      .read(coupleHintsProvider.notifier)
                      .answerQuizQuestion(question.id, idx);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 1.2),
                    color: bgColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question.options[idx],
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasAnswered && question.isMythBuster && isCorrect)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Color(0xFF16A34A),
                        ),
                    ],
                  ),
                ),
              );
            }),
            if (hasAnswered && question.explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: Color(0xFF0F766E),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.explanation,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddCheckupDialog(
    BuildContext context,
    PregnancyStage currentStage,
  ) {
    final titleController = TextEditingController();
    String category = 'Checkup Prep';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Add Shared Reminder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task / Reminder',
                      hintText: 'e.g., Bring scan file, evening walk check',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Checkup Prep',
                        child: Text('Checkup Prep'),
                      ),
                      DropdownMenuItem(
                        value: 'Shared Medicine Check',
                        child: Text('Shared Medicine Check'),
                      ),
                      DropdownMenuItem(
                        value: 'Supportive Check-in',
                        child: Text('Supportive Check-in'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          category = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      ref
                          .read(coupleHintsProvider.notifier)
                          .addCheckupReminder(
                            title: titleController.text.trim(),
                            category: category,
                            stage: currentStage,
                          );
                    }
                    Navigator.of(dialogCtx).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
