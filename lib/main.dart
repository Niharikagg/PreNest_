import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/security/app_security_service.dart';
import 'core/security/flutter_secure_key_storage.dart';
import 'core/security/local_auth_biometric_authenticator.dart';
import 'features/lock/app_lock_gate.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.securityService});

  final AppSecurityService? securityService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppSecurityService _securityService =
      widget.securityService ??
      AppSecurityService(
        authenticator: LocalAuthBiometricAuthenticator(),
        secureStorage: FlutterSecureKeyStorage(),
      );

  @override
  void dispose() {
    _securityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PreNest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      builder: (context, child) => AppLockGate(
        securityService: _securityService,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
