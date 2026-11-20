import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/contracts/extraction_service.dart';
import '../core/contracts/trend_service.dart';
import '../core/contracts/validity_engine.dart';
import '../core/di.dart';
import '../core/security/app_security_service.dart';
import '../core/security/flutter_secure_key_storage.dart';
import '../core/security/local_auth_biometric_authenticator.dart';
import '../features/reminders/local_reminder_service.dart';
import '../features/reports/capture/document_scanner_service.dart';
import '../features/trends/default_trend_service.dart';
import '../features/validity/default_validity_engine.dart';

export '../core/di.dart';

/// Provider for Riddhi's AppSecurityService.
final appSecurityServiceProvider = Provider<AppSecurityService>((ref) {
  final service = AppSecurityService(
    authenticator: LocalAuthBiometricAuthenticator(),
    secureStorage: FlutterSecureKeyStorage(),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for clinical lab extraction service (ML Kit with graceful fallback).
final extractionServiceProvider = Provider<ExtractionService>((ref) {
  final useMock = ref.watch(useMockExtractionProvider);
  if (useMock) {
    return ref.watch(mockExtractionServiceProvider);
  }
  return ref.watch(mlKitExtractionServiceProvider);
});

/// Provider for Pooja's clinical lab validity engine.
final validityEngineProvider = Provider<ValidityEngine>((ref) {
  return const DefaultValidityEngine();
});

/// Provider for Pooja's trend service, backed by DefaultValidityEngine.
final trendServiceProvider = Provider<TrendService>((ref) {
  final validityEngine = ref.watch(validityEngineProvider);
  return DefaultTrendService(validityEngine: validityEngine);
});

/// Provider for Pooja's persistent local reminder service.
final localReminderServiceProvider = Provider<LocalReminderService>((ref) {
  return LocalReminderService();
});

/// Provider for Niharika's document scanner service.
final documentScannerServiceProvider = Provider<DocumentScannerService>((ref) {
  return const DocumentScannerService();
});
