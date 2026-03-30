import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/widgets/gradient_text.dart';
import '../../../../core/ai/ai_engine.dart';
import '../../../../data/hive/hive_initializer.dart';
import '../../data/models/chat_message_model.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <ChatMessageModel>[];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // Add welcome message if empty
    if (_messages.isEmpty) {
      _messages.add(ChatMessageModel(
        id: const Uuid().v4(),
        text: '👋 Hey! I\'m your AI inventory assistant.\n\n'
            'I can help you with:\n'
            '• 📊 Stock analysis & insights\n'
            '• 🔮 Demand forecasting\n'
            '• 🚨 Anomaly detection\n'
            '• 📝 Product categorization\n'
            '• 🤝 Supplier recommendations\n\n'
            'Just ask me anything about your inventory!',
        isUser: false,
        provider: 'system',
        timestamp: DateTime.now(),
      ));
    }
  }

  void _loadHistory() {
    try {
      final box = Hive.box<ChatMessageModel>(HiveBoxes.chatMessages);
      _messages.addAll(box.values.toList());
    } catch (_) {}
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  const GradientText(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (_isTyping)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Thinking...',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Quick action chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _QuickChip('📊 Stock Summary', () => _sendMessage('Give me a stock summary')),
                  _QuickChip('⚠️ Low Stock', () => _sendMessage('Which products are low on stock?')),
                  _QuickChip('🔮 Forecast', () => _sendMessage('Generate a demand forecast')),
                  _QuickChip('🚨 Anomalies', () => _sendMessage('Detect any anomalies')),
                  _QuickChip('💡 Optimize', () => _sendMessage('How can I optimize my inventory?')),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _ChatBubble(message: _messages[i]),
              ),
            ),

            // Typing indicator
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI is thinking...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Input
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textCtrl,
                        decoration: InputDecoration(
                          hintText: 'Ask about your inventory...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10,
                          ),
                        ),
                        maxLines: 3,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, size: 20),
                        color: Colors.white,
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    _textCtrl.text = text;
    _send();
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();

    // Add user message
    final userMsg = ChatMessageModel(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      provider: 'user',
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      // Save to Hive
      final chatBox = Hive.box<ChatMessageModel>(HiveBoxes.chatMessages);
      await chatBox.put(userMsg.id, userMsg);

      // Get AI response
      final engine = InvXAIEngine.instance;
      if (!engine.fallbackManager.costTracker.canUsePaidProvider()) {
        // Engine might not be initialized, try to initialize
        await engine.initialize();
      }
      final response = await engine.chat(text);

      final aiMsg = ChatMessageModel(
        id: const Uuid().v4(),
        text: response.text,
        isUser: false,
        provider: response.provider,
        timestamp: DateTime.now(),
        latencyMs: response.latencyMs,
        cost: response.cost,
      );

      await chatBox.put(aiMsg.id, aiMsg);

      setState(() {
        _messages.add(aiMsg);
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessageModel(
          id: const Uuid().v4(),
          text: '⚠️ Error: ${e.toString()}\n\n'
              'Tip: Make sure AI providers are configured in Settings.',
          isUser: false,
          provider: 'error',
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: isUser ? 60 : 0,
        right: isUser ? 0 : 60,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: isUser ? AppColors.primaryGradient : null,
              color: isUser ? null : AppColors.card,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: isUser
                  ? null
                  : Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: isUser ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUser && message.provider != 'system') ...[
                Text(
                  '${message.provider} • ',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
