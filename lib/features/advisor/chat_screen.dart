import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/profile_provider.dart';
import '../stage/stage.dart';
import '../stage/stage_provider.dart';
import 'ai_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmitted() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final couple = ref.watch(coupleProvider);
    final stage = ref.watch(stageProvider);
    final theme = Theme.of(context);

    // Scroll down when messages change or loading state toggles
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isLoading != next.isLoading) {
        _scrollToBottom();
      }
    });

    final itemCount = chatState.messages.length + (chatState.isLoading ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PreNest AI Advisor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${couple.activePartner.name} (${couple.activePartner.role}) • ${stage.displayName}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear Chat',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Disclaimer Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Emotional support & general info only — not medical advice.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chat Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  // Show loading indicator as the last item if loading
                  if (index == chatState.messages.length) {
                    return _buildLoadingBubble(theme);
                  }

                  final message = chatState.messages[index];
                  return _buildMessageBubble(context, message, theme);
                },
              ),
            ),

            // Bottom Text Field + Send Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Ask PreNest anything...',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.4),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _handleSubmitted(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: chatState.isLoading ? null : _handleSubmitted,
                    icon: const Icon(Icons.send_rounded),
                    tooltip: 'Send message',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    ThemeData theme,
  ) {
    final isUser = message.isUser;
    final timeStr = TimeOfDay.fromDateTime(message.timestamp).format(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 10,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.favorite,
                    size: 11,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'PreNest',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                timeStr,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            child: Material(
              color: isUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              elevation: 0.5,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isUser
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.favorite,
                  size: 11,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'PreNest is thinking...',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Material(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Thinking...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
