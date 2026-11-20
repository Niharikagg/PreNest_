import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/tts_service.dart';
import 'contraction_timer_provider.dart';

class ContractionTimerScreen extends ConsumerStatefulWidget {
  const ContractionTimerScreen({super.key});

  @override
  ConsumerState<ContractionTimerScreen> createState() =>
      _ContractionTimerScreenState();
}

class _ContractionTimerScreenState
    extends ConsumerState<ContractionTimerScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 1-second ticker to update the live elapsed timer whenever an active contraction is running
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final state = ref.read(contractionTimerProvider);
        if (state.isTiming) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatElapsed(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatSecondsToHuman(num seconds) {
    if (seconds <= 0) return '—';
    final secInt = seconds.round();
    final minutes = secInt ~/ 60;
    final remainingSecs = secInt % 60;

    if (minutes > 0) {
      return remainingSecs > 0
          ? '${minutes}m ${remainingSecs}s'
          : '${minutes}m';
    }
    return '${remainingSecs}s';
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $period';
  }

  Color _getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'mild':
        return AppTheme.primaryTeal;
      case 'moderate':
        return AppTheme.warningAmber;
      case 'strong':
        return AppTheme.warmRose;
      default:
        return AppTheme.primaryTeal;
    }
  }

  Color _getIntensityContainerColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'mild':
        return const Color(0xFFCCFBF1);
      case 'moderate':
        return const Color(0xFFFEF3C7);
      case 'strong':
        return const Color(0xFFFFE4E6);
      default:
        return const Color(0xFFCCFBF1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contractionTimerProvider);
    final notifier = ref.read(contractionTimerProvider.notifier);
    final currentLang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    // Compute live elapsed time if active
    int currentElapsedSeconds = 0;
    if (state.isTiming && state.currentStartTime != null) {
      currentElapsedSeconds = DateTime.now()
          .difference(state.currentStartTime!)
          .inSeconds;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t('Contraction Timer', currentLang)),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_outlined),
            tooltip: AppStrings.t('Read aloud', currentLang),
            onPressed: () {
              ref
                  .read(ttsServiceProvider)
                  .speak(
                    'Contraction Timer. Use this tool to measure labor contraction length and intervals. '
                    'Many doctors use the 5-1-1 pattern as a cue to call your hospital.',
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
                // 1. Calm Informational Guidance Banner (5-1-1 Pattern & Danger Signs button)
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
                                Icons.info_outline,
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
                                    '5-1-1 Labor Guidance Rule',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppTheme.primaryTealDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Many doctors use the 5-1-1 pattern (contractions ~5 min apart, lasting ~1 min, for 1 hour) '
                                    'as a general cue to call your hospital. Always follow your doctor\'s advice, and open the Danger-Sign Checker '
                                    'or call 108 if you have heavy bleeding, fluid leak, or severe pain.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.grey.shade800,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.warmRose,
                                side: const BorderSide(
                                  color: Color(0xFFFECDD3),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'Danger-Sign Checker',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () => context.push('/danger-signs'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Active Contraction Card with Large Circular Button & Intensity Chips
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: state.isTiming
                          ? AppTheme.warmRose.withOpacity(0.5)
                          : AppTheme.borderLight,
                      width: state.isTiming ? 1.5 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        // Active status pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: state.isTiming
                                ? const Color(0xFFFFE4E6)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: state.isTiming
                                  ? const Color(0xFFFDA4AF)
                                  : AppTheme.borderLight,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: state.isTiming
                                      ? AppTheme.warmRose
                                      : AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                state.isTiming
                                    ? 'Contraction in Progress'
                                    : 'Ready to Track',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: state.isTiming
                                      ? AppTheme.warmRose
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Large Circular Start / Stop Contraction Button
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () {
                              if (state.isTiming) {
                                notifier.stopContraction();
                              } else {
                                notifier.startContraction();
                              }
                            },
                            customBorder: const CircleBorder(),
                            splashColor: state.isTiming
                                ? const Color(0xFFFFE4E6)
                                : AppTheme.primaryTealLight,
                            child: Ink(
                              width: 210,
                              height: 210,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: state.isTiming
                                      ? [
                                          const Color(0xFFE11D48),
                                          const Color(0xFFBE123C),
                                        ]
                                      : [
                                          const Color(0xFF0F766E),
                                          const Color(0xFF14B8A6),
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (state.isTiming
                                                ? AppTheme.warmRose
                                                : AppTheme.primaryTeal)
                                            .withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      state.isTiming
                                          ? Icons.stop_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 38,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      state.isTiming
                                          ? _formatElapsed(
                                              currentElapsedSeconds,
                                            )
                                          : 'Start Contraction',
                                      style: TextStyle(
                                        fontSize: state.isTiming ? 30 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: state.isTiming
                                            ? 1.0
                                            : -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      state.isTiming
                                          ? 'Tap to Stop & Save'
                                          : 'Tap when contraction starts',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Intensity Selector Chips
                        Column(
                          children: [
                            Text(
                              'Intensity Level',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: ['Mild', 'Moderate', 'Strong'].map((
                                level,
                              ) {
                                final isSelected =
                                    state.selectedIntensity == level;
                                final color = _getIntensityColor(level);
                                return ChoiceChip(
                                  label: Text(level),
                                  selected: isSelected,
                                  onSelected: (_) =>
                                      notifier.setIntensity(level),
                                  selectedColor: _getIntensityContainerColor(
                                    level,
                                  ),
                                  backgroundColor: const Color(0xFFF8FAFC),
                                  labelStyle: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? color
                                        : AppTheme.textDark,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? color
                                        : AppTheme.borderLight,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Summary Metrics Row: Total Logged, Avg Duration, Avg Interval
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Total Logged',
                        value: '${state.totalLogged}',
                        icon: Icons.format_list_numbered_rounded,
                        accentColor: const Color(0xFF0284C7),
                        containerColor: const Color(0xFFE0F2FE),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Avg Duration',
                        value: _formatSecondsToHuman(state.avgDurationSeconds),
                        icon: Icons.timer_outlined,
                        accentColor: AppTheme.primaryTeal,
                        containerColor: const Color(0xFFCCFBF1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Avg Interval',
                        value: _formatSecondsToHuman(state.avgIntervalSeconds),
                        icon: Icons.sync_rounded,
                        accentColor: AppTheme.warmRose,
                        containerColor: const Color(0xFFFFE4E6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Scrollable History List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Contraction History (${state.history.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.history.isNotEmpty)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textMuted,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Clear Contraction History?'),
                              content: const Text(
                                'This will delete all logged contractions in this session. This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                  onPressed: () {
                                    notifier.clearHistory();
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Clear All'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                        label: const Text(
                          'Clear All',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                if (state.history.isEmpty)
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(28.0),
                      child: Center(
                        child: Text(
                          'No contractions recorded yet. Tap the button above to begin tracking.',
                          style: TextStyle(color: AppTheme.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.history.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = state.history[index];
                      final intensityColor = _getIntensityColor(
                        entry.intensity,
                      );
                      final intensityBg = _getIntensityContainerColor(
                        entry.intensity,
                      );

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: AppTheme.borderLight,
                            width: 1,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: intensityBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.timer_outlined,
                                    color: intensityColor,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Duration: ${_formatSecondsToHuman(entry.durationSeconds)}',
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
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
                                            color: intensityBg,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            entry.intensity,
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: intensityColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          _formatTimestamp(entry.startTime),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          entry.intervalSeconds != null
                                              ? '•  Interval: ${_formatSecondsToHuman(entry.intervalSeconds!)} apart'
                                              : '•  Baseline entry',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                entry.intervalSeconds != null
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: entry.intervalSeconds != null
                                                ? AppTheme.primaryTealDark
                                                : AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                color: AppTheme.textMuted,
                                tooltip: 'Delete entry',
                                onPressed: () {
                                  notifier.deleteEntry(entry.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),

                // 5. Gentle Clinical Safety Disclaimer
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
                          'Informational screening only. Never diagnose or self-manage labor. Always confirm labor progression and hospital admission cues directly with your doctor or healthcare provider.',
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

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
    required Color containerColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.25), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
