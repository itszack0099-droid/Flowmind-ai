import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/groq_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  // Chat history for context
  final List<Map<String, String>> _history = [];

  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'ai',
      'text': 'Hello! I am your AI Mentor. I am here to help you with studies, career advice, planning, or anything else on your mind. What would you like to work on today?',
      'time': '10:00 AM',
    },
  ];

  final List<String> _suggestions = [
    'Help me study',
    'Plan my day',
    'Career advice',
    'I am feeling stuck',
  ];

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final time = TimeOfDay.now().format(context);

    setState(() {
      _messages.add({'role': 'user', 'text': text, 'time': time});
      _history.add({'role': 'user', 'content': text});
      _isTyping = true;
      _controller.clear();
    });

    _scrollToBottom();

    // Get real AI response from Groq
    final response = await GroqService.chat(
      userMessage: text,
      history: _history.length > 10
          ? _history.sublist(_history.length - 10)
          : _history,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'ai',
          'text': response,
          'time': TimeOfDay.now().format(context),
        });
        _history.add({'role': 'assistant', 'content': response});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _history.clear();
      _messages.add({
        'role': 'ai',
        'text': 'Chat cleared. How can I help you today?',
        'time': TimeOfDay.now().format(context),
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.07)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.mint, AppColors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mint.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FlowMind AI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textLight : AppColors.textDark,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.mint,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _isTyping ? 'Thinking...' : 'Online — Always ready',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.mint,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearChat,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Icon(
                          CupertinoIcons.trash,
                          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                itemCount: _messages.length +
                    (_isTyping ? 1 : 0) +
                    (_messages.length == 1 ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_messages.length == 1 && index == 1) {
                    return _buildSuggestions();
                  }
                  final msgIndex = _messages.length == 1 ? index - 1 : index;
                  if (_isTyping && msgIndex == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  if (msgIndex < 0 || msgIndex >= _messages.length) {
                    return const SizedBox();
                  }
                  final msg = _messages[msgIndex];
                  final isAI = msg['role'] == 'ai';

                  return FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        mainAxisAlignment: isAI
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isAI) ...[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [AppColors.mint, AppColors.purple],
                                ),
                              ),
                              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: isAI
                                    ? null
                                    : const LinearGradient(
                                        colors: [AppColors.mint, AppColors.purple],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                color: isAI ? Colors.white.withOpacity(0.06) : null,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isAI ? 4 : 18),
                                  bottomRight: Radius.circular(isAI ? 18 : 4),
                                ),
                                border: isAI
                                    ? Border.all(color: Colors.white.withOpacity(0.08))
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg['text']!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: isAI
                                          ? (isDark ? AppColors.textLight : AppColors.textDark)
                                          : Colors.white,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    msg['time']!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: isAI
                                          ? AppColors.mutedDark
                                          : Colors.white.withOpacity(0.6),
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
                },
              ),
            ),

            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.07)),
                ),
                color: isDark ? AppColors.bgDark : AppColors.bgLight,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Icon(
                      CupertinoIcons.mic,
                      color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: isDark ? AppColors.textLight : AppColors.textDark,
                        ),
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Ask anything...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(_controller.text),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.mint, AppColors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(CupertinoIcons.arrow_up, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 38),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _suggestions.map((s) {
          return GestureDetector(
            onTap: () => _sendMessage(s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.mint.withOpacity(0.1),
                border: Border.all(color: AppColors.mint.withOpacity(0.25)),
              ),
              child: Text(
                s,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mint,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.mint, AppColors.purple]),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mint.withOpacity(0.6),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
