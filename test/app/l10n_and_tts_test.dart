import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/core/l10n/app_l10n.dart';
import 'package:prenest/core/l10n/tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLanguage and Translations', () {
    test('AppLanguage en, hi, kn metadata', () {
      expect(AppLanguage.en.label, 'English');
      expect(AppLanguage.en.ttsLocale, 'en-IN');

      expect(AppLanguage.hi.label, 'हिन्दी');
      expect(AppLanguage.hi.ttsLocale, 'hi-IN');

      expect(AppLanguage.kn.label, 'ಕನ್ನಡ');
      expect(AppLanguage.kn.ttsLocale, 'kn-IN');
    });

    test('AppStrings translations for bottom nav tabs', () {
      expect(AppStrings.t('Timeline', AppLanguage.en), 'Timeline');
      expect(AppStrings.t('Timeline', AppLanguage.hi), 'टाइमलाइन');
      expect(AppStrings.t('Timeline', AppLanguage.kn), 'ಟೈಮ್‌ಲೈನ್‌');

      expect(AppStrings.t('Records', AppLanguage.en), 'Records');
      expect(AppStrings.t('Verify', AppLanguage.hi), 'सत्यापित करें');
      expect(AppStrings.t('Trends', AppLanguage.kn), 'ಟ್ರೆಂಡ್‌ಗಳು');
    });

    test('AppStrings translations for danger sign checker and emergency', () {
      expect(
        AppStrings.t('Danger-Sign Checker', AppLanguage.en),
        'Danger-Sign Checker',
      );
      expect(
        AppStrings.t('Danger-Sign Checker', AppLanguage.hi),
        'खतरे के संकेत जांच',
      );
      expect(
        AppStrings.t('Danger-Sign Checker', AppLanguage.kn),
        'ಅಪಾಯದ ಚಿಹ್ನೆಗಳ ಪರಿಶೀಲಕ',
      );

      expect(
        AppStrings.t('Seek medical care immediately', AppLanguage.hi),
        'तुरंत चिकित्सा सहायता लें',
      );
      expect(AppStrings.t('Call 108', AppLanguage.kn), '108 ಗೆ ಕರೆ ಮಾಡಿ');
    });

    test('LanguageNotifier switches language state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(languageProvider), AppLanguage.en);

      container.read(languageProvider.notifier).setLanguage(AppLanguage.hi);
      expect(container.read(languageProvider), AppLanguage.hi);

      container.read(languageProvider.notifier).setLanguage(AppLanguage.kn);
      expect(container.read(languageProvider), AppLanguage.kn);
    });

    test('TtsService instance is created without throwing', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final tts = container.read(ttsServiceProvider);
      expect(tts, isA<TtsService>());
      // Safe stop and speak calls
      await tts.stop();
      await tts.speak('Test', AppLanguage.en);
    });
  });
}
