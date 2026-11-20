import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../couple/couple_hints_provider.dart';
import '../onboarding/mode_selection_state.dart';
import '../profile/profile_provider.dart';
import '../stage/stage.dart';
import '../stage/stage_provider.dart';
import 'ai_service.dart';

@immutable
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

@immutable
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  const ChatState({required this.messages, this.isLoading = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

class ChatNotifier extends Notifier<ChatState> {
  late final AiService _aiService;

  @override
  ChatState build() {
    _aiService = ref.watch(aiServiceProvider);
    return ChatState(
      messages: [
        ChatMessage(
          text: "Hello! I'm PreNest, your empathetic emotional companion and couple communication guide. I'm here to support you and your partner with reassurance, mutual care tips, and general healthcare insights. What's on your mind today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: false,
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMessage = ChatMessage(
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Immediately post user message and show loading indicator
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    // Read active context without showing prefix in the UI
    final stage = ref.read(stageProvider);
    final couple = ref.read(coupleProvider);
    final modeState = ref.read(modeSelectionProvider);
    final hintsState = ref.read(coupleHintsProvider);

    final activePartner = couple.activePartner;
    final otherPartner = couple.otherPartner;
    final activeMode = modeState.activeMode(stage);

    final activeHint = hintsState.activeSmartHint;
    final hintContext = (activeHint != null && activeHint.hintText.isNotEmpty)
        ? 'ActivePartnerHint=${activeHint.fromPartnerName}: "${activeHint.hintText}"'
        : 'ActivePartnerHint=None';

    final contextPrefix =
        '[Context: Partner=${activePartner.name}/${activePartner.role}, OtherPartner=${otherPartner.name}/${otherPartner.role}, Mode=${activeMode.title}, Stage=${stage.displayName}, $hintContext]';
    final invisiblePrompt = '$contextPrefix $trimmed';

    try {
      final reply = await _aiService.sendMessage(invisiblePrompt);
      final aiMessage = ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (_) {
      final fallbackMessage = ChatMessage(
        text: "I'm here for you, but I had trouble processing that just now. Please try again in a moment. Always consult your doctor for medical advice or urgent concerns.",
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, fallbackMessage],
        isLoading: false,
      );
    }
  }

  void clearChat() {
    state = ChatState(
      messages: [
        ChatMessage(
          text: "Hello! I'm PreNest, your empathetic companion. What's on your mind today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: false,
    );
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});
