import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/models/trend_summary.dart';
import '../../core/models/verified_result.dart';
import '../profile/profile_provider.dart';
import '../records/records_provider.dart';

class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePartner = ref.watch(coupleProvider).activePartner;
    final partnerRecords = ref.watch(activePartnerRecordsProvider);
    final trendService = ref.read(trendServiceProvider);

    // Group records by standardized test name
    final groupedRecords = <String, List<VerifiedResult>>{};
    for (final record in partnerRecords) {
      groupedRecords.putIfAbsent(record.testNameStd, () => []).add(record);
    }

    final testNames = groupedRecords.keys.toList()..sort();

    final theme = Theme.of(context);

    if (testNames.isEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFBAE6FD),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    size: 48,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No lab reports yet — scan your first report to unlock safe trends',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Once you verify clinical reports in PreNest, your longitudinal trajectories, safe reference ranges, and trimester flags will be visualized here.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go('/verify'),
                  icon: const Icon(Icons.document_scanner_rounded, size: 18),
                  label: const Text('Scan & Verify Report'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: testNames.length,
          itemBuilder: (context, index) {
            final testName = testNames[index];
            final records = groupedRecords[testName]!;
            final summary = trendService.summarize(records);
            final unit = records.isNotEmpty ? records.first.unit : '';
            final labelInfo = _getTrendLabelInfo(summary.labelKey);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              color: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  context.push(
                    '/records/detail/${Uri.encodeComponent(testName)}',
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Test Name & Trajectory badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              testName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: labelInfo.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: labelInfo.color.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  labelInfo.icon,
                                  size: 14,
                                  color: labelInfo.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  labelInfo.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: labelInfo.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Current value and delta
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            summary.latestValue != null
                                ? summary.latestValue.toString()
                                : '--',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            unit,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          if (summary.change != null && summary.count > 1) ...[
                            Icon(
                              summary.change! >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 14,
                              color: summary.change! > 0
                                  ? Colors.teal.shade700
                                  : Colors.indigo.shade700,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${summary.change! >= 0 ? "+" : ""}${summary.change} (${summary.changePercent! >= 0 ? "+" : ""}${summary.changePercent}%)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: summary.change! > 0
                                    ? Colors.teal.shade700
                                    : Colors.indigo.shade700,
                              ),
                            ),
                          ] else ...[
                            Text(
                              '1 reading recorded',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Range position bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: summary.positionInRange ?? 0.5,
                          minHeight: 6,
                          backgroundColor: theme.colorScheme.outlineVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getPositionColor(summary.positionInRange ?? 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Bottom reason label
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              summary.reason,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Color _getPositionColor(double pos) {
    if (pos < 0.25) return Colors.blue.shade400;
    if (pos > 0.8) return Colors.orange.shade600;
    return Colors.teal.shade500;
  }

  static _TrendLabelData _getTrendLabelInfo(TrendLabelKey key) {
    switch (key) {
      case TrendLabelKey.firstResult:
        return _TrendLabelData('Baseline', Icons.flag_outlined, Colors.blue);
      case TrendLabelKey.changeTwo:
        return _TrendLabelData(
          '2-Point Shift',
          Icons.compare_arrows,
          Colors.purple,
        );
      case TrendLabelKey.movingUpSoFar:
        return _TrendLabelData('Upward', Icons.trending_up, Colors.teal);
      case TrendLabelKey.movingDownSoFar:
        return _TrendLabelData('Downward', Icons.trending_down, Colors.indigo);
      case TrendLabelKey.steady:
        return _TrendLabelData('Steady', Icons.trending_flat, Colors.green);
      case TrendLabelKey.notEnough:
        return _TrendLabelData(
          'Baseline Only',
          Icons.fiber_manual_record,
          Colors.grey,
        );
      case TrendLabelKey.cannotCompare:
        return _TrendLabelData(
          'Non-comparable',
          Icons.warning_amber,
          Colors.orange,
        );
    }
  }
}

class _TrendLabelData {
  final String label;
  final IconData icon;
  final Color color;

  _TrendLabelData(this.label, this.icon, this.color);
}
