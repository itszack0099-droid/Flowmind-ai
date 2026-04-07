import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/local_llm_service.dart';
import '../services/summarizer_service.dart';
import '../widgets/glass_card.dart';
import '../theme/app_colors.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final LocalLLMService _llm = LocalLLMService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeLLM();
    _addWelcomeMessage();
  }

  Future<void> _initializeLLM() async {
    try {
      await _llm.initializeModel();
    } catch (e) {
      debugPrint("Chat LLM init failed: $e");
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({
        'isUser': false,
        'text': "Namaste! Main FlowMind AI hoon. Aaj kya soch rahe ho? 😊",
      });
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    setState(() {
      _messages.add({'isUser': true, 'text': userMessage});
      _isTyping = true;
    });
    _controller.clear();

    try {
      final response = await _llm.getResponse(userMessage);

      setState(() {
        _messages.add({'isUser': false, 'text': response});
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'isUser': false, 'text': "Sorry, kuch samajh nahi aaya. Phir se try karo."});
        _isTyping = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      _isTyping = true;
    });

    try {
      final file = File(result.files.single.path!);
      final text = await SummarizerService.extractTextFromFile(file);

      final response = await _llm.getResponse("Yeh file ka content hai: $text\nIske baare mein short summary aur advice do.");

      setState(() {
        _messages.add({'isUser': true, 'text': "📎 File uploaded: ${result.files.single.name}"});
        _messages.add({'isUser': false, 'text': response});
        _isTyping = false;
      });
    } catch (e) {
      setState(() => _isTyping = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "AI Mentor",
          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                final isUser = msg['isUser'] as bool;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.blue : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      msg['text'] as String,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text("AI soch raha hai...", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.white70),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Message AI Mentor...",
                      hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}