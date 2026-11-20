import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const String systemInstruction =
      'You are PreNest, an empathetic, supportive emotional companion and communication guide for couples navigating preconception, cycle care, pregnancy, and postpartum. You support both partners (mothers, fathers, and primary caregivers). You suggest loving, practical ways partners can support one another, explain concepts warmly, and help reduce anxiety. You NEVER diagnose, prescribe, or give definitive medical advice or medication dosages. Always remind users to consult their healthcare provider for medical evaluation and treatment.';

  final String _apiKey;
  GenerativeModel? _model;

  AiService({String? apiKey})
    : _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY') {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(systemInstruction),
      );
    }
  }

  bool get isConfigured => _apiKey.isNotEmpty && _model != null;

  Future<String> sendMessage(String prompt) async {
    if (_apiKey.isEmpty || _model == null) {
      // Simulate natural response latency in demo mode
      await Future<void>.delayed(const Duration(milliseconds: 650));
      return _generateDemoResponse(prompt);
    }

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.trim().isNotEmpty) {
        return text.trim();
      }
      return _generateDemoResponse(prompt);
    } catch (_) {
      // Fall back gracefully on network or API failures
      return _generateDemoResponse(prompt);
    }
  }

  String _generateDemoResponse(String prompt) {
    // Invisibly parsed context:
    // [Context: Partner=<name/role>, OtherPartner=<name/role>, Mode=<mode>, Stage=<stage>, ActivePartnerHint=<hint>]
    final partnerMatch = RegExp(r'Partner=([^,]+)').firstMatch(prompt);
    final otherPartnerMatch = RegExp(r'OtherPartner=([^,]+)')
        .firstMatch(prompt);
    final modeMatch = RegExp(r'Mode=([^,]+)').firstMatch(prompt);
    final stageMatch = RegExp(r'Stage=([^,]+)').firstMatch(prompt);
    final hintMatch = RegExp(r'ActivePartnerHint=([^\]]+)').firstMatch(prompt);

    final partner = partnerMatch?.group(1)?.trim() ?? 'you';
    final otherPartner = otherPartnerMatch?.group(1)?.trim() ?? 'your partner';
    final mode = modeMatch?.group(1)?.trim() ?? 'Journey';
    final stage = stageMatch?.group(1)?.trim() ?? 'current';
    final rawHint = hintMatch?.group(1)?.trim() ?? 'None';
    final hasHint = rawHint.isNotEmpty && rawHint != 'None';

    final lowerPrompt = prompt.toLowerCase();

    // Contextual hint mention if active
    final hintCallout = hasHint
        ? "\n\n🌱 **Partner Smart Hint**: $rawHint\nKeeping this gentle signal in mind makes mutual support feel effortless today."
        : "";

    // Medical disclaimer reminder
    const disclaimer =
        "\n\n🩺 *Gentle Reminder*: PreNest is here for emotional reassurance and general guidance. Always consult your doctor or healthcare provider for medical diagnosis, symptoms, or medication advice.";

    if (lowerPrompt.contains('support my partner') ||
        lowerPrompt.contains('support her') ||
        lowerPrompt.contains('support him')) {
      return "Supporting $otherPartner in the $mode mode ($stage) is all about consistent, small acts of care:\n\n"
          "1. **Proactive Ownership**: Take charge of small daily tasks (like restocking water, preparing a meal, or setting up a calm wind-down) without waiting to be asked.\n"
          "2. **Attentive Listening**: Spend 10–15 minutes sitting together without screens. Ask: *\"How is your body feeling today?\"* and simply listen without trying to fix everything.\n"
          "3. **Attend Checkups Together**: Offer to review upcoming questions and hold the records folder.\n"
          "4. **Shared Routines**: Celebrate small milestones together and remind each other that you are an equal team.$hintCallout$disclaimer";
    }

    if (lowerPrompt.contains('questions for next doctor visit') ||
        lowerPrompt.contains('doctor visit') ||
        lowerPrompt.contains('anc')) {
      return "Here is a thoughtful checklist of questions tailored for your $mode ($stage) consultation:\n\n"
          "• **Vitals & Trends**: \"Are our blood pressure, weight, and lab trends progressing within the expected range?\"\n"
          "• **Supplements & Timing**: \"Could you confirm the best timing and gap between our daily supplements (like iron, calcium, or preconception vitamins)?\"\n"
          "• **Symptoms & Discomfort**: \"Are the symptoms we are observing (such as fatigue, nausea, or cramping) typical, and what warning signs should prompt an earlier visit?\"\n"
          "• **Next Milestone**: \"What specific scan, lab test, or dietary adjustment is planned for our next visit?\"\n\n"
          "Write these down in your notes before walking in so you both feel calm and organized.$hintCallout$disclaimer";
    }

    if (lowerPrompt.contains('overwhelmed') ||
        lowerPrompt.contains('unwind') ||
        lowerPrompt.contains('stress') ||
        lowerPrompt.contains('anxious')) {
      return "Take a deep, slow breath right now. It is completely normal to feel overwhelmed during the $stage stage—your body and mind are navigating immense changes.\n\n"
          "Here are three gentle ways to ground yourself:\n"
          "• **The 4-4-6 Breath**: Inhale slowly through your nose for 4 counts, hold gently for 4, and release through your mouth for 6. Repeat 3 times.\n"
          "• **Release the Pressure**: You do not have to have everything figured out today. Taking care of today's hydration and rest is already a victory.\n"
          "• **Share the Feeling**: Let $otherPartner know you are feeling stretched. Often, just naming the fatigue out loud cuts the stress in half.$hintCallout$disclaimer";
    }

    if (lowerPrompt.contains('pcos') || lowerPrompt.contains('cycle fatigue')) {
      return "Navigating cycle variations and PCOD/PCOS takes patience and self-compassion. Hormonal shifts can impact energy, mood, and sleep rhythms:\n\n"
          "• Prioritize protein and healthy fats with meals to stabilize energy levels.\n"
          "• Honor your rest—gentle movement like a stroll or gentle stretching is far more restorative than high-intensity strain on low-energy days.\n"
          "• Remember: PreNest's Irregular Cycle Mode is designed to protect your peace of mind with zero stressful 'late' alerts.$hintCallout$disclaimer";
    }

    if (lowerPrompt.contains('postpartum') ||
        lowerPrompt.contains('baby blues')) {
      return "The fourth trimester is a profound physical and emotional transition. Healing tissue, fluctuating hormones, and fragmented sleep require village-level care:\n\n"
          "• Protect 3-hour unbroken sleep blocks by coordinating shifts with $otherPartner.\n"
          "• It is normal to feel weepiness or vulnerability in the first two weeks (the 'baby blues').\n"
          "• If emotional heaviness, anxiety, or detachment lasts beyond 2 weeks, reaching out for compassionate care is a sign of strength. India's Tele-MANAS toll-free line is 14416 (available 24/7).$hintCallout$disclaimer";
    }

    // Default warm and structured response
    return "Thank you for reaching out, $partner. Navigating the $mode mode ($stage) brings up many thoughts, feelings, and questions for both you and $otherPartner.\n\n"
        "Here are a few supportive thoughts for today:\n"
        "• **Take it one day at a time**: Health and family journeys are built on consistent daily nourishment and emotional presence.\n"
        "• **Keep communication open**: Share joys, worries, and fatigue with each other without judgment.\n"
        "• **Lean into shared habits**: Checking off daily reminders, going for an evening walk, and resting together make the journey joyful.$hintCallout$disclaimer";
  }
}
