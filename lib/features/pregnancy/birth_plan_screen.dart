import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import 'birth_plan_provider.dart';

class BirthPlanScreen extends ConsumerStatefulWidget {
  const BirthPlanScreen({super.key});

  @override
  ConsumerState<BirthPlanScreen> createState() => _BirthPlanScreenState();
}

class _BirthPlanScreenState extends ConsumerState<BirthPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _facilityNameController;
  late TextEditingController _facilityPhoneController;
  late TextEditingController _transportNameController;
  late TextEditingController _transportPhoneController;
  late TextEditingController _donorNameController;
  late TextEditingController _donorBloodGroupController;
  late TextEditingController _donorPhoneController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(birthPlanProvider);
    _facilityNameController = TextEditingController(text: state.facilityName);
    _facilityPhoneController = TextEditingController(text: state.facilityPhone);
    _transportNameController = TextEditingController(text: state.transportName);
    _transportPhoneController = TextEditingController(text: state.transportPhone);
    _donorNameController = TextEditingController(text: state.donorName);
    _donorBloodGroupController = TextEditingController(text: state.donorBloodGroup);
    _donorPhoneController = TextEditingController(text: state.donorPhone);
  }

  @override
  void dispose() {
    _facilityNameController.dispose();
    _facilityPhoneController.dispose();
    _transportNameController.dispose();
    _transportPhoneController.dispose();
    _donorNameController.dispose();
    _donorBloodGroupController.dispose();
    _donorPhoneController.dispose();
    super.dispose();
  }

  void _saveAll() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(birthPlanProvider.notifier);
    notifier.updateFacility(
      name: _facilityNameController.text.trim(),
      phone: _facilityPhoneController.text.trim(),
    );
    notifier.updateTransport(
      name: _transportNameController.text.trim(),
      phone: _transportPhoneController.text.trim(),
    );
    notifier.updateDonor(
      name: _donorNameController.text.trim(),
      bloodGroup: _donorBloodGroupController.text.trim(),
      phone: _donorPhoneController.text.trim(),
    );

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Birth Preparedness Plan updated successfully.'),
        backgroundColor: AppTheme.primaryTeal,
        duration: Duration(seconds: 2),
      ),
    );
  }

  static const _checklistConfig = [
    {
      'key': 'mcp_card',
      'title': 'Mother & Child Protection (MCP) Card',
      'subtitle': 'Essential for hospital admission, immunization records & JSY benefits.',
      'icon': Icons.badge_outlined,
    },
    {
      'key': 'aadhaar_id',
      'title': 'Aadhaar Card / Government Photo ID',
      'subtitle': 'Original & copies for mother and partner for identity verification.',
      'icon': Icons.credit_card_outlined,
    },
    {
      'key': 'lab_reports',
      'title': 'Lab Reports & Ultrasound Folder',
      'subtitle': 'Blood group, Rh factor, hemoglobin, viral markers & latest USG scans.',
      'icon': Icons.folder_shared_outlined,
    },
    {
      'key': 'hospital_bag',
      'title': 'Hospital Bag (Mother & Newborn)',
      'subtitle': 'Maternity clothes, sanitary pads, newborn swaddles, warm clothes & caps.',
      'icon': Icons.luggage_outlined,
    },
    {
      'key': 'emergency_funds',
      'title': 'Emergency Cash & Liquid Funds',
      'subtitle': 'Ready cash set aside for transport, admission deposit, or medicines.',
      'icon': Icons.account_balance_wallet_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final birthPlan = ref.watch(birthPlanProvider);
    final notifier = ref.read(birthPlanProvider.notifier);
    final theme = Theme.of(context);

    final completedCount =
        birthPlan.checklist.values.where((checked) => checked).length;
    final totalCount = _checklistConfig.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Birth Preparedness Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save Plan',
            onPressed: _saveAll,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Overview Banner
                  Card(
                    elevation: 0,
                    color: const Color(0xFFF0FDFA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFF99F6E4)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFBF1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.health_and_safety_outlined,
                              color: AppTheme.primaryTeal,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Preparedness Checklist',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.primaryTealDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$completedCount of $totalCount essential preparations ready',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFFCCFBF1),
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryTeal,
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
                  const SizedBox(height: 20),

                  // Section 1: Planned Delivery Facility
                  _buildSectionHeader(
                    context,
                    icon: Icons.local_hospital_outlined,
                    title: '1. Planned Delivery Facility',
                    subtitle: 'Where you plan to deliver and facility emergency contact',
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _facilityNameController,
                            decoration: const InputDecoration(
                              labelText: 'Facility Name / Hospital',
                              hintText: 'e.g., District Hospital, Maternity Nursing Home',
                              prefixIcon: Icon(Icons.apartment_outlined, size: 20),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Please enter hospital name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _facilityPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Labor Ward / Hospital Phone',
                              hintText: 'e.g., +91 94123 45678',
                              prefixIcon: Icon(Icons.phone_outlined, size: 20),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Please enter contact number'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Emergency Transport Contact
                  _buildSectionHeader(
                    context,
                    icon: Icons.airport_shuttle_outlined,
                    title: '2. Emergency Transport Contact',
                    subtitle: 'Arranged driver, auto, or dedicated ambulance contact',
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _transportNameController,
                            decoration: const InputDecoration(
                              labelText: 'Driver / Transport Service Name',
                              hintText: 'e.g., Ramesh (Neighbor cab) or Ambulance 108',
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Please enter transport contact name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _transportPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Driver Phone / Helpline',
                              hintText: 'e.g., 108 / +91 98765 12345',
                              prefixIcon: Icon(Icons.phone_in_talk_outlined, size: 20),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Please enter phone number'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 3: Identified Blood Donor
                  _buildSectionHeader(
                    context,
                    icon: Icons.bloodtype_outlined,
                    title: '3. Identified Blood Donor',
                    subtitle: 'Contact ready in advance in case blood transfusion is required',
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _donorNameController,
                            decoration: const InputDecoration(
                              labelText: 'Donor Name & Relation',
                              hintText: 'e.g., Suresh Patel (Brother / Relative)',
                              prefixIcon: Icon(Icons.person_pin_outlined, size: 20),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Please enter blood donor name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _donorBloodGroupController,
                                  decoration: const InputDecoration(
                                    labelText: 'Blood Group',
                                    hintText: 'e.g., B+ Positive, O-',
                                    prefixIcon: Icon(Icons.opacity_outlined, size: 20),
                                  ),
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                          ? 'Blood group'
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _donorPhoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Donor Phone',
                                    hintText: '+91 98111 22334',
                                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                                  ),
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                          ? 'Phone number'
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 4: Checklist of Essentials
                  _buildSectionHeader(
                    context,
                    icon: Icons.checklist_outlined,
                    title: '4. Checklist of Essentials',
                    subtitle: 'Items to keep packed and ready before 36 weeks',
                  ),
                  const SizedBox(height: 10),
                  ..._checklistConfig.map((item) {
                    final key = item['key'] as String;
                    final title = item['title'] as String;
                    final subtitle = item['subtitle'] as String;
                    final icon = item['icon'] as IconData;
                    final isChecked = birthPlan.checklist[key] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      color: isChecked ? const Color(0xFFF0FDF4) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isChecked
                              ? const Color(0xFFBBF7D0)
                              : AppTheme.borderLight,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: isChecked,
                        activeColor: AppTheme.successGreen,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        secondary: CircleAvatar(
                          radius: 18,
                          backgroundColor: isChecked
                              ? const Color(0xFFDCFCE7)
                              : theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            icon,
                            size: 18,
                            color: isChecked
                                ? AppTheme.successGreen
                                : AppTheme.textMuted,
                          ),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                            color: isChecked
                                ? const Color(0xFF166534)
                                : AppTheme.textDark,
                          ),
                        ),
                        subtitle: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isChecked
                                ? const Color(0xFF15803D).withOpacity(0.8)
                                : AppTheme.textMuted,
                          ),
                        ),
                        onChanged: (_) {
                          notifier.toggleChecklistItem(key);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Section 5: Government Scheme Info Card (JSY & PMMVY)
                  _buildSectionHeader(
                    context,
                    icon: Icons.account_balance_outlined,
                    title: '5. Government Scheme Information',
                    subtitle: 'National maternity benefit and institutional delivery schemes',
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // JSY Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.stars_rounded,
                                      color: Color(0xFFD97706),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Janani Suraksha Yojana (JSY)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'A safe motherhood intervention under the National Health Mission (NHM). '
                                  'Provides financial assistance (ranging from ₹1,000 to ₹1,400 depending on rural/urban categorization) '
                                  'for institutional deliveries in public and accredited private facilities.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF78350F),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // PMMVY Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.volunteer_activism_rounded,
                                      color: Color(0xFF059669),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Direct Benefit Transfer (DBT) providing financial support of ₹5,000 in instalments '
                                  'to pregnant and lactating mothers for wage compensation and nutritional well-being for the first live birth, '
                                  'with enhanced support for girl children under PMMVY 2.0.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF047857),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Note on ASHA/ANM verification
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceMuted,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppTheme.textMuted,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Important: Scheme rules, entitlement brackets, and registration formalities '
                                    'differ across states and parity. Please confirm your eligibility, bank account linkage (Aadhaar DBT enabled), '
                                    'and paperwork with your local ASHA worker, ANM, or delivery facility.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                      height: 1.35,
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
                  const SizedBox(height: 24),

                  // Save Button
                  FilledButton.icon(
                    onPressed: _saveAll,
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('Save Birth Preparedness Plan'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryTeal),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
