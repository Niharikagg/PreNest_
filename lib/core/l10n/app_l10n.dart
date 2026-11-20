import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported application languages with live localization and TTS locale support.
enum AppLanguage {
  en(label: 'English', ttsLocale: 'en-IN'),
  hi(label: 'हिन्दी', ttsLocale: 'hi-IN'),
  kn(label: 'ಕನ್ನಡ', ttsLocale: 'kn-IN');

  final String label;
  final String ttsLocale;

  const AppLanguage({required this.label, required this.ttsLocale});
}

/// Riverpod State Notifier managing active language preference.
class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => AppLanguage.en;

  void setLanguage(AppLanguage lang) {
    state = lang;
  }
}

/// Provider for the currently active AppLanguage.
final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(
  LanguageNotifier.new,
);

/// Pure-Dart translations map for compile-time safety and zero codegen dependencies.
class AppStrings {
  static const Map<String, Map<AppLanguage, String>> _localizedValues = {
    // Bottom Navigation Bar
    'Timeline': {
      AppLanguage.en: 'Timeline',
      AppLanguage.hi: 'टाइमलाइन',
      AppLanguage.kn: 'ಟೈಮ್‌ಲೈನ್‌',
    },
    'Records': {
      AppLanguage.en: 'Records',
      AppLanguage.hi: 'रिकॉर्ड्स',
      AppLanguage.kn: 'ದಾಖಲೆಗಳು',
    },
    'Verify': {
      AppLanguage.en: 'Verify',
      AppLanguage.hi: 'सत्यापित करें',
      AppLanguage.kn: 'ಪರಿಶೀಲಿಸಿ',
    },
    'Trends': {
      AppLanguage.en: 'Trends',
      AppLanguage.hi: 'ट्रेंड्स',
      AppLanguage.kn: 'ಟ್ರೆಂಡ್‌ಗಳು',
    },
    'Doctor Summary': {
      AppLanguage.en: 'Doctor Summary',
      AppLanguage.hi: 'डॉक्टर सारांश',
      AppLanguage.kn: 'ವೈದ್ಯರ ಸಾರಾಂಶ',
    },

    // Modes & Stages
    'Period Tracker': {
      AppLanguage.en: 'Period Tracker',
      AppLanguage.hi: 'पीरियड ट्रैकर',
      AppLanguage.kn: 'ಮುಟ್ಟು ಟ್ರ್ಯಾಕರ್',
    },
    'Plan': {
      AppLanguage.en: 'Plan',
      AppLanguage.hi: 'योजना',
      AppLanguage.kn: 'ಯೋಜನೆ',
    },
    'Planning': {
      AppLanguage.en: 'Planning',
      AppLanguage.hi: 'योजना',
      AppLanguage.kn: 'ಯೋಜನೆ',
    },
    'Trying': {
      AppLanguage.en: 'Trying',
      AppLanguage.hi: 'प्रयास',
      AppLanguage.kn: 'ಪ್ರಯತ್ನ',
    },
    'Pregnancy': {
      AppLanguage.en: 'Pregnancy',
      AppLanguage.hi: 'गर्भावस्था',
      AppLanguage.kn: 'ಗರ್ಭಾವಸ್ಥೆ',
    },
    'Pregnant': {
      AppLanguage.en: 'Pregnant',
      AppLanguage.hi: 'गर्भवती',
      AppLanguage.kn: 'ಗರ್ಭಿಣಿ',
    },
    'Postpartum': {
      AppLanguage.en: 'Postpartum',
      AppLanguage.hi: 'प्रसवोत्तर',
      AppLanguage.kn: 'ಪ್ರಸವೋತ್ತರ',
    },

    // Key Actions & Headings
    'Checklist': {
      AppLanguage.en: 'Checklist',
      AppLanguage.hi: 'चेकलिस्ट',
      AppLanguage.kn: 'ಪರಿಶೀಲನಾ ಪಟ್ಟಿ',
    },
    'Danger Signs': {
      AppLanguage.en: 'Danger Signs',
      AppLanguage.hi: 'खतरे के संकेत',
      AppLanguage.kn: 'ಅಪಾಯದ ಚಿಹ್ನೆಗಳು',
    },
    'Vitals Log': {
      AppLanguage.en: 'Vitals Log',
      AppLanguage.hi: 'वाइटल्स लॉग',
      AppLanguage.kn: 'ಪ್ರಮುಖ ಆರೋಗ್ಯ ದಾಖಲೆ',
    },
    'Kick Counter': {
      AppLanguage.en: 'Kick Counter',
      AppLanguage.hi: 'किक काउंटर',
      AppLanguage.kn: 'ಕಿಕ್ ಕೌಂಟರ್',
    },
    'Contraction Timer': {
      AppLanguage.en: 'Contraction Timer',
      AppLanguage.hi: 'संकुचन टाइमर',
      AppLanguage.kn: 'ಸಂಕೋಚನ ಟೈಮರ್',
    },
    'ANC Visit Planner': {
      AppLanguage.en: 'ANC Visit Planner',
      AppLanguage.hi: 'एएनसी विजिट प्लानर',
      AppLanguage.kn: 'ಎಎನ್‌ಸಿ ಭೇಟಿ ಯೋಜಕ',
    },
    'ANC Planner': {
      AppLanguage.en: 'ANC Planner',
      AppLanguage.hi: 'एएनसी प्लानर',
      AppLanguage.kn: 'ಎಎನ್‌ಸಿ ಯೋಜಕ',
    },
    'Birth Plan': {
      AppLanguage.en: 'Birth Plan',
      AppLanguage.hi: 'प्रसव योजना',
      AppLanguage.kn: 'ಜನನ ಯೋಜನೆ',
    },
    'Postpartum Care': {
      AppLanguage.en: 'Postpartum Care',
      AppLanguage.hi: 'प्रसवोत्तर देखभाल',
      AppLanguage.kn: 'ಪ್ರಸವಾನಂತರದ ಆರೈಕೆ',
    },
    'Medicine Reminders': {
      AppLanguage.en: 'Medicine Reminders',
      AppLanguage.hi: 'दवा अनुस्मारक',
      AppLanguage.kn: 'ಔಷಧ ಜ್ಞಾಪನೆಗಳು',
    },
    'Shared Calendar': {
      AppLanguage.en: 'Shared Calendar',
      AppLanguage.hi: 'साझा कैलेंडर',
      AppLanguage.kn: 'ಹಂಚಿಕೊಂಡ ಕ್ಯಾಲೆಂಡರ್',
    },
    'Symptom Checker': {
      AppLanguage.en: 'Symptom Checker',
      AppLanguage.hi: 'लक्षण परीक्षक',
      AppLanguage.kn: 'ಲಕ್ಷಣ ಪರೀಕ್ಷಕ',
    },
    'Couple Quizzes': {
      AppLanguage.en: 'Couple Quizzes',
      AppLanguage.hi: 'दंपति प्रश्नोत्तरी',
      AppLanguage.kn: 'ದಂಪತಿ ರಸಪ್ರಶ್ನೆಗಳು',
    },
    'AI Advisor': {
      AppLanguage.en: 'AI Advisor',
      AppLanguage.hi: 'एआई सलाहकार',
      AppLanguage.kn: 'ಎಐ ಸಲಹೆಗಾರ',
    },
    'Media Vault': {
      AppLanguage.en: 'Media Vault',
      AppLanguage.hi: 'मीडिया वॉल्ट',
      AppLanguage.kn: 'ಮಾಧ್ಯಮ ವಾಲ್ಟ್',
    },
    'Privacy & Lock': {
      AppLanguage.en: 'Privacy & Lock',
      AppLanguage.hi: 'गोपनीयता और लॉक',
      AppLanguage.kn: 'ಗೌಪ್ಯತೆ ಮತ್ತು ಲಾಕ್',
    },
    'Language': {
      AppLanguage.en: 'Language',
      AppLanguage.hi: 'भाषा',
      AppLanguage.kn: 'ಭಾಷೆ',
    },

    // Shortcuts & Hub Titles
    'Cycle & PCOS Hub': {
      AppLanguage.en: 'Cycle & PCOS Hub',
      AppLanguage.hi: 'मासिक धर्म और पीसीओएस हब',
      AppLanguage.kn: 'ಮುಟ್ಟು ಮತ್ತು ಪಿಸಿಓಎಸ್ ಕೇಂದ್ರ',
    },
    'Planning Hub': {
      AppLanguage.en: 'Planning Hub',
      AppLanguage.hi: 'योजना केंद्र',
      AppLanguage.kn: 'ಯೋಜನಾ ಕೇಂದ್ರ',
    },
    'Active Journey Stage': {
      AppLanguage.en: 'Active Journey Stage',
      AppLanguage.hi: 'सक्रिय यात्रा चरण',
      AppLanguage.kn: 'ಸಕ್ರಿಯ ಹಂತ',
    },
    'Stage Checklist Progress': {
      AppLanguage.en: 'Stage Checklist Progress',
      AppLanguage.hi: 'चरण चेकलिस्ट प्रगति',
      AppLanguage.kn: 'ಹಂತದ ಪರಿಶೀಲನಾ ಪಟ್ಟಿ ಪ್ರಗತಿ',
    },
    'Critical triage & 108 dispatch': {
      AppLanguage.en: 'Critical triage & 108 dispatch',
      AppLanguage.hi: 'गंभीर ट्राइएज और 108 सहायता',
      AppLanguage.kn: 'ತುರ್ತು ಚಿಕಿತ್ಸೆ ಮತ್ತು 108 ನೆರವು',
    },
    'Track BP & weight metrics': {
      AppLanguage.en: 'Track BP & weight metrics',
      AppLanguage.hi: 'बीपी और वजन ट्रैक करें',
      AppLanguage.kn: 'ಬಿಪಿ ಮತ್ತು ತೂಕವನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡಿ',
    },
    'Read aloud': {
      AppLanguage.en: 'Read aloud',
      AppLanguage.hi: 'बोलकर सुनें',
      AppLanguage.kn: 'ಓದಿ ಹೇಳಿ',
    },
    'Select Active Partner Profile': {
      AppLanguage.en: 'Select Active Partner Profile',
      AppLanguage.hi: 'सक्रिय साथी प्रोफ़ाइल चुनें',
      AppLanguage.kn: 'ಸಕ್ರಿಯ ಪಾಲುದಾರ ಪ್ರೊಫೈಲ್ ಆಯ್ಕೆಮಾಡಿ',
    },
    'Switch Partner Profile': {
      AppLanguage.en: 'Switch Partner Profile',
      AppLanguage.hi: 'साथी प्रोफ़ाइल बदलें',
      AppLanguage.kn: 'ಪಾಲುದಾರರ ಪ್ರೊಫೈಲ್ ಬದಲಿಸಿ',
    },

    // Danger Signs Screen
    'Danger-Sign Checker': {
      AppLanguage.en: 'Danger-Sign Checker',
      AppLanguage.hi: 'खतरे के संकेत जांच',
      AppLanguage.kn: 'ಅಪಾಯದ ಚಿಹ್ನೆಗಳ ಪರಿಶೀಲಕ',
    },
    'Seek medical care immediately': {
      AppLanguage.en: 'Seek medical care immediately',
      AppLanguage.hi: 'तुरंत चिकित्सा सहायता लें',
      AppLanguage.kn: 'ತಕ್ಷಣ ವೈದ್ಯಕೀಯ ನೆರವು ಪಡೆಯಿರಿ',
    },
    'Call 108': {
      AppLanguage.en: 'Call 108',
      AppLanguage.hi: '108 पर कॉल करें',
      AppLanguage.kn: '108 ಗೆ ಕರೆ ಮಾಡಿ',
    },
    'Call Ambulance (108)': {
      AppLanguage.en: 'Call Ambulance (108)',
      AppLanguage.hi: 'एम्बुलेंस (108) को कॉल करें',
      AppLanguage.kn: 'ಆಂಬ್ಯುಲೆನ್ಸ್‌ಗೆ ಕರೆ ಮಾಡಿ (108)',
    },
    'Clear': {
      AppLanguage.en: 'Clear',
      AppLanguage.hi: 'साफ़ करें',
      AppLanguage.kn: 'ತೆರವುಗೊಳಿಸಿ',
    },
    'No critical danger signs reported': {
      AppLanguage.en: 'No critical danger signs reported. Tap any symptom below if you experience it.',
      AppLanguage.hi: 'कोई गंभीर खतरे के लक्षण नहीं मिले। यदि कोई लक्षण महसूस हो तो नीचे चुनें।',
      AppLanguage.kn: 'ಯಾವುದೇ ಗಂಭೀರ ಅಪಾಯದ ಚಿಹ್ನೆಗಳು ವರದಿಯಾಗಿಲ್ಲ. ಯಾವುದೇ ಲಕ್ಷಣ ಅನುಭವಿಸಿದರೆ ಕೆಳಗೆ ಟ್ಯಾಪ್ ಮಾಡಿ.',
    },
    'critical_warning_prefix': {
      AppLanguage.en: 'CRITICAL WARNING: Danger sign(s) detected! ',
      AppLanguage.hi: 'गंभीर चेतावनी: खतरे के लक्षण का पता चला! ',
      AppLanguage.kn: 'ತೀವ್ರ ಎಚ್ಚರಿಕೆ: ಅಪಾಯದ ಲಕ್ಷಣ ಕಂಡುಬಂದಿದೆ! ',
    },
    'critical_warning_body': {
      AppLanguage.en: 'Go to the nearest emergency health facility or hospital immediately.',
      AppLanguage.hi:
          'तुरंत निकटतम आपातकालीन स्वास्थ्य केंद्र या अस्पताल जाएं।',
      AppLanguage.kn:
          'ತಕ್ಷಣ ಹತ್ತಿರದ ತುರ್ತು ಆರೋಗ್ಯ ಕೇಂದ್ರ ಅಥವಾ ಆಸ್ಪತ್ರೆಗೆ ಭೇಟಿ ನೀಡಿ.',
    },

    // Individual Danger Signs (Titles, Descriptions, Notes)
    'heavy_bleeding_title': {
      AppLanguage.en: 'Heavy Vaginal Bleeding',
      AppLanguage.hi: 'अत्यधिक योनि रक्तस्राव',
      AppLanguage.kn: 'ತೀವ್ರ ಯೋನಿ ರಕ್ತಸ್ರಾವ',
    },
    'heavy_bleeding_desc': {
      AppLanguage.en:
          'Soaking a sanitary pad in under 1-2 hours or passing large clots.',
      AppLanguage.hi:
          '1-2 घंटे में सैनिटरी पैड का पूरी तरह भीगना या बड़े थक्के निकलना।',
      AppLanguage.kn: '1-2 ಗಂಟೆಗಳಲ್ಲಿ ಸ್ಯಾನಿಟರಿ ಪ್ಯಾಡ್ ಸಂಪೂರ್ಣ ನೆನೆಯುವುದು ಅಥವಾ ದೊಡ್ಡ ರಕ್ತ ಹೆಪ್ಪುಗಟ್ಟುವಿಕೆ.',
    },
    'heavy_bleeding_note': {
      AppLanguage.en:
          'High risk: Placental abruption, placenta previa, or hemorrhage.',
      AppLanguage.hi: 'उच्च जोखिम: प्लेसेंटल एब्स्ट्रक्शन, प्लेसेंटा प्रिविया या अत्यधिक रक्तस्राव।',
      AppLanguage.kn:
          'ಹೆಚ್ಚಿನ ಅಪಾಯ: ಜರಾಯು ಬೇರ್ಪಡುವಿಕೆ, ಪ್ಲಾಸೆಂಟಾ ಪ್ರೀವಿಯಾ ಅಥವಾ ರಕ್ತಸ್ರಾವ.',
    },

    'severe_headache_vision_title': {
      AppLanguage.en: 'Severe Headache with Blurred Vision',
      AppLanguage.hi: 'धुंधली दृष्टि के साथ तेज सिरदर्द',
      AppLanguage.kn: 'ಮಸುಕಾದ ದೃಷ್ಟಿಯೊಂದಿಗೆ ತೀವ್ರ ತಲೆನೋವು',
    },
    'severe_headache_vision_desc': {
      AppLanguage.en: 'Pounding headache, flashing lights, aura, or sudden visual disturbance.',
      AppLanguage.hi: 'तेज सिरदर्द, चमकती रोशनी, या अचानक देखने में परेशानी।',
      AppLanguage.kn: 'ವಿಪರೀತ ತಲೆನೋವು, ಮಿಂಚಿನ ಬೆಳಕು, ಅಥವಾ ಹಠಾತ್ ದೃಷ್ಟಿ ದೋಷ.',
    },
    'severe_headache_vision_note': {
      AppLanguage.en:
          'High risk: Impending eclampsia or acute gestational hypertension.',
      AppLanguage.hi:
          'उच्च जोखिम: आसन्न एक्लम्पसिया या गंभीर गर्भावधि उच्च रक्तचाप।',
      AppLanguage.kn:
          'ಹೆಚ್ಚಿನ ಅಪಾಯ: ಎಕ್ಲಾಂಪ್ಸಿಯಾ ಅಥವಾ ತೀವ್ರ ಗರ್ಭಾವಸ್ಥೆಯ ಅಧಿಕ ರಕ್ತದೊತ್ತಡ.',
    },

    'fits_seizures_title': {
      AppLanguage.en: 'Fits or Seizures / Convulsions',
      AppLanguage.hi: 'दौरे या ऐंठन',
      AppLanguage.kn: 'ಫಿಟ್ಸ್ ಅಥವಾ ಸೆಳೆತ',
    },
    'fits_seizures_desc': {
      AppLanguage.en:
          'Uncontrollable shaking, spasms, or momentary loss of consciousness.',
      AppLanguage.hi: 'अनियंत्रित कंपन, ऐंठन या अचानक बेहोशी।',
      AppLanguage.kn: 'ನಿಯಂತ್ರಿಸಲಾಗದ ನಡುಕ, ಸೆಳೆತ ಅಥವಾ ಪ್ರಜ್ಞೆ ಕಳೆದುಕೊಳ್ಳುವುದು.',
    },
    'fits_seizures_note': {
      AppLanguage.en: 'Immediate critical emergency: Eclampsia convulsion.',
      AppLanguage.hi: 'तत्काल गंभीर आपात स्थिति: एक्लम्पसिया दौरा।',
      AppLanguage.kn: 'ತಕ್ಷಣದ ತುರ್ತು ಪರಿಸ್ಥಿತಿ: ಎಕ್ಲಾಂಪ್ಸಿಯಾ ಸೆಳೆತ.',
    },

    'reduced_fetal_movement_title': {
      AppLanguage.en: 'Reduced or Absent Baby Movement',
      AppLanguage.hi: 'शिशु की हलचल में कमी या अभाव',
      AppLanguage.kn: 'ಮಗುವಿನ ಚಲನೆ ಕಡಿಮೆಯಾಗುವುದು ಅಥವಾ ನಿಲ್ಲುವುದು',
    },
    'reduced_fetal_movement_desc': {
      AppLanguage.en:
          'Substantial drop in kick count or no movement felt over 2-3 hours.',
      AppLanguage.hi:
          'किक की संख्या में भारी कमी या 2-3 घंटे तक कोई हलचल न होना।',
      AppLanguage.kn: 'ಕಿಕ್ ಎಣಿಕೆಯಲ್ಲಿ ಗಣನೀಯ ಇಳಿಕೆ ಅಥವಾ 2-3 ಗಂಟೆಗಳ ಕಾಲ ಯಾವುದೇ ಚಲನೆ ಇಲ್ಲದಿರುವುದು.',
    },
    'reduced_fetal_movement_note': {
      AppLanguage.en:
          'Urgent: Possible fetal compromise requiring immediate CTG scan.',
      AppLanguage.hi: 'अति आवश्यक: तत्काल सीटीजी स्कैन की आवश्यकता।',
      AppLanguage.kn:
          'ತುರ್ತು: ತಕ್ಷಣದ ಸಿಟಿಜಿ ಸ್ಕ್ಯಾನ್ ಅಗತ್ಯವಿರುವ ಸಂಭವನೀಯ ಭ್ರೂಣದ ತೊಂದರೆ.',
    },

    'high_fever_chills_title': {
      AppLanguage.en: 'High Fever & Severe Chills',
      AppLanguage.hi: 'तेज बुखार और तेज ठंड लगना',
      AppLanguage.kn: 'ತೀವ್ರ ಜ್ವರ ಮತ್ತು ನಡುಕ',
    },
    'high_fever_chills_desc': {
      AppLanguage.en: 'Temperature over 101°F (38.3°C) with persistent shivering or rigors.',
      AppLanguage.hi: '101°F (38.3°C) से अधिक तापमान के साथ लगातार कंपकंपी।',
      AppLanguage.kn: '101°F (38.3°C) ಗಿಂತ ಹೆಚ್ಚಿನ ಜ್ವರ ಮತ್ತು ನಿರಂತರ ನಡುಕ.',
    },
    'high_fever_chills_note': {
      AppLanguage.en: 'Risk of intra-amniotic infection (chorioamnionitis) or maternal sepsis.',
      AppLanguage.hi: 'गर्भाशय संक्रमण या मातृ सेप्सिस का जोखिम।',
      AppLanguage.kn: 'ಗರ್ಭಕೋಶದ ಸೋಂಕು ಅಥವಾ ಸೆಪ್ಸಿಸ್ ಅಪಾಯ.',
    },

    'severe_abdominal_pain_title': {
      AppLanguage.en: 'Severe Persistent Abdominal Pain',
      AppLanguage.hi: 'पेट में लगातार तेज दर्द',
      AppLanguage.kn: 'ಹೊಟ್ಟೆಯಲ್ಲಿ ತೀವ್ರ ನಿರಂತರ ನೋವು',
    },
    'severe_abdominal_pain_desc': {
      AppLanguage.en: 'Constant sharp or rigid abdominal cramps, distinct from normal Braxton-Hicks.',
      AppLanguage.hi: 'पेट में लगातार तेज ऐंठन जो सामान्य संकुचन से अलग हो।',
      AppLanguage.kn: 'ಸಾಮಾನ್ಯ ಬ್ರಾಕ್ಸ್‌ಟನ್-ಹಿಕ್ಸ್ ಗಿಂತ ಭಿನ್ನವಾದ ನಿರಂತರ ತೀವ್ರ ಹೊಟ್ಟೆ ಸೆಳೆತ.',
    },
    'severe_abdominal_pain_note': {
      AppLanguage.en:
          'Critical: Possible uterine rupture, abruption, or acute abdomen.',
      AppLanguage.hi: 'गंभीर: गर्भाशय फटने या प्लेसेंटा अलग होने का जोखिम।',
      AppLanguage.kn: 'ಗಂಭೀರ: ಗರ್ಭಾಶಯ ಛಿದ್ರ ಅಥವಾ ಜರಾಯು ಬೇರ್ಪಡುವ ಸಾಧ್ಯತೆ.',
    },

    'fluid_leakage_title': {
      AppLanguage.en: 'Amniotic Fluid Leakage (Water Break)',
      AppLanguage.hi: 'एमनियोटिक द्रव का रिसाव (पानी छूटना)',
      AppLanguage.kn: 'ಉಲ್ಬದ್ರವ ಸೋರಿಕೆ (ನೀರು ಒಡೆಯುವುದು)',
    },
    'fluid_leakage_desc': {
      AppLanguage.en: 'Continuous trickle or sudden rush of clear/greenish fluid from vagina.',
      AppLanguage.hi: 'योनि से लगातार या अचानक पानी जैसा स्राव होना।',
      AppLanguage.kn: 'ಯೋನಿಯಿಂದ ನಿರಂತರವಾಗಿ ಅಥವಾ ಹಠಾತ್ತನೆ ದ್ರವ ಸೋರಿಕೆಯಾಗುವುದು.',
    },
    'fluid_leakage_note': {
      AppLanguage.en: 'Premature rupture of membranes (PROM) requiring immediate sterile evaluation.',
      AppLanguage.hi:
          'झिल्ली का समय से पहले फटना (PROM), तत्काल परीक्षण आवश्यक।',
      AppLanguage.kn: 'ಪೊರೆಯ ಅಕಾಲಿಕ ಛಿದ್ರ (PROM), ತಕ್ಷಣದ ಪರೀಕ್ಷೆ ಅಗತ್ಯ.',
    },
  };

  /// Translate a given key to the specified [AppLanguage].
  /// Falls back to English, or returns the key if not found.
  static String t(String key, AppLanguage lang) {
    return _localizedValues[key]?[lang] ??
        _localizedValues[key]?[AppLanguage.en] ??
        key;
  }
}
