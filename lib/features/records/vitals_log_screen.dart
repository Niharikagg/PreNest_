import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VitalEntry {
  final String id;
  final int systolicBp;
  final int diastolicBp;
  final double weightKg;
  final DateTime recordedAt;
  final String? note;

  const VitalEntry({
    required this.id,
    required this.systolicBp,
    required this.diastolicBp,
    required this.weightKg,
    required this.recordedAt,
    this.note,
  });

  String get bpCategory {
    if (systolicBp >= 140 || diastolicBp >= 90) {
      return 'High BP';
    } else if ((systolicBp >= 120 && systolicBp <= 139) ||
        (diastolicBp >= 80 && diastolicBp <= 89)) {
      return 'Elevated';
    } else if (systolicBp < 90 || diastolicBp < 60) {
      return 'Low BP';
    } else {
      return 'Normal BP';
    }
  }

  Color get bpColor {
    if (systolicBp >= 140 || diastolicBp >= 90) {
      return Colors.red.shade700;
    } else if ((systolicBp >= 120 && systolicBp <= 139) ||
        (diastolicBp >= 80 && diastolicBp <= 89)) {
      return Colors.orange.shade800;
    } else if (systolicBp < 90 || diastolicBp < 60) {
      return Colors.blue.shade700;
    } else {
      return Colors.green.shade700;
    }
  }
}

class VitalsLogNotifier extends Notifier<List<VitalEntry>> {
  @override
  List<VitalEntry> build() {
    final now = DateTime.now();
    return [
      VitalEntry(
        id: 'vital_002',
        systolicBp: 122,
        diastolicBp: 80,
        weightKg: 59.2,
        recordedAt: now.subtract(const Duration(days: 1, hours: 3)),
        note: 'Resting morning reading',
      ),
      VitalEntry(
        id: 'vital_001',
        systolicBp: 118,
        diastolicBp: 76,
        weightKg: 58.6,
        recordedAt: now.subtract(const Duration(days: 4, hours: 6)),
        note: 'Pre-pregnancy routine baseline',
      ),
    ];
  }

  void addEntry({
    required int systolic,
    required int diastolic,
    required double weight,
    String? note,
  }) {
    final newEntry = VitalEntry(
      id: 'vital_${DateTime.now().millisecondsSinceEpoch}',
      systolicBp: systolic,
      diastolicBp: diastolic,
      weightKg: weight,
      recordedAt: DateTime.now(),
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );
    state = [newEntry, ...state];
  }

  void removeEntry(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final vitalsLogProvider = NotifierProvider<VitalsLogNotifier, List<VitalEntry>>(
  () {
    return VitalsLogNotifier();
  },
);

class VitalsLogScreen extends ConsumerStatefulWidget {
  const VitalsLogScreen({super.key});

  @override
  ConsumerState<VitalsLogScreen> createState() => _VitalsLogScreenState();
}

class _VitalsLogScreenState extends ConsumerState<VitalsLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final systolic = int.parse(_systolicController.text.trim());
    final diastolic = int.parse(_diastolicController.text.trim());
    final weight = double.parse(_weightController.text.trim());
    final note = _noteController.text.trim();

    ref
        .read(vitalsLogProvider.notifier)
        .addEntry(
          systolic: systolic,
          diastolic: diastolic,
          weight: weight,
          note: note.isNotEmpty ? note : null,
        );

    _systolicController.clear();
    _diastolicController.clear();
    _weightController.clear();
    _noteController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vitals recorded successfully.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
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

  @override
  Widget build(BuildContext context) {
    final vitals = ref.watch(vitalsLogProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Vitals Log (BP & Weight)')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Form Card
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
                    padding: const EdgeInsets.all(18.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.monitor_heart,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Record Today\'s Vitals',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Systolic BP
                              Expanded(
                                child: TextFormField(
                                  controller: _systolicController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Systolic BP',
                                    hintText: '120',
                                    suffixText: 'mmHg',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    final parsed = int.tryParse(value.trim());
                                    if (parsed == null) {
                                      return 'Integer only';
                                    }
                                    if (parsed < 60 || parsed > 250) {
                                      return '60-250';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Diastolic BP
                              Expanded(
                                child: TextFormField(
                                  controller: _diastolicController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Diastolic BP',
                                    hintText: '80',
                                    suffixText: 'mmHg',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    final parsed = int.tryParse(value.trim());
                                    if (parsed == null) {
                                      return 'Integer only';
                                    }
                                    if (parsed < 40 || parsed > 160) {
                                      return '40-160';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Weight
                          TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Weight',
                              hintText: '58.5',
                              suffixText: 'kg',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter maternal/partner weight';
                              }
                              final parsed = double.tryParse(value.trim());
                              if (parsed == null) {
                                return 'Enter a valid number';
                              }
                              if (parsed < 30 || parsed > 250) {
                                return 'Enter realistic weight (30-250 kg)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          // Notes (Optional)
                          TextFormField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: 'Optional note / symptom',
                              hintText: 'e.g., Fasting, morning post-walk',
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Save Vitals Entry'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // History Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vitals History (${vitals.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'WHO Guideline: <120/<80',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // History List
                if (vitals.isEmpty)
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(28.0),
                      child: Center(
                        child: Text(
                          'No vitals recorded yet. Use the form above to log.',
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vitals.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = vitals[index];
                      final statusColor = entry.bpColor;

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(3),
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
                                          '${entry.systolicBp}/${entry.diastolicBp} mmHg',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(
                                              0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            entry.bpCategory,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Weight: ${entry.weightKg.toStringAsFixed(1)} kg' +
                                          (entry.note != null
                                              ? ' • ${entry.note}'
                                              : ''),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatDateTime(entry.recordedAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                color: theme.colorScheme.onSurfaceVariant,
                                tooltip: 'Delete entry',
                                onPressed: () {
                                  ref
                                      .read(vitalsLogProvider.notifier)
                                      .removeEntry(entry.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
