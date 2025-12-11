import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../services/ai_service.dart';

class TravelChatScreen extends StatefulWidget {
  const TravelChatScreen({super.key});

  @override
  State<TravelChatScreen> createState() => _TravelChatScreenState();
}

class _TravelChatScreenState extends State<TravelChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<ChatMessage> messages = [
    ChatMessage(
      "Hi! I’m your AI travel buddy. Ask me anything about destinations, itineraries or budgets",
      false,
    ),
  ];

  bool _loading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> sendMsg([String? preset]) async {
    final text = (preset ?? controller.text).trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      messages.add(ChatMessage(text, true));
      controller.clear();
      _loading = true;
    });

    try {
      final reply = await AIService.chatReply(text);
      if (!mounted) return;
      setState(() {
        messages.add(ChatMessage(reply, false));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        messages.add(
          ChatMessage(
            "Sorry, I couldn’t reach the travel AI service. Please try again.",
            false,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text('AI Travel Assistant', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050816),
              Color(0xFF09152B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Try: “3-day budget trip to Bali”, “Compare Paris vs Rome for 5 days”, or “Best time to visit Japan”.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _SuggestionChip(
                    label: '3 days in Kyoto',
                    onTap: () => sendMsg("Plan a 3-day trip to Kyoto"),
                  ),
                  _SuggestionChip(
                    label: 'Backpacking Europe',
                    onTap: () => sendMsg(
                      "Backpacking through Europe for 2 weeks on a budget",
                    ),
                  ),
                  _SuggestionChip(
                    label: 'Solo trip ideas',
                    onTap: () =>
                        sendMsg("Solo-friendly destinations from Bangladesh"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length + (_loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_loading && index == messages.length) {
                    return const _TypingBubble();
                  }

                  final msg = messages[index];
                  final isUser = msg.isUser;

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.78,
                      ),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF246BFD),
                                  Color(0xFF4ADEDE),
                                ],
                              )
                            : null,
                        color: isUser
                            ? null
                            : Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft:
                              Radius.circular(isUser ? 18 : 4),
                          bottomRight:
                              Radius.circular(isUser ? 4 : 18),
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _ChatInput(
              controller: controller,
              onSend: () => sendMsg(),
              loading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: false,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 8,
              height: 8,
              child: CircularProgressIndicator(strokeWidth: 1.8),
            ),
            SizedBox(width: 8),
            Text('Thinking...'),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool loading;

  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ask anything about your trip…',
                  prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF246BFD),
                    Color(0xFF4ADEDE),
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: IconButton(
                icon: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                color: Colors.white,
                onPressed: loading ? null : onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
