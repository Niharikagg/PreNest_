import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/models/trend_summary.dart';
import '../../core/models/verified_result.dart';
import '../profile/profile_provider.dart';
import 'records_provider.dart';

class TestDetailScreen extends ConsumerWidget {
  final String testName;

  const TestDetailScreen({super.key, required this.testName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePartner = ref.watch(coupleProvider).activePartner;
    final partnerRecords = ref.watch(activePartnerRecordsProvider);
    final testRecords =
        partnerRecords
            .where((r) => r.testNameStd.toLowerCase() == testName.toLowerCase())
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final trendService = ref.read(trendServiceProvider);
    final trendSummary = trendService.summarize(testRecords);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          testName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: testRecords.isEmpty
          ? Center(child: Text('No records found for "$testName"'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Patient banner
                  _buildPatientHeader(
                    context,
                    activePartner,
                    testRecords.last.unit,
                  ),
                  const SizedBox(height: 16),

                  // Trend Summary Card
                  _buildTrendSummaryCard(
                    context,
                    trendSummary,
                    testRecords.last.unit,
                  ),
                  const SizedBox(height: 16),

                  // Range Position Visualizer
                  _buildRangePositionCard(context, trendSummary),
                  const SizedBox(height: 24),

                  // History Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historical Readings (${testRecords.length})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Chronological',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...testRecords.reversed.map(
                    (record) => _buildHistoryItem(context, record),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildPatientHeader(
    BuildContext context,
    PartnerProfile partner,
    String unit,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            radius: 18,
            child: Text(
              partner.initials,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${partner.name} (${partner.role})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'PreNest Profile • Standard Unit: $unit',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSummaryCard(
    BuildContext context,
    TrendSummary summary,
    String unit,
  ) {
    final labelInfo = _getTrendLabelInfo(summary.labelKey);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trend Trajectory',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: labelInfo.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: labelInfo.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(labelInfo.icon, size: 16, color: labelInfo.color),
                      const SizedBox(width: 6),
                      Text(
                        labelInfo.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: labelInfo.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Value',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          summary.latestValue != null
                              ? summary.latestValue.toString()
                              : '--',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                if (summary.change != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Baseline Shift',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${summary.change! >= 0 ? "+" : ""}${summary.change} $unit (${summary.changePercent! >= 0 ? "+" : ""}${summary.changePercent}%)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: summary.change! > 0
                              ? Colors.teal.shade700
                              : summary.change! < 0
                              ? Colors.indigo.shade700
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  summary.canCompare
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  size: 16,
                  color: summary.canCompare
                      ? Colors.green.shade700
                      : Colors.amber.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    summary.reason,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangePositionCard(BuildContext context, TrendSummary summary) {
    final pos = summary.positionInRange ?? 0.5;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Range Position Indicator',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Normalized relative standing within expected clinical target boundaries',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            // Position Gauge Bar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF90CAF9), // Low zone
                        Color(0xFFA5D6A7), // Optimal zone
                        Color(0xFFFFCC80), // High zone
                      ],
                    ),
                  ),
                ),
                // Indicator marker
                LayoutBuilder(
                  builder: (context, constraints) {
                    final leftOffset = (constraints.maxWidth - 20) * pos;
                    return Positioned(
                      left: leftOffset,
                      top: -6,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low / Sub-optimal',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                Text(
                  'Optimal Target',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                Text(
                  'High / Elevated',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, VerifiedResult record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.event_note, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(record.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Stage: ${_capitalize(record.stage)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.value} ${record.unit}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: record.status == VerificationStatus.confirmed
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  record.status == VerificationStatus.confirmed
                      ? 'Confirmed'
                      : 'Corrected',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: record.status == VerificationStatus.confirmed
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static _TrendLabelData _getTrendLabelInfo(TrendLabelKey key) {
    switch (key) {
      case TrendLabelKey.firstResult:
        return _TrendLabelData(
          'Baseline Set',
          Icons.flag_outlined,
          Colors.blue,
        );
      case TrendLabelKey.changeTwo:
        return _TrendLabelData(
          'Two-Point Trend',
          Icons.compare_arrows,
          Colors.purple,
        );
      case TrendLabelKey.movingUpSoFar:
        return _TrendLabelData(
          'Upward Trajectory',
          Icons.trending_up,
          Colors.teal,
        );
      case TrendLabelKey.movingDownSoFar:
        return _TrendLabelData(
          'Downward Shift',
          Icons.trending_down,
          Colors.indigo,
        );
      case TrendLabelKey.steady:
        return _TrendLabelData(
          'Stable Trend',
          Icons.trending_flat,
          Colors.green,
        );
      case TrendLabelKey.notEnough:
        return _TrendLabelData(
          'Single Reading',
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

  static String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _capitalize(String str) {
    if (str.isEmpty) return str;
    return '${str[0].toUpperCase()}${str.substring(1)}';
  }
}

class _TrendLabelData {
  final String label;
  final IconData icon;
  final Color color;

  _TrendLabelData(this.label, this.icon, this.color);
}
