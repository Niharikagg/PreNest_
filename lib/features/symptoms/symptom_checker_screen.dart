import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/tts_service.dart';
import '../stage/stage.dart';
import 'symptom_checker_provider.dart';

class SymptomCheckerScreen extends ConsumerWidget {
  const SymptomCheckerScreen({super.key});

  void _readAloudSymptom(
    WidgetRef ref,
    StageSymptomItem symptom,
    AppLanguage lang,
  ) {
    final tts = ref.read(ttsServiceProvider);
    final buffer = StringBuffer();

    if (symptom.isRedFlag) {
      buffer.write('Warning. Red-flag symptom: ${symptom.title}. ');
      buffer.write('${symptom.description}. ');
      buffer.write(
        'Prompt medical review needed. ${symptom.clinicalRationale}. ',
      );
      buffer.write('Action required: ${symptom.whenToConsultDoctor}. ');
      buffer.write('Source: ${symptom.sourceAttribution}.');
    } else {
      buffer.write('Common discomfort: ${symptom.title}. ');
      buffer.write('${symptom.description}. ');
      buffer.write('Comfort advice: ${symptom.comfortTips}. ');
      buffer.write('When to consult doctor: ${symptom.whenToConsultDoctor}. ');
      buffer.write('Source: ${symptom.sourceAttribution}.');
    }

    tts.speak(buffer.toString(), lang);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(symptomCheckerProvider);
    final currentLang = ref.watch(languageProvider);
    final activeStage = state.activeStage;
    final selected = state.selectedSymptom;

    final commonItems = state.commonDiscomforts;
    final redFlagItems = state.redFlags;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: Text(AppStrings.t('Symptom Checker', currentLang)),
        actions: [
          if (selected != null)
            IconButton(
              icon: const Icon(Icons.volume_up_outlined),
              tooltip: 'Read guidance aloud',
              onPressed: () => _readAloudSymptom(ref, selected, currentLang),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Clinical Safety Disclaimer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFECACA),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppTheme.errorRed,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Informational Guide Only — Not Diagnostic',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'PreNest does not diagnose, prescribe, or provide medicine dosing. '
                              'Always consult your obstetrician or doctor for medical concerns. '
                              'In an emergency, call 108 immediately.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7F1D1D),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Stage Filter Segmented Selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: PregnancyStage.values.map((stage) {
                      final isSelected = activeStage == stage;
                      String label;
                      switch (stage) {
                        case PregnancyStage.trying:
                          label = 'Period & PCOS';
                          break;
                        case PregnancyStage.plan:
                          label = 'Planning';
                          break;
                        case PregnancyStage.pregnancy:
                          label = 'Pregnant';
                          break;
                        case PregnancyStage.postpartum:
                          label = 'Postpartum';
                          break;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(label),
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
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryTeal
                                : AppTheme.borderLight,
                          ),
                          onSelected: (val) {
                            if (val) {
                              ref
                                  .read(symptomCheckerProvider.notifier)
                                  .setStage(stage);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Group 1: Common Stage Discomforts Header
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Common Stage Discomforts',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTealLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${commonItems.length} items',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTealDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Group 1 Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: commonItems.map((item) {
                    final isSelected = selected?.id == item.id;
                    return InkWell(
                      onTap: () {
                        ref
                            .read(symptomCheckerProvider.notifier)
                            .selectSymptom(item.id);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryTealLight
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryTeal
                                : AppTheme.borderLight,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: 16,
                              color: isSelected
                                  ? AppTheme.primaryTeal
                                  : AppTheme.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.primaryTealDark
                                    : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Group 2: Symptoms Needing Prompt Medical Review / Red Flags
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Prompt Medical Review Needed (Red Flags)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${redFlagItems.length} critical',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorRed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Group 2 Chips (Pastel Coral/Rose)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: redFlagItems.map((item) {
                    final isSelected = selected?.id == item.id;
                    return InkWell(
                      onTap: () {
                        ref
                            .read(symptomCheckerProvider.notifier)
                            .selectSymptom(item.id);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFE4E6)
                              : const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE11D48)
                                : const Color(0xFFFECDD3),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: 16,
                              color: const Color(0xFFE11D48),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: const Color(0xFF9F1239),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Detailed Selected Symptom Information Card
                if (selected != null)
                  _buildDetailCard(context, ref, selected, currentLang),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    WidgetRef ref,
    StageSymptomItem item,
    AppLanguage lang,
  ) {
    final isRedFlag = item.isRedFlag;
    final accentColor = isRedFlag ? AppTheme.errorRed : AppTheme.primaryTeal;
    final containerColor = isRedFlag
        ? const Color(0xFFFEF2F2)
        : AppTheme.primaryTealLight;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isRedFlag ? const Color(0xFFFCA5A5) : AppTheme.borderLight,
          width: isRedFlag ? 1.3 : 1.1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, size: 22, color: accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isRedFlag
                              ? 'PROMPT MEDICAL REVIEW'
                              : 'COMMON STAGE DISCOMFORT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textDark,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),

            // If Red Flag: High-Priority Escalation Box
            if (isRedFlag) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.emergency_rounded,
                          color: AppTheme.errorRed,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Immediate Clinical Triage Guidance',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.clinicalRationale,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F1D1D),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: AppTheme.errorRed,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.whenToConsultDoctor,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF991B1B),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Direct Action Escalation Buttons
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.errorRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 11,
                                horizontal: 12,
                              ),
                            ),
                            icon: const Icon(Icons.emergency, size: 16),
                            label: const Text(
                              'Danger Signs / 108',
                              style: TextStyle(fontSize: 12.5),
                            ),
                            onPressed: () {
                              context.push('/danger-signs');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF991B1B),
                            side: const BorderSide(color: Color(0xFFF87171)),
                            padding: const EdgeInsets.symmetric(
                              vertical: 11,
                              horizontal: 10,
                            ),
                          ),
                          icon: const Icon(
                            Icons.bookmark_add_outlined,
                            size: 16,
                          ),
                          label: const Text(
                            'Save Question',
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added "${item.title}" to your urgent doctor question notes.',
                                ),
                                backgroundColor: AppTheme.errorRed,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ] else ...[
              // Common Discomfort: Calm Comfort Tips Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF99F6E4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.spa_rounded,
                          color: AppTheme.primaryTeal,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Comfort & Non-Pharmacological Tips',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTealDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.comfortTips,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF134E4A),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: AppTheme.primaryTeal,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.whenToConsultDoctor,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF0F766E),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Suggested Doctor Questions
            if (item.doctorQuestions.isNotEmpty) ...[
              const Text(
                'Questions to Ask Your Healthcare Provider:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              ...item.doctorQuestions.map((q) {
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
                          color: AppTheme.primaryTeal,
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
              const SizedBox(height: 12),
            ],

            // Clinical Source Attribution
            Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 13,
                  color: AppTheme.primaryTeal,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Clinical Source: ${item.sourceAttribution}',
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
    );
  }
}
