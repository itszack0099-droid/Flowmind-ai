import 'dart:math';
import 'dart:async';   // ← Yeh line zaroori hai (Timer ke liye)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/local_llm_service.dart';
import '../widgets/glass_card.dart';
import '../theme/app_colors.dart';

class CandleFocusScreen extends StatefulWidget {
  const CandleFocusScreen({super.key});

  @override
  State<CandleFocusScreen> createState() => _CandleFocusScreenState();
}

class _CandleFocusScreenState extends State<CandleFocusScreen> with TickerProviderStateMixin {
  final LocalLLMService _llm = LocalLLMService();

  late AnimationController _flameController;
  late Animation<double> _flameAnimation;
  late AnimationController _glowController;

  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _useAIMode = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _flameAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(_flameController);

    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);

    _initializeLocalModel();
  }

  Future<void> _initializeLocalModel() async {
    try {
      await _llm.initializeModel();
    } catch (e) {
      debugPrint("Candle screen model init failed: $e");
    }
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _totalSeconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    _saveSession();
  }

  Future<void> _saveSession() async {
    final minutes = _totalSeconds \~/ 60;
    if (minutes < 1) return;

    final xp = minutes * 2;

    try {
      await Supabase.instance.client.from('study_sessions').insert({
        'minutes': minutes,
        'xp_earned': xp,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {}
  }

  Future<void> _getAISuggestion() async {
    final prompt = "You are a deep focus mentor. User has been focusing for ${_totalSeconds \~/ 60} minutes. Give a short, motivating one-line message.";
    try {
      final response = await _llm.getResponse(prompt);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.trim())));
    } catch (e) {}
  }

  @override
  void dispose() {
    _flameController.dispose();
    _glowController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _totalSeconds \~/ 60;
    final seconds = _totalSeconds % 60;

    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Candle Focus", style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),

            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) => Container(
                        width: 180,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 60 + _glowController.value * 20, spreadRadius: 20)],
                        ),
                      ),
                    ),
                    Container(width: 60, height: 220, decoration: BoxDecoration(color: const Color(0xFFFFE4C4), borderRadius: BorderRadius.circular(8))),
                    AnimatedBuilder(
                      animation: _flameAnimation,
                      builder: (context, child) => Transform.scale(scale: _flameAnimation.value, child: const Icon(Icons.whatshot, size: 80, color: Colors.orange)),
                    ),
                  ],
                ),
              ),
            ),

            Text(
              "\( {minutes.toString().padLeft(2, '0')}: \){seconds.toString().padLeft(2, '0')}",
              style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  style: ElevatedButton.styleFrom(backgroundColor: _isRunning ? Colors.red : Colors.green),
                  child: Text(_isRunning ? "Stop" : "Start Focus"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _getAISuggestion,
                  child: const Text("AI Suggestion"),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}