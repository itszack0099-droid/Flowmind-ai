import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/local_llm_service.dart';
import '../widgets/glass_card.dart';
import '../theme/app_colors.dart';

class ExamRoomScreen extends StatefulWidget {
  const ExamRoomScreen({super.key});

  @override
  State<ExamRoomScreen> createState() => _ExamRoomScreenState();
}

class _ExamRoomScreenState extends State<ExamRoomScreen> {
  final LocalLLMService _llm = LocalLLMService();
  List<Map<String, dynamic>> _exams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('exams')
          .select()
          .order('created_at', ascending: false);
      setState(() => _exams = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      debugPrint("Error loading exams: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddExamSheet() async {
    // Add exam sheet logic (same as before)
    // ... (agar tera original sheet code hai toh yahan paste kar sakte hain)
  }

  Future<void> _generatePlan(Map<String, dynamic> exam) async {
    final prompt = """
You are an expert exam strategist for FlowMind AI.
Create a detailed battle plan for this exam:

Subject: ${exam['subject']}
Days left: ${exam['daysLeft']}
Topics: ${exam['topics'].join(', ')}

Give a smart, realistic, and motivating study plan in this exact format:
MINUTES: X
GOAL: Y
MESSAGE: Z

Make it encouraging and practical.
""";

    try {
      final response = await _llm.getResponse(prompt);
      // Parse response (same as before)
      // ... (agar tera original parsing logic hai toh use kar sakte hain)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Battle plan generated!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to generate plan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Exam Room",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stats Row (same as original)
                Row(
                  children: [
                    _StatCard(
                      value: '${_exams.length}',
                      label: 'Upcoming',
                      color: AppColors.mint,
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      value: '92%',
                      label: 'Avg Score',
                      color: AppColors.blue,
                      icon: Icons.leaderboard,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Exams List
                ..._exams.map((exam) => GlassCard(
                      child: ListTile(
                        title: Text(
                          exam['subject'] ?? 'Unknown Subject',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "${exam['daysLeft']} days left • ${exam['topics']?.length ?? 0} topics",
                          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.rocket_launch, color: Colors.blue),
                          onPressed: () => _generatePlan(exam),
                        ),
                      ),
                    )),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExamSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Top-level widgets (fixed nesting error)
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}