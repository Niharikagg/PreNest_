import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'app_l10n.dart';

/// Text-to-Speech service wrapping FlutterTts for reading content aloud
/// in English, Hindi, and Kannada.
class TtsService {
  final FlutterTts _flutterTts;

  TtsService({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts();

  /// Reads aloud [text] using the appropriate TTS locale for [lang].
  /// Cancels any currently active speech, sets speech rate to 0.48, and initiates speak.
  /// Wrapped in try/catch to gracefully handle unsupported platforms or missing voices.
  Future<void> speak(String text, AppLanguage lang) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage(lang.ttsLocale);
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TtsService speak warning/error: $e');
    }
  }

  /// Stops any currently playing speech audio safely.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TtsService stop warning/error: $e');
    }
  }
}

/// Riverpod provider delivering the application's singleton [TtsService].
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(() {
    service.stop();
  });
  return service;
});
