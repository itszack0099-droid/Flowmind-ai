import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/local_llm_service.dart';
import '../widgets/glass_card.dart';
import '../theme/app_colors.dart';

class BrainDumpScreen extends StatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  State<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends State<BrainDumpScreen> {
  final LocalLLMService _llm = LocalLLMService();
  final TextEditingController _controller = TextEditingController();
  bool _isProcessing = false;
  String _aiSuggestion = '';

  @override
  void initState() {
    super.initState();
    _initializeLLM();
  }

  Future<void> _initializeLLM() async {
    try {
      await _llm.initializeModel();
    } catch (e) {
      debugPrint("Brain Dump LLM init failed: $e");
    }
  }

  Future<void> _processDump() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isProcessing = true);

    final prompt = """
User ka brain dump: "${_controller.text.trim()}"

Tum FlowMind AI ho. Is brain dump ko analyze karo aur structured output do:

Tasks list banao, priorities set karo, suggested schedule do, aur ek motivating AI tip do.

Output sirf yeh format mein do:
{
  "tasks": ["task1", "task2"],
  "priorities": ["high", "medium"],
  "schedule": "10 AM - Task 1",
  "ai_tip": "Motivating message"
}
""";

    try {
      final response = await _llm.getResponse(prompt);

      setState(() => _aiSuggestion = response);

      // Save to Supabase
      await Supabase.instance.client.from('brain_dumps').insert({
        'content': _controller.text,
        'ai_response': response,
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Brain Dump processed!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to process dump")),
      );
    } finally {
      setState(() => _isProcessing = false);
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
          "Brain Dump",
          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GlassCard(
              child: TextField(
                controller: _controller,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: "Apne dimag mein jo bhi hai, likh do...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isProcessing ? null : _processDump,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Process with AI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 30),

            if (_aiSuggestion.isNotEmpty)
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _aiSuggestion,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}