import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DangerSign {
  final String id;
  final String title;
  final String description;
  final String emergencyNote;
  final IconData icon;

  const DangerSign({
    required this.id,
    required this.title,
    required this.description,
    required this.emergencyNote,
    required this.icon,
  });
}

const List<DangerSign> kDangerSigns = [
  DangerSign(
    id: 'heavy_bleeding',
    title: 'Heavy Vaginal Bleeding',
    description:
        'Soaking a sanitary pad in under 1-2 hours or passing large clots.',
    emergencyNote: 'High risk: Placental abruption, placenta previa, or hemorrhage.',
    icon: Icons.bloodtype,
  ),
  DangerSign(
    id: 'severe_headache_vision',
    title: 'Severe Headache with Blurred Vision',
    description:
        'Pounding headache, flashing lights, aura, or sudden visual disturbance.',
    emergencyNote: 'High risk: Impending eclampsia or acute gestational hypertension.',
    icon: Icons.visibility_off,
  ),
  DangerSign(
    id: 'fits_seizures',
    title: 'Fits or Seizures / Convulsions',
    description:
        'Uncontrollable shaking, spasms, or momentary loss of consciousness.',
    emergencyNote: 'Immediate critical emergency: Eclampsia convulsion.',
    icon: Icons.flash_on,
  ),
  DangerSign(
    id: 'reduced_fetal_movement',
    title: 'Reduced or Absent Baby Movement',
    description:
        'Substantial drop in kick count or no movement felt over 2-3 hours.',
    emergencyNote: 'Urgent: Possible fetal compromise requiring immediate CTG scan.',
    icon: Icons.child_care,
  ),
  DangerSign(
    id: 'high_fever_chills',
    title: 'High Fever & Severe Chills',
    description:
        'Temperature over 101°F (38.3°C) with persistent shivering or rigors.',
    emergencyNote: 'Risk of intra-amniotic infection (chorioamnionitis) or maternal sepsis.',
    icon: Icons.thermostat,
  ),
  DangerSign(
    id: 'severe_abdominal_pain',
    title: 'Severe Persistent Abdominal Pain',
    description:
        'Constant sharp or rigid abdominal cramps, distinct from normal Braxton-Hicks.',
    emergencyNote: 'Critical: Possible uterine rupture, abruption, or acute abdomen.',
    icon: Icons.healing,
  ),
  DangerSign(
    id: 'fluid_leakage',
    title: 'Amniotic Fluid Leakage (Water Break)',
    description:
        'Continuous trickle or sudden rush of clear/greenish fluid from vagina.',
    emergencyNote: 'Premature rupture of membranes (PROM) requiring immediate sterile evaluation.',
    icon: Icons.water_drop,
  ),
];

class DangerSignsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggleSymptom(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void reset() {
    state = {};
  }
}

final dangerSignsProvider =
    NotifierProvider<DangerSignsNotifier, Set<String>>(() {
  return DangerSignsNotifier();
});

class DangerSignCheckerScreen extends ConsumerWidget {
  const DangerSignCheckerScreen({super.key});

  void _simulateAmbulanceCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.emergency, color: Colors.red, size: 48),
        title: const Text('Connecting to Emergency (108)...'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulating emergency dispatch call to 108 (National Emergency Ambulance Service).',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Recommended emergency steps:\n'
              '• Lie down on your left side to maintain optimal blood flow.\n'
              '• Keep maternal health records & hospital file ready.\n'
              '• Ensure someone stays by your side until ambulance arrives.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.phone_in_talk),
            label: const Text('Call 108 (Simulated)'),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulated emergency call placed to 108.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
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
    final selectedSigns = ref.watch(dangerSignsProvider);
    final hasCriticalSigns = selectedSigns.isNotEmpty;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danger-Sign Checker'),
        actions: [
          if (hasCriticalSigns)
            TextButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear'),
              onPressed: () {
                ref.read(dangerSignsProvider.notifier).reset();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Prominent MaterialBanner when ANY critical symptom is checked
          if (hasCriticalSigns)
            Container(
              width: double.infinity,
              color: const Color(0xFFFEF2F2),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFECACA),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFDC2626),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'CRITICAL WARNING: ${selectedSigns.length} danger sign(s) detected! '
                                'Go to the nearest emergency health facility or hospital immediately.',
                                style: const TextStyle(
                                  color: Color(0xFF991B1B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.phone_in_talk, size: 20),
                          label: const Text(
                            'Call Ambulance (108)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _simulateAmbulanceCall(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFDCFCE7),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: Color(0xFF15803D), size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No critical danger signs reported. Tap any symptom below if you experience it.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: kDangerSigns.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sign = kDangerSigns[index];
                    final isSelected = selectedSigns.contains(sign.id);

                    return Card(
                      elevation: 0,
                      color: isSelected
                          ? const Color(0xFFFEF2F2)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFFF87171)
                              : theme.colorScheme.outlineVariant,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: isSelected,
                        activeColor: const Color(0xFFDC2626),
                        checkColor: Colors.white,
                        onChanged: (_) {
                          ref
                              .read(dangerSignsProvider.notifier)
                              .toggleSymptom(sign.id);
                        },
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFEE2E2)
                                : theme.colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            sign.icon,
                            color: isSelected
                                ? const Color(0xFFDC2626)
                                : theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          sign.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: isSelected
                                ? const Color(0xFF991B1B)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              sign.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? const Color(0xFF7F1D1D)
                                    : const Color(0xFF475569),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Text(
                                  '⚠ ${sign.emergencyNote}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        isThreeLine: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
