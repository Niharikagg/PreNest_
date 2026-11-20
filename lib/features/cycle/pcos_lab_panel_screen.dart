import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/tts_service.dart';
import 'pcos_lab_panel_provider.dart';

class PcosLabPanelScreen extends ConsumerWidget {
  const PcosLabPanelScreen({super.key});

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

  void _speakSummary(
    BuildContext context,
    WidgetRef ref,
    PcosLabPanelState state,
    AppLanguage lang,
  ) {
    final tts = ref.read(ttsServiceProvider);
    final logged = state.loggedMarkers;

    final loggedText = logged.isEmpty
        ? 'No lab markers currently logged.'
        : logged
              .map((m) {
                return '${m.name}: ${m.value} ${m.activeUnit}, printed range ${m.activeReferenceRange}, ${m.rangeStatusLabel}';
              })
              .join('. ');

    final speech =
        'PCOS Hormone and Metabolic Lab Panel. Tracked ${state.loggedCount} of ${state.totalCount} markers. '
        'Clinical notice: Reference ranges vary by laboratory and menstrual cycle phase. Always consult your gynaecologist. '
        'Logged values: $loggedText';

    tts.speak(speech, lang);
  }

  void _showEditMarkerSheet(
    BuildContext context,
    WidgetRef ref,
    PcosLabMarker marker,
  ) {
    final valueController = TextEditingController(
      text: marker.value != null ? marker.value.toString() : '',
    );
    final unitController = TextEditingController(text: marker.activeUnit);
    final rangeController = TextEditingController(
      text: marker.activeReferenceRange,
    );
    final notesController = TextEditingController(text: marker.notes ?? '');
    DateTime selectedDate = marker.loggedDate ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: marker.category == PcosLabCategory.metabolic
                                ? const Color(0xFFCCFBF1)
                                : const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            marker.category == PcosLabCategory.metabolic
                                ? Icons.bloodtype_outlined
                                : Icons.biotech_outlined,
                            color: marker.category == PcosLabCategory.metabolic
                                ? AppTheme.primaryTeal
                                : AppTheme.warmRose,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${marker.name} (${marker.shortCode})',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                marker.category == PcosLabCategory.metabolic
                                    ? 'Metabolic Panel Marker'
                                    : 'Hormone Panel Marker',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (marker.isLogged)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.errorRed,
                              size: 20,
                            ),
                            tooltip: 'Clear Entry',
                            onPressed: () {
                              ref
                                  .read(pcosLabPanelProvider.notifier)
                                  .clearMarker(marker.id);
                              Navigator.of(ctx).pop();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      marker.clinicalContext,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Value and Unit Inputs
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: valueController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: 'Lab Value',
                              hintText: 'e.g., 95.5',
                              prefixIcon: Icon(Icons.speed_outlined, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: unitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              hintText: 'e.g., mg/dL',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Printed Lab Reference Range
                    TextField(
                      controller: rangeController,
                      decoration: InputDecoration(
                        labelText: 'Printed Lab Reference Range',
                        hintText: 'e.g., ${marker.standardReferenceRange}',
                        helperText:
                            'Standard baseline: ${marker.standardReferenceRange}',
                        helperStyle: const TextStyle(fontSize: 11),
                        prefixIcon: const Icon(
                          Icons.straighten_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date Picker Row
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 730),
                          ),
                          lastDate: DateTime.now(),
                          helpText: 'Select Lab Test Date',
                        );
                        if (picked != null) {
                          setSheetState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.event_outlined,
                                  size: 20,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Test Date',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(selectedDate),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Optional Notes
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Optional Lab Notes',
                        hintText: 'e.g., Fasting 10 hrs, Day 3 follicular phase, Labcorp test',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Button
                    FilledButton(
                      onPressed: () {
                        final parsed = double.tryParse(
                          valueController.text.trim(),
                        );
                        if (parsed != null) {
                          ref
                              .read(pcosLabPanelProvider.notifier)
                              .updateMarker(
                                id: marker.id,
                                value: parsed,
                                customUnit: unitController.text.trim(),
                                printedReferenceRange: rangeController.text
                                    .trim(),
                                loggedDate: selectedDate,
                                notes: notesController.text.trim(),
                              );
                          Navigator.of(ctx).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a valid numeric value.',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Lab Value',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMarkerCard({
    required BuildContext context,
    required WidgetRef ref,
    required PcosLabMarker marker,
  }) {
    final isMetabolic = marker.category == PcosLabCategory.metabolic;
    final primaryAccent = isMetabolic
        ? AppTheme.primaryTeal
        : AppTheme.warmRose;
    final containerColor = isMetabolic
        ? const Color(0xFFCCFBF1)
        : const Color(0xFFFFE4E6);

    return InkWell(
      onTap: () => _showEditMarkerSheet(context, ref, marker),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: marker.isLogged
                ? (marker.rangeStatus == PcosRangeStatus.outsideRange
                      ? const Color(0xFFFDE68A)
                      : AppTheme.borderLight)
                : AppTheme.borderLight,
            width:
                marker.isLogged &&
                    marker.rangeStatus == PcosRangeStatus.outsideRange
                ? 1.5
                : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          marker.shortCode,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          marker.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  marker.isLogged
                      ? Icons.edit_note_rounded
                      : Icons.add_circle_outline_rounded,
                  size: 20,
                  color: marker.isLogged ? primaryAccent : AppTheme.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (marker.isLogged) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${marker.value}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    marker.activeUnit,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const Spacer(),
                  if (marker.loggedDate != null)
                    Text(
                      _formatDate(marker.loggedDate!),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Soft non-diagnostic range badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: marker.rangeStatus == PcosRangeStatus.withinRange
                      ? const Color(0xFFECFDF5)
                      : (marker.rangeStatus == PcosRangeStatus.outsideRange
                            ? const Color(0xFFFFFBEB)
                            : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: marker.rangeStatus == PcosRangeStatus.withinRange
                        ? const Color(0xFFA7F3D0)
                        : (marker.rangeStatus == PcosRangeStatus.outsideRange
                              ? const Color(0xFFFDE68A)
                              : AppTheme.borderLight),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      marker.rangeStatus == PcosRangeStatus.withinRange
                          ? Icons.check_circle_outline_rounded
                          : (marker.rangeStatus == PcosRangeStatus.outsideRange
                                ? Icons.info_outline_rounded
                                : Icons.help_outline_rounded),
                      size: 14,
                      color: marker.rangeStatus == PcosRangeStatus.withinRange
                          ? const Color(0xFF059669)
                          : (marker.rangeStatus == PcosRangeStatus.outsideRange
                                ? const Color(0xFFD97706)
                                : AppTheme.textMuted),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        marker.rangeStatusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              marker.rangeStatus == PcosRangeStatus.withinRange
                              ? const Color(0xFF065F46)
                              : (marker.rangeStatus ==
                                        PcosRangeStatus.outsideRange
                                    ? const Color(0xFF92400E)
                                    : AppTheme.textDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Printed Lab Range: ${marker.activeReferenceRange}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              if (marker.notes != null && marker.notes!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  'Note: ${marker.notes}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Not logged yet',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    'Ref: ${marker.standardReferenceRange}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                marker.clinicalContext,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.textMuted,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pcosLabPanelProvider);
    final currentLang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PCOS Lab Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_outlined),
            tooltip: AppStrings.t('Read aloud', currentLang),
            onPressed: () => _speakSummary(context, ref, state, currentLang),
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset to sample entries',
            onPressed: () {
              ref.read(pcosLabPanelProvider.notifier).resetToDefaults();
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
                // 1. Scan Paper Lab Report Action Hero Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.document_scanner_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Have a Paper Lab Report?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Extract TSH, AMH, HbA1c & insulin automatically',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFCCFBF1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryTealDark,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: AppTheme.primaryTealDark,
                          ),
                          label: const Text(
                            'Scan Paper Lab Report',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                          onPressed: () => context.push('/verify'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Overview Stats Card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Logged Markers',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${state.loggedCount} / ${state.totalCount}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppTheme.borderLight,
                        ),
                        Column(
                          children: [
                            const Text(
                              'Metabolic',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${state.metabolicMarkers.where((m) => m.isLogged).length} of 4',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppTheme.borderLight,
                        ),
                        Column(
                          children: [
                            const Text(
                              'Hormone',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${state.hormoneMarkers.where((m) => m.isLogged).length} of 6',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. SECTION 1: METABOLIC PANEL
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.monitor_heart_outlined,
                        size: 18,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Metabolic Panel (4 Markers)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Screens for glycemic balance, fasting insulin, and lipid risk factors.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.metabolicMarkers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final marker = state.metabolicMarkers[index];
                    return _buildMarkerCard(
                      context: context,
                      ref: ref,
                      marker: marker,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 4. SECTION 2: HORMONE PANEL
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bubble_chart_outlined,
                        size: 18,
                        color: AppTheme.warmRose,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hormone Panel (6 Markers)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Evaluates ovulatory reserve, gonadotropins, androgen markers, and thyroid/prolactin baselines.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.hormoneMarkers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final marker = state.hormoneMarkers[index];
                    return _buildMarkerCard(
                      context: context,
                      ref: ref,
                      marker: marker,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 5. Clinical Safety & Non-Diagnostic Disclaimer Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        color: Color(0xFFD97706),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clinical Lab Range Notice',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'PreNest displays lab values for tracking and communication purposes only. '
                              'Reference ranges vary significantly by testing laboratory, equipment, testing methodology, '
                              'and menstrual cycle phase (e.g., follicular vs. luteal). These values do not constitute a medical diagnosis. '
                              'Always review lab findings directly with your gynaecologist or endocrinologist.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF92400E),
                                height: 1.35,
                              ),
                            ),
                          ],
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
