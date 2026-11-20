import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/tts_service.dart';
import '../profile/profile_provider.dart';
import 'mood_state_insight_provider.dart';

class MoodStateInsightCard extends ConsumerWidget {
  const MoodStateInsightCard({super.key});

  static const Map<String, String> _moodEmojis = {
    'Calm': '😌',
    'Happy': '😊',
    'Tired': '🥱',
    'Anxious': '💭',
    'Low Energy': '🔋',
    'Irritable': '⚡',
  };

  void _readAloudInsight(
    WidgetRef ref,
    MoodStateInsight insight,
    bool isPartner,
    AppLanguage lang,
  ) {
    final tts = ref.read(ttsServiceProvider);
    final buffer = StringBuffer();

    if (isPartner) {
      buffer.write('Partner summary: ${insight.partnerStateSummary}. ');
      buffer.write(
        'Recommended partner support: ${insight.partnerSupportCue}. ',
      );
      buffer.write('Clinical observation: ${insight.professionalGuidance}. ');
      buffer.write('Source: ${insight.sourceAttribution}.');
    } else {
      buffer.write('Current state summary: ${insight.stateSummary}. ');
      buffer.write('Professional guidance: ${insight.professionalGuidance}. ');
      buffer.write('Source: ${insight.sourceAttribution}. ');
      if (insight.doctorQuestions.isNotEmpty) {
        buffer.write('Suggested questions for your doctor: ');
        for (int i = 0; i < insight.doctorQuestions.length; i++) {
          buffer.write('${i + 1}: ${insight.doctorQuestions[i]} ');
        }
      }
    }

    tts.speak(buffer.toString(), lang);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(moodStateInsightProvider);
    final activeMood = ref.watch(activeMoodProvider);
    final currentLang = ref.watch(languageProvider);
    final couple = ref.watch(coupleProvider);
    final activePartner = couple.activePartner;
    final isPartner =
        activePartner.id == couple.secondaryPartner.id ||
        activePartner.role.toLowerCase() == 'him';

    final stageColor = AppTheme.primaryTeal;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.borderLight, width: 1.1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header: Title + TTS Audio Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: isPartner
                            ? const Color(0xFFFEF3C7)
                            : AppTheme.primaryTealLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isPartner
                            ? Icons.favorite_rounded
                            : Icons.psychology_outlined,
                        size: 18,
                        color: isPartner
                            ? const Color(0xFFD97706)
                            : AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPartner
                              ? 'Partner Support Insight'
                              : 'Mood & State Insights',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          isPartner
                              ? 'Synthesized for ${couple.otherPartner.name} • Private chats protected'
                              : 'Source-linked non-diagnostic guidance',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.volume_up_outlined,
                    size: 20,
                    color: AppTheme.primaryTeal,
                  ),
                  tooltip: 'Read insight aloud',
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      _readAloudInsight(ref, insight, isPartner, currentLang),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // If primary view (Her), show 1-Tap Mood Check-In chips
            if (!isPartner) ...[
              const Text(
                'Quick Mood Check-In (Tap to refresh insight)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: kAvailableMoodCheckIns.map((mood) {
                    final isSelected = activeMood == mood;
                    final emoji = _moodEmojis[mood] ?? '✨';
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        selected: isSelected,
                        label: Text('$emoji $mood'),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primaryTealDark
                              : AppTheme.textDark,
                        ),
                        selectedColor: AppTheme.primaryTealLight,
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryTeal
                              : AppTheme.borderLight,
                        ),
                        onSelected: (val) {
                          if (val) {
                            ref.read(activeMoodProvider.notifier).setMood(mood);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Current State Summary Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isPartner
                    ? const Color(0xFFFFFBEB)
                    : const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPartner
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFF99F6E4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPartner
                        ? Icons.lightbulb_rounded
                        : Icons.auto_awesome_rounded,
                    size: 16,
                    color: isPartner
                        ? const Color(0xFFD97706)
                        : const Color(0xFF0F766E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isPartner
                          ? insight.partnerStateSummary
                          : insight.stateSummary,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPartner
                            ? const Color(0xFF92400E)
                            : const Color(0xFF115E59),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // If partner view: prominent actionable partner support cue
            if (isPartner) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.volunteer_activism_rounded,
                          size: 14,
                          color: Color(0xFFE11D48),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Empathetic Action Suggestion',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.partnerSupportCue,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textDark,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Source-Linked Professional Guidance
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 14,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Clinical Stage Insight',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Non-Diagnostic',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    insight.professionalGuidance,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 12,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Source: ${insight.sourceAttribution}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Questions for Your Doctor (Shown on Her view or Partner view)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.contact_support_outlined,
                        size: 14,
                        color: Color(0xFF0284C7),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Questions for Your Next Doctor Visit',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...insight.doctorQuestions.map((q) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              q,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textDark,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
