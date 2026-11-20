import 'package:flutter/material.dart';

/// An opaque privacy shield widget that obscures sensitive screen contents
/// when the user switches apps or when the application is inactive.
class PrivacyShield extends StatefulWidget {
  final Widget child;
  final bool enableRecentsShield;

  const PrivacyShield({
    super.key,
    required this.child,
    this.enableRecentsShield = true,
  });

  @override
  State<PrivacyShield> createState() => _PrivacyShieldState();
}

class _PrivacyShieldState extends State<PrivacyShield>
    with WidgetsBindingObserver {
  bool _isBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enableRecentsShield) return;

    final shouldCover = state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden;

    if (shouldCover != _isBackgrounded) {
      setState(() {
        _isBackgrounded = shouldCover;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isBackgrounded)
          Positioned.fill(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'PreNest Protected Screen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
