import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/tts_service.dart';
import '../profile/profile_provider.dart';
import 'doctor_summary_pdf_service.dart';
import 'doctor_summary_provider.dart';

class DoctorSummaryScreen extends ConsumerStatefulWidget {
  const DoctorSummaryScreen({super.key});

  @override
  ConsumerState<DoctorSummaryScreen> createState() =>
      _DoctorSummaryScreenState();
}

class _DoctorSummaryScreenState extends ConsumerState<DoctorSummaryScreen> {
  final TextEditingController _questionController = TextEditingController();
  final DoctorSummaryPdfService _pdfService = const DoctorSummaryPdfService();
  bool _isGeneratingPdf = false;
  bool _isSpeaking = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _handleAddCustomQuestion() {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;

    ref.read(customDoctorQuestionsProvider.notifier).addQuestion(text);
    _questionController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom question added to your doctor visit list.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handlePrintPdf(DoctorSummaryData data) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfBytes = await _pdfService.buildOnePagePdf(data);
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'PreNest_Doctor_Summary_${data.partnerName}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open print preview: $e'),
            action: SnackBarAction(
              label: 'Copy Text',
              onPressed: () => _copyTextSummary(data),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _handleSharePdf(DoctorSummaryData data) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfBytes = await _pdfService.buildOnePagePdf(data);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'prenest_doctor_summary_${data.partnerName.toLowerCase()}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to share PDF: $e'),
            action: SnackBarAction(
              label: 'Copy Text',
              onPressed: () => _copyTextSummary(data),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  void _copyTextSummary(DoctorSummaryData data) {
    final text = _pdfService.buildPlainTextSummary(data);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Doctor summary copied to clipboard!'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleTtsReadAloud(DoctorSummaryData data) async {
    final tts = ref.read(ttsServiceProvider);
    final lang = ref.read(languageProvider);

    if (_isSpeaking) {
      await tts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      if (mounted) setState(() => _isSpeaking = true);
      final readAloudText =
          'PreNest Doctor Visit Summary for ${data.partnerName}. Stage: ${data.stageDisplayName}. '
          'Measured facts include ${data.measuredLabs.length} verified laboratory parameters and vitals. '
          'Cycle summary: Cycle day ${data.cycleSummary.currentCycleDay}, '
          '${data.cycleSummary.flaggedPcosCount} PCOS indicators flagged. '
          'There are ${data.allQuestions.length} suggested questions for your doctor. '
          'Notice: Informational only. Not a medical diagnosis or prescription.';

      await tts.speak(readAloudText, lang);
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(doctorSummaryProvider);
    final couple = ref.watch(coupleProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doctor Visit Summary',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              'One-Page Clinical Export & Talking Points',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isSpeaking ? 'Stop reading' : 'Read summary aloud',
            icon: Icon(
              _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
              color: _isSpeaking ? AppTheme.warmRose : AppTheme.primaryTeal,
            ),
            onPressed: () => _toggleTtsReadAloud(data),
          ),
          IconButton(
            tooltip: 'Copy plain text',
            icon: const Icon(Icons.copy_rounded, color: AppTheme.textMuted),
            onPressed: () => _copyTextSummary(data),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              // Scrollable 5-Section Preview
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    // Top Non-Diagnostic Safety Disclaimer
                    _buildClinicalDisclaimerBanner(),
                    const SizedBox(height: 12),

                    // Patient & Couple Switcher Header Card
                    _buildPatientHeaderCard(data, couple),
                    const SizedBox(height: 16),

                    // Section 1: Measured Lab & Vitals Facts
                    _buildSectionHeader(
                      '1. Measured Lab & Vitals Facts',
                      'Verified lab tests and on-device logged vitals',
                      Icons.biotech_outlined,
                      AppTheme.primaryTeal,
                    ),
                    const SizedBox(height: 8),
                    _buildMeasuredFactsSection(data),
                    const SizedBox(height: 20),

                    // Section 2: 6-Month Cycle & PCOD/PCOS Summary
                    _buildSectionHeader(
                      '2. 6-Month Cycle & PCOD/PCOS Summary',
                      'Tracking mode, cycle length and flagged self-check signs',
                      Icons.water_drop_outlined,
                      AppTheme.warmRose,
                    ),
                    const SizedBox(height: 8),
                    _buildCycleSummarySection(data.cycleSummary),
                    const SizedBox(height: 20),

                    // Section 3: App Observations (Non-Diagnostic)
                    _buildSectionHeader(
                      '3. App Observations (Non-Diagnostic)',
                      'Soft-label trend notes and synthesized stage context',
                      Icons.insights_rounded,
                      const Color(0xFF0284C7),
                    ),
                    const SizedBox(height: 8),
                    _buildObservationsSection(data.appObservations),
                    const SizedBox(height: 20),

                    // Section 4: Uncertain / Needs-Review Items
                    _buildSectionHeader(
                      '4. Uncertain / Needs-Review Items',
                      'Items requiring manual verification with original paper reports',
                      Icons.fact_check_outlined,
                      const Color(0xFFD97706),
                    ),
                    const SizedBox(height: 8),
                    _buildUncertainSection(data.uncertainItems),
                    const SizedBox(height: 20),

                    // Section 5: Questions to Ask Your Doctor
                    _buildSectionHeader(
                      '5. Questions to Ask Your Doctor',
                      'Clinical prompts compiled from lab markers, self-check & partner input',
                      Icons.help_outline_rounded,
                      AppTheme.primaryTeal,
                    ),
                    const SizedBox(height: 8),
                    _buildQuestionsSection(data),
                    const SizedBox(height: 16),

                    // Inline "Add a Question" Input Box
                    _buildAddQuestionRow(),
                    const SizedBox(height: 24),

                    // Bottom Non-Diagnostic Reassurance
                    _buildBottomFooterNote(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Sticky Bottom Action Bar
              _buildStickyActionBar(data, theme),
            ],
          ),
        ),
      ),
    );
  }

  // --- SECTION WIDGETS ---

  Widget _buildClinicalDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 18, color: Color(0xFFD97706)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Informational summary generated on-device by PreNest. Not a medical diagnosis, triage, or prescription. '
              'Please bring your physical paper reports to your doctor consultation.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF92400E),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeaderCard(DoctorSummaryData data, CoupleState couple) {
    return Card(
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
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryTealLight,
                  child: Text(
                    data.partnerName.isNotEmpty ? data.partnerName[0] : 'P',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTealDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.partnerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceMuted,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${data.partnerRole} • Age ${data.partnerAge} • ${data.bloodGroup}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Stage: ${data.stageDisplayName} (${data.stageDescription})',
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
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Switch Active Partner:',
                  style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                ),
                const SizedBox(width: 8),
                ...couple.partners.map((partner) {
                  final isSelected = partner.id == couple.activePartnerId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(
                        partner.name,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryTealLight,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryTealDark
                            : AppTheme.textDark,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        ref
                            .read(coupleProvider.notifier)
                            .switchPartner(partner.id);
                      },
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeasuredFactsSection(DoctorSummaryData data) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.measuredLabs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No verified lab entries recorded yet for active partner.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              )
            else
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.0),
                  1: FlexColumnWidth(1.4),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(1.8),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppTheme.borderLight),
                      ),
                    ),
                    children: [
                      _tableHeader('Parameter'),
                      _tableHeader('Value'),
                      _tableHeader('Date'),
                      _tableHeader('Reference Range'),
                    ],
                  ),
                  ...data.measuredLabs.map((lab) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            lab.testName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            lab.valueWithUnit,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: lab.isFlagged
                                  ? AppTheme.warmRose
                                  : AppTheme.textDark,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            lab.dateStr,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            lab.referenceRange,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            if (data.measuredVitals.isNotEmpty) ...[
              const SizedBox(height: 10),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 8),
              const Text(
                'Logged Vitals (Latest):',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: data.measuredVitals.map((v) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monitor_heart_outlined,
                          size: 14,
                          color: AppTheme.primaryTeal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${v.label}: ${v.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${v.category})',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildCycleSummarySection(CycleSummaryData cycle) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                    color: cycle.irregularCycleMode
                        ? const Color(0xFFFFE4E6)
                        : const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    cycle.irregularCycleMode
                        ? 'Irregular / Flexible Mode (PCOD/PCOS)'
                        : 'Standard Cycle Window (~${cycle.averageCycleLength} days)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: cycle.irregularCycleMode
                          ? AppTheme.warmRoseDark
                          : AppTheme.primaryTealDark,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Day ${cycle.currentCycleDay}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last Period: ${cycle.lastPeriodDateStr} • Flow: ${cycle.flowIntensity}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Logged Symptoms: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    cycle.activeSymptoms.isEmpty
                        ? 'None logged this cycle'
                        : cycle.activeSymptoms.join(', '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PCOS Self-Check: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    '${cycle.flaggedPcosCount} of ${cycle.totalPcosCount} indicators noted',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cycle.flaggedPcosCount > 0
                          ? AppTheme.warmRose
                          : AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            if (cycle.flaggedPcosNames.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Flagged: ${cycle.flaggedPcosNames.join("; ")}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                cycle.patternSummary,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textDark,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationsSection(List<AppObservationItem> observations) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: observations.map((obs) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: obs.isAttentionNeeded
                    ? const Color(0xFFFFF1F2)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: obs.isAttentionNeeded
                      ? const Color(0xFFFECDD3)
                      : AppTheme.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: obs.isAttentionNeeded
                              ? const Color(0xFFFFE4E6)
                              : AppTheme.primaryTealLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          obs.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: obs.isAttentionNeeded
                                ? AppTheme.warmRoseDark
                                : AppTheme.primaryTealDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          obs.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: obs.isAttentionNeeded
                                ? AppTheme.warmRoseDark
                                : AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    obs.detail,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textDark,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUncertainSection(List<UncertainItem> items) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFFDE68A)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Confidence: ${item.confidencePercent}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.reason,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Recommendation: ${item.recommendation}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuestionsSection(DoctorSummaryData data) {
    final customQuestions = ref.watch(customDoctorQuestionsProvider);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auto compiled questions
            ...data.autoQuestions.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final q = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: AppTheme.primaryTealLight,
                      child: Text(
                        '$idx',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTealDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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

            // Custom questions added by user
            if (customQuestions.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text(
                'Custom Partner Questions:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.warmRoseDark,
                ),
              ),
              const SizedBox(height: 6),
              ...customQuestions.asMap().entries.map((entry) {
                final idx = data.autoQuestions.length + entry.key + 1;
                final q = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 9,
                        backgroundColor: const Color(0xFFFFE4E6),
                        child: Text(
                          '$idx',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warmRoseDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          size: 16,
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Remove custom question',
                        onPressed: () {
                          ref
                              .read(customDoctorQuestionsProvider.notifier)
                              .removeQuestion(entry.key);
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddQuestionRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add a question for your doctor:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText:
                        'e.g., Should we check thyroid or fasting insulin?',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                  ),
                  onSubmitted: (_) => _handleAddCustomQuestion(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _handleAddCustomQuestion,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Add', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomFooterNote() {
    return Center(
      child: Text(
        'Generated on-device by PreNest • Non-diagnostic clinical summary aid',
        style: TextStyle(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStickyActionBar(DoctorSummaryData data, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppTheme.borderLight)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Copy Text Button
          IconButton.outlined(
            tooltip: 'Copy Plain Text Summary',
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: () => _copyTextSummary(data),
          ),
          const SizedBox(width: 8),

          // Share PDF Button
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              onPressed: _isGeneratingPdf ? null : () => _handleSharePdf(data),
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text(
                'Share PDF',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Export / Print PDF Button
          Expanded(
            flex: 1,
            child: FilledButton.icon(
              onPressed: _isGeneratingPdf ? null : () => _handlePrintPdf(data),
              icon: _isGeneratingPdf
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.print_rounded, size: 18),
              label: Text(
                _isGeneratingPdf ? 'Preparing...' : 'Export / Print PDF',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
