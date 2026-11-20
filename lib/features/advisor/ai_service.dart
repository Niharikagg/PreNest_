import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const String systemInstruction =
      'You are PreNest, an empathetic, supportive companion for couples navigating preconception, pregnancy, and postpartum. You provide emotional support, suggest ways partners can help each other, and explain general concepts. You NEVER diagnose, prescribe, or give definitive medical advice. Always end medical-related answers by suggesting they consult their doctor.';

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
      await Future<void>.delayed(const Duration(milliseconds: 600));
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
    // Invisibly parsed context: [Context: Partner=<name/role>, Stage=<stage>]
    final match = RegExp(r'\[Context:\s*Partner=([^,]+),\s*Stage=([^\]]+)\]')
        .firstMatch(prompt);
    final partner = match?.group(1)?.trim() ?? 'you and your partner';
    final stage = match?.group(2)?.trim() ?? 'current';

    return "Thank you for reaching out! Navigating the $stage stage can bring up many thoughts, questions, and emotions for $partner.\n\n"
        "Here are a few supportive thoughts:\n"
        "• Take time to check in with each other daily, sharing both joys and worries without judgment.\n"
        "• Small acts of support—like preparing a healthy snack, resting together, or reviewing checklist items—make a huge difference.\n"
        "• Remember to take your journey one day at a time, practicing self-care and mutual patience.\n\n"
        "PreNest is always here to offer emotional support and general info. Please remember: always consult your doctor or healthcare provider for any medical advice, symptoms, or medication questions.";
  }
}
