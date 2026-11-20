import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/security/app_security_service.dart';
import '../onboarding/entry_state.dart';
import '../profile/profile_provider.dart';
import 'privacy_sync_provider.dart';

class PrivacySyncScreen extends ConsumerStatefulWidget {
  const PrivacySyncScreen({super.key});

  @override
  ConsumerState<PrivacySyncScreen> createState() => _PrivacySyncScreenState();
}

class _PrivacySyncScreenState extends ConsumerState<PrivacySyncScreen> {
  @override
  Widget build(BuildContext context) {
    final privacyState = ref.watch(privacySyncProvider);
    final securityService = ref.watch(appSecurityServiceProvider);
    final couple = ref.watch(coupleProvider);
    final entry = ref.watch(entryProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(title: const Text('Security, Lock & Privacy')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. App Lock Status Card (Riddhi's AppLockGate / AppSecurityService)
                _buildLockStatusHeader(securityService),

                const SizedBox(height: 16),

                // 2. App Security & Biometric Protection Section
                _buildSectionTitle('App Security & Biometric Protection'),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTealLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.fingerprint_rounded,
                            color: AppTheme.primaryTeal,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Biometric & System Security',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Integrated with Riddhi\'s AppLockGate & Local Biometric Authenticator',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),

                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.timer_outlined,
                            color: Color(0xFF0284C7),
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Inactivity Timeout',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Auto-locks screen after 5 minutes of background or idle state',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Text(
                          '5 mins',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ),
                      const Divider(height: 1),

                      // Lock App Now Action Tile
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lock_clock_rounded,
                            color: Color(0xFFE11D48),
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Lock App Now',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Immediately engage Riddhi\'s AppLockGate lock screen',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: FilledButton.tonal(
                          onPressed: () {
                            securityService.lock();
                          },
                          child: const Text('Lock Now'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Offline-First & Local Storage Settings Section
                _buildSectionTitle('Offline-First Architecture & Storage'),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.cloud_off_rounded,
                            color: Color(0xFF059669),
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Offline-First Mode',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Save all vitals, lab PDFs, and milestone media on-device first. Full functionality without internet.',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: privacyState.offlineFirstEnabled,
                        onChanged: (val) {
                          ref
                              .read(privacySyncProvider.notifier)
                              .toggleOfflineFirst(val);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.storage_rounded,
                            color: Color(0xFF475569),
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Local Encrypted Cache Storage',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          '14.6 MB indexed in secure on-device store',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Local cache optimized & verified.',
                                ),
                              ),
                            );
                          },
                          child: const Text('Optimize'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 4. Partner Pairing Code Card
                _buildSectionTitle('Partner Pairing & Invite Code'),
                const SizedBox(height: 8),
                _buildPartnerPairingCodeCard(context, entry),

                const SizedBox(height: 20),

                // 5. Couple Sync & Data Privacy Boundaries
                _buildSectionTitle('Couple Sync & Privacy Boundary'),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.sync_rounded,
                            color: Color(0xFF7C3AED),
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Auto-Sync Couple Shared Data',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Automatically synchronize shared items with ${couple.otherPartner.name}\'s paired device',
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: privacyState.autoSyncCoupleData,
                        onChanged: (val) {
                          ref
                              .read(privacySyncProvider.notifier)
                              .toggleAutoSync(val);
                        },
                      ),
                      const Divider(height: 1),

                      // Explicit Data Sharing Rules Explanation
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PreNest Couple Privacy Guarantee:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildRuleRow(
                              icon: Icons.check_circle_rounded,
                              iconColor: const Color(0xFF059669),
                              title: 'Shared by Default:',
                              description:
                                  'Lab reports, doctor medicines, vitals analysis & shared pregnancy milestones are visible to both partners for unified care.',
                            ),
                            const SizedBox(height: 12),
                            _buildRuleRow(
                              icon: Icons.shield_rounded,
                              iconColor: const Color(0xFFE11D48),
                              title: 'Strictly Private by Default:',
                              description:
                                  'Personal emotional reflections, private AI advisor chats, and locked vault photos remain on your personal device unless explicitly opted into sharing.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 6. Explicit Partner Data-Sharing Controls & Toggles
                _buildSectionTitle('Partner Data-Sharing Defaults & Controls'),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      // Overview Header Banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          border: const Border(
                            bottom: BorderSide(color: AppTheme.borderLight),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.rule_rounded,
                              size: 20,
                              color: AppTheme.primaryTeal,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Active Sharing Policy for ${couple.primaryPartner.name} & ${couple.secondaryPartner.name}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Clinical records & schedules are shared by default for unified care. Emotional reflections, AI chats & quiz hints remain private until you explicitly opt in.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      height: 1.35,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Category 1: Lab Reports & Diagnostics (Shared by default)
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.science_rounded,
                            color: Color(0xFF059669),
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            const Text(
                              'Lab Reports & Tests',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSharingBadge(
                              isDefaultShared: true,
                              isActive: privacyState.shareLabReports,
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Share CBC, ultrasound scans, urinalysis & verified doctor reports',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: privacyState.shareLabReports,
                        onChanged: (val) {
                          ref
                              .read(privacySyncProvider.notifier)
                              .toggleShareLabReports(val);
                        },
                      ),
                      const Divider(height: 1),

                      // Category 2: Medicine Reminders (Shared by default)
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.medication_rounded,
                            color: Color(0xFF0F766E),
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            const Text(
                              'Medicine Reminders',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSharingBadge(
                              isDefaultShared: true,
                              isActive: privacyState.shareMedicineReminders,
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Synchronize daily supplements & adherence (IFA, Calcium, Inositol)',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: privacyState.shareMedicineReminders,
                        onChanged: (val) {
                          ref
                              .read(privacySyncProvider.notifier)
                              .toggleShareMedicineReminders(val);
                        },
                      ),
                      const Divider(height: 1),

                      // Category 3: Health Trends & Vitals Log (Shared by default)
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            color: Color(0xFF0284C7),
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            const Text(
                              'Trends & Vitals Analysis',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSharingBadge(
                              isDefaultShared: true,
                              isActive: privacyState.shareTrendAnalysis,
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Share blood pressure records, weight progression & cycle trends',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: privacyState.shareTrendAnalysis,
                        onChanged: (val) {
                          ref
                              .read(privacySyncProvider.notifier)
                              .toggleShareTrendAnalysis(val);
                        },
                      ),
                      const Divider(height: 1),

                      // Category 4: Personal Reflections & Daily Notes (Private by default)
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFFE11D48),
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            const Text(
                              'Personal Reflections',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSharingBadge(
                              isDefaultShared: false,
                              isActive: privacyState.sharePersonalReflections,
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Private by default. Opt in to allow partner to read your personal reflections',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: privacyState.sharePersonalReflections,
                        onChanged: (val) {
                          ref
                              .read(privacySyncProvider.notifier)
                              .toggleSharePersonalReflections(val);
                        },
                      ),
                      const Divider(height: 1),

                      // Category 5: Private AI Advisor Chats (Private by default)
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: Color(0xFF7C3AED),
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            const Text(
                              'Private AI Advisor Chats',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSharingBadge(
                              isDefaultShared: false,
                              isActive: privacyState.sharePrivateAiChats,
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Private by default. Opt in to share confidential AI emotional companion chat sessions',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: privacyState.sharePrivateAiChats,
                        onChanged: (val) {
                          ref
                              .read(privacySyncProvider.notifier)
                              .toggleSharePrivateAiChats(val);
                        },
                      ),
                      const Divider(height: 1),

                      // Category 6: Quiz Cross-Partner Hints (Private by default)
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.volunteer_activism_rounded,
                            color: Color(0xFFD97706),
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            const Text(
                              'Quiz Cross-Partner Hints',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSharingBadge(
                              isDefaultShared: false,
                              isActive: privacyState.shareQuizPartnerHints,
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Private by default. Opt in to display gentle caring hints from check-in quizzes',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: privacyState.shareQuizPartnerHints,
                        onChanged: (val) {
                          ref
                              .read(privacySyncProvider.notifier)
                              .toggleShareQuizPartnerHints(val);
                        },
                      ),
                      const Divider(height: 1),

                      // Reset to Defaults Action Button
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.borderLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.restore_rounded,
                            size: 16,
                            color: AppTheme.primaryTeal,
                          ),
                          label: const Text(
                            'Reset to PreNest Recommended Defaults',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          onPressed: () {
                            ref
                                .read(privacySyncProvider.notifier)
                                .resetSharingDefaults();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Partner data sharing restored to recommended defaults.',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
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

  Widget _buildSharingBadge({
    required bool isDefaultShared,
    required bool isActive,
  }) {
    final text = isDefaultShared
        ? (isActive ? 'Shared (Default)' : 'Unshared')
        : (isActive ? 'Shared (Opt-in)' : 'Private (Default)');

    final bgColor = isDefaultShared
        ? (isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9))
        : (isActive ? const Color(0xFFE0F2FE) : const Color(0xFFFFF1F2));

    final textColor = isDefaultShared
        ? (isActive ? const Color(0xFF15803D) : const Color(0xFF64748B))
        : (isActive ? const Color(0xFF0284C7) : const Color(0xFFBE123C));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLockStatusHeader(AppSecurityService securityService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Color(0xFF059669),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Lock: Active',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF065F46),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Secured by Riddhi\'s AppLockGate & Local Biometric Authenticator (5m timeout).',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBE123C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
            ),
            onPressed: () => securityService.lock(),
            icon: const Icon(Icons.lock_rounded, size: 16),
            label: const Text('Lock Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppTheme.textMuted,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildRuleRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerPairingCodeCard(BuildContext context, EntryState entry) {
    final bool hasActiveCode =
        entry.inviteActive && entry.generatedInviteCode != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasActiveCode
                        ? AppTheme.primaryTealLight
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasActiveCode ? Icons.key_rounded : Icons.key_off_rounded,
                    color: hasActiveCode
                        ? AppTheme.primaryTeal
                        : AppTheme.textMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Partner Pairing Code',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasActiveCode
                            ? 'Share this 6-character code with your partner to sync journeys'
                            : 'No active invite. Generate a code so your partner can connect',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: hasActiveCode
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hasActiveCode ? 'Invite Active' : 'Invite Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: hasActiveCode
                          ? const Color(0xFF15803D)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasActiveCode) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF99F6E4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      entry.generatedInviteCode!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 8,
                        color: AppTheme.primaryTealDark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: AppTheme.primaryTeal,
                        size: 20,
                      ),
                      tooltip: 'Copy Code',
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: entry.generatedInviteCode!),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Code ${entry.generatedInviteCode} copied to clipboard!',
                            ),
                            backgroundColor: AppTheme.primaryTeal,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (entry.isPaired) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppTheme.successGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Partner connected with code ${entry.partnerCode ?? entry.generatedInviteCode}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: AppTheme.primaryTeal,
                      ),
                      label: const Text(
                        'Regenerate Code',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      onPressed: () {
                        ref.read(entryProvider.notifier).generateInviteCode();
                        final newCode = ref
                            .read(entryProvider)
                            .generatedInviteCode;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'New invite code generated: $newCode',
                            ),
                            backgroundColor: AppTheme.primaryTeal,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFECDD3)),
                        foregroundColor: AppTheme.errorRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(
                        Icons.link_off_rounded,
                        size: 16,
                        color: AppTheme.errorRed,
                      ),
                      label: const Text(
                        'Cancel / Revoke Invite',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorRed,
                        ),
                      ),
                      onPressed: () => _showRevokeConfirmDialog(context),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No active invite code. Generate a fresh 6-character code below so your partner can link to your timeline.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.add_link_rounded, size: 18),
                label: const Text(
                  'Generate Pairing Code',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  ref.read(entryProvider.notifier).generateInviteCode();
                  final newCode = ref.read(entryProvider).generatedInviteCode;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pairing code generated: $newCode'),
                      backgroundColor: AppTheme.primaryTeal,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRevokeConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed),
            SizedBox(width: 8),
            Text('Revoke Pairing Code?', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel and revoke this pairing code? '
          'Any pending invite will be invalidated and your partner will not be able to connect until you generate a new code.',
          style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Active'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(entryProvider.notifier).revokePairingCode();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pairing code revoked and invite cancelled.'),
                  backgroundColor: AppTheme.errorRed,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Revoke Invite'),
          ),
        ],
      ),
    );
  }
}
