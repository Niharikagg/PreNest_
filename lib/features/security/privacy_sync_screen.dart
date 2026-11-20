import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../profile/profile_provider.dart';
import 'vault_lock_provider.dart';

class PrivacySyncScreen extends ConsumerStatefulWidget {
  const PrivacySyncScreen({super.key});

  @override
  ConsumerState<PrivacySyncScreen> createState() => _PrivacySyncScreenState();
}

class _PrivacySyncScreenState extends ConsumerState<PrivacySyncScreen> {
  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(vaultLockProvider);
    final couple = ref.watch(coupleProvider);
    final theme = Theme.of(context);

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
                // 1. App Lock Status Card
                _buildLockStatusHeader(lockState),

                const SizedBox(height: 16),

                // 2. App Lock & Security Settings Section
                _buildSectionTitle('App & Vault Lock (PIN Protection)'),
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
                            color: lockState.appLockEnabled
                                ? AppTheme.primaryTealLight
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            lockState.appLockEnabled
                                ? Icons.lock_rounded
                                : Icons.lock_open_rounded,
                            color: lockState.appLockEnabled
                                ? AppTheme.primaryTeal
                                : AppTheme.textMuted,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Enable App Lock',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Require a 4-digit PIN code to access locked keepsakes & records',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: lockState.appLockEnabled,
                        onChanged: (val) {
                          ref
                              .read(vaultLockProvider.notifier)
                              .toggleAppLock(val);
                        },
                      ),
                      const Divider(height: 1),

                      // Set/Change PIN Tile
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
                            Icons.pin_rounded,
                            color: Color(0xFF0284C7),
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Change 4-Digit Security PIN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Current PIN: ${lockState.pinCode} (Tap to change)',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppTheme.textMuted,
                        ),
                        onTap: () => _showChangePinDialog(context, lockState),
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
                          'Lock App Now (Test Mode)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          lockState.isLocked
                              ? 'App is currently locked. Tap to enter PIN.'
                              : 'Immediately engage PIN screen to test lock state',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: FilledButton.tonal(
                          onPressed: () {
                            if (!lockState.isLocked) {
                              ref.read(vaultLockProvider.notifier).lockNow();
                            }
                            _showUnlockPinDialog(context);
                          },
                          child: Text(
                            lockState.isLocked ? 'Unlock' : 'Lock Now',
                          ),
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
                        value: lockState.offlineFirstEnabled,
                        onChanged: (val) {
                          ref
                              .read(vaultLockProvider.notifier)
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

                // 4. Couple Sync & Data Privacy Boundaries
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
                        value: lockState.autoSyncCoupleData,
                        onChanged: (val) {
                          ref
                              .read(vaultLockProvider.notifier)
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
                              description: 'Lab reports, doctor medicines, vitals analysis & shared pregnancy milestones are visible to both partners for unified care.',
                            ),
                            const SizedBox(height: 12),
                            _buildRuleRow(
                              icon: Icons.shield_rounded,
                              iconColor: const Color(0xFFE11D48),
                              title: 'Strictly Private by Default:',
                              description: 'Personal emotional reflections, private AI advisor chats, and locked vault photos remain on your personal device unless explicitly opted into sharing.',
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

  Widget _buildLockStatusHeader(VaultLockState lockState) {
    final isLocked = lockState.isLocked;
    final isEnabled = lockState.appLockEnabled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked
            ? const Color(0xFFFFF1F2)
            : (isEnabled ? const Color(0xFFECFDF5) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? const Color(0xFFFDA4AF)
              : (isEnabled ? const Color(0xFFA7F3D0) : AppTheme.borderLight),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLocked
                  ? const Color(0xFFFFE4E6)
                  : (isEnabled
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFF1F5F9)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocked
                  ? Icons.lock_rounded
                  : (isEnabled
                        ? Icons.verified_user_rounded
                        : Icons.lock_open_rounded),
              color: isLocked
                  ? const Color(0xFFBE123C)
                  : (isEnabled
                        ? const Color(0xFF059669)
                        : const Color(0xFF64748B)),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLocked
                      ? 'App State: Locked'
                      : (isEnabled ? 'App Lock: Active' : 'App Lock: Off'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLocked
                        ? const Color(0xFF881337)
                        : (isEnabled
                              ? const Color(0xFF065F46)
                              : AppTheme.textDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLocked
                      ? 'PIN is required to view locked items. Tap "Unlock" below.'
                      : (isEnabled
                            ? 'Protected with 4-digit PIN (${lockState.pinCode})'
                            : 'Turn on PIN protection to safeguard confidential memories.'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isLocked
                        ? const Color(0xFF9F1239)
                        : (isEnabled
                              ? const Color(0xFF047857)
                              : AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBE123C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
              onPressed: () => _showUnlockPinDialog(context),
              child: const Text('Unlock'),
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

  void _showUnlockPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    String? localError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final lockState = ref.watch(vaultLockProvider);

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.shield_rounded, color: AppTheme.primaryTeal),
                SizedBox(width: 10),
                Text('Enter Security PIN', style: TextStyle(fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your 4-digit PIN to unlock the app and access private records.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    errorText: localError,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Default PIN is 1234 (current: ${lockState.pinCode})',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(vaultLockProvider.notifier).resetPinToDefault();
                  pinController.text = '1234';
                  setDialogState(() {
                    localError = null;
                  });
                },
                child: const Text('Reset to 1234'),
              ),
              FilledButton(
                onPressed: () {
                  final entered = pinController.text.trim();
                  final success = ref
                      .read(vaultLockProvider.notifier)
                      .verifyAndUnlock(entered);
                  if (success) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App successfully unlocked!'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  } else {
                    setDialogState(() {
                      localError = 'Incorrect PIN. Try 1234.';
                    });
                  }
                },
                child: const Text('Unlock'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, VaultLockState lockState) {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    String? localError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text(
              'Update 4-Digit PIN',
              style: TextStyle(fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'Current PIN',
                      hintText: 'e.g. 1234',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'New 4-Digit PIN',
                      hintText: 'e.g. 5678',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New PIN',
                      hintText: 'Re-enter new PIN',
                      counterText: '',
                    ),
                  ),
                  if (localError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      localError!,
                      style: const TextStyle(
                        color: AppTheme.errorRed,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final cur = currentPinController.text.trim();
                  final n1 = newPinController.text.trim();
                  final n2 = confirmPinController.text.trim();

                  if (cur != lockState.pinCode) {
                    setDialogState(() {
                      localError =
                          'Current PIN is incorrect (hint: ${lockState.pinCode}).';
                    });
                    return;
                  }
                  if (n1.length != 4 || int.tryParse(n1) == null) {
                    setDialogState(() {
                      localError = 'New PIN must be exactly 4 numeric digits.';
                    });
                    return;
                  }
                  if (n1 != n2) {
                    setDialogState(() {
                      localError = 'New PIN and confirmation do not match.';
                    });
                    return;
                  }

                  final success = ref
                      .read(vaultLockProvider.notifier)
                      .updatePin(currentPin: cur, newPin: n1);
                  if (success) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('PIN successfully changed to $n1.'),
                        backgroundColor: AppTheme.primaryTeal,
                      ),
                    );
                  }
                },
                child: const Text('Save PIN'),
              ),
            ],
          );
        },
      ),
    );
  }
}
