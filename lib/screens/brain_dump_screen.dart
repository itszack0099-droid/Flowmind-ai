import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/local_llm_service.dart';
import '../services/model_downloader.dart';
import '../services/supabase_service.dart';

class BrainDumpScreen extends StatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  State<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends State<BrainDumpScreen> {
  final _controller = TextEditingController();
  final LocalLLMService _llm = LocalLLMService();

  bool _isProcessing = false;
  bool _showResults = false;
  bool _isRecording = false;
  bool _isSaving = false;
  Map<String, dynamic>? _results;

  bool _modelLoaded = false;
  bool _downloadConfirmed = false;
  String _modelStatus = "AI Model download ho raha hai...";
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _showDownloadConfirmation();
  }

  void _showDownloadConfirmation() {
    if (_downloadConfirmed) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text("🚀 Download AI Model?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("We need to download \~398 MB model for offline & unlimited use.\n\nOnce downloaded, everything works without internet forever."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Not now"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _downloadConfirmed = true);
              _initializeLocalModel();
            },
            child: const Text("Download Now"),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeLocalModel() async {
    await _llm.initializeModel(
      onDownloadProgress: (progress) {
        if (mounted) setState(() => _downloadProgress = progress);
      },
      onStatusUpdate: (status) {
        if (mounted) {
          setState(() {
            _modelStatus = status;
            if (status.contains("ready")) _modelLoaded = true;
          });
        }
      },
    );
  }

  void _processDump() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _showResults = false;
      _results = null;
    });

    // Local LLM se process kar rahe hain
    final prompt = """
<system>
Tu FlowMind AI ka Brain Dump Analyzer hai. User jo bhi likhega usse:
1. Important Tasks nikaal
2. Priorities set kar (High/Medium/Low)
3. Action steps suggest kar
4. Suggested schedule/time slots de
5. Extra tips de productivity ke liye

Sab kuch clean bullet points mein Hindi mein de.
Format:
✅ Tasks:
• Task 1 (High)
• Task 2 (Medium)

⏰ Suggested Schedule:
• 9 AM - Task 1

💡 Action Steps:
• Step 1...
</system>

<user>
${_controller.text.trim()}
</user>
""";

    final resultText = await _llm.getResponse(prompt);

    // Simple parsing (AI se structured output expect kar rahe hain)
    final result = {
      'tasks': [], // yahan baad mein parsing kar sakte hain
      'schedule': [],
      'ai_suggestion': resultText,
    };

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _showResults = true;
        _results = result;
      });
    }
  }

  Future<void> _acceptAll() async {
    if (_results == null) return;

    setState(() => _isSaving = true);

    try {
      // Tasks save karne ka logic same rakha hai
      final tasks = _results!['tasks'] as List? ?? [];
      for (final task in tasks) {
        await SupabaseService.addTask(
          title: task['title'] ?? 'Untitled Task',
          subject: task['subject'] ?? 'General',
          time: task['time'] ?? '',
        );
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
          _showResults = false;
          _results = null;
          _controller.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${tasks.length} tasks saved successfully!',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
            backgroundColor: AppColors.mint,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.orangeRed;
      case 'medium':
        return AppColors.purple;
      case 'low':
        return AppColors.mint;
      default:
        return AppColors.mint;
    }
  }

  @override
  void dispose() {
    _llm.dispose();
    _controller.dispose();
    super.dispose();
  }
@override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: AppColors.mint.withOpacity(0.12),
                        border: Border.all(color: AppColors.mint.withOpacity(0.25)),
                      ),
                      child: const Icon(CupertinoIcons.cloud_upload, color: AppColors.mint, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Brain Dump',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textLight : AppColors.textDark,
                          ),
                        ),
                        Text(
                          'AI organizes everything instantly',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Input card
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: 8,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: isDark ? AppColors.textLight : AppColors.textDark,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What\'s on your mind?\n\nType anything — tasks, ideas, worries, plans...\nAI will organize it all for you.',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                            height: 1.7,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.07)),
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _isRecording = !_isRecording),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isRecording
                                      ? AppColors.orangeRed.withOpacity(0.15)
                                      : Colors.white.withOpacity(0.06),
                                  border: Border.all(
                                    color: _isRecording
                                        ? AppColors.orangeRed.withOpacity(0.4)
                                        : Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Icon(
                                  _isRecording ? CupertinoIcons.stop_circle : CupertinoIcons.mic,
                                  color: _isRecording ? AppColors.orangeRed : AppColors.mutedDark,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _isRecording ? 'Listening...' : '${_controller.text.length} characters',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _isProcessing ? null : _processDump,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.mint, AppColors.purple],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _isProcessing
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : Row(
                                        children: [
                                          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Process',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Processing indicator
              if (_isProcessing) ...[
                const SizedBox(height: 20),
                FadeIn(
                  child: GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: AppColors.mint, strokeWidth: 2),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'AI is organizing your thoughts...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: isDark ? AppColors.textLight : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Results
              if (_showResults && _results != null) ...[
                const SizedBox(height: 24),

                // Tasks section
                if ((_results!['tasks'] as List?)?.isNotEmpty == true) ...[
                  FadeInUp(
                    child: _SectionHeader(
                      icon: CupertinoIcons.checkmark_circle,
                      title: 'Tasks',
                      count: (_results!['tasks'] as List).length,
                      color: AppColors.mint,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...(_results!['tasks'] as List).asMap().entries.map((e) {
                    final task = e.value as Map<String, dynamic>;
                    final priority = task['priority'] ?? 'medium';
                    final color = _getPriorityColor(priority);
                    return FadeInUp(
                      delay: Duration(milliseconds: e.key * 60),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          borderRadius: 14,
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: color.withOpacity(0.15),
                                ),
                                child: Icon(CupertinoIcons.checkmark_circle, color: color, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['title'] ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textLight : AppColors.textDark,
                                      ),
                                    ),
                                    if ((task['subject'] ?? '').isNotEmpty)
                                      Text(
                                        task['subject'],
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.mutedDark),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  priority.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],

                // Schedule section
                if ((_results!['schedule'] as List?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  FadeInUp(
                    child: _SectionHeader(
                      icon: CupertinoIcons.calendar,
                      title: 'Schedule',
                      count: (_results!['schedule'] as List).length,
                      color: AppColors.purple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...(_results!['schedule'] as List).asMap().entries.map((e) {
                    final event = e.value as Map<String, dynamic>;
                    return FadeInUp(
                      delay: Duration(milliseconds: e.key * 60),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          borderRadius: 14,
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.purple.withOpacity(0.15),
                                ),
                                child: const Icon(CupertinoIcons.clock, color: AppColors.purple, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['event'] ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textLight : AppColors.textDark,
                                      ),
                                    ),
                                    if ((event['time'] ?? '').isNotEmpty)
                                      Text(
                                        event['time'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: AppColors.purple,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],

                // AI Suggestion
                if ((_results!['ai_suggestion'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  FadeInUp(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.mint.withOpacity(0.15),
                            AppColors.purple.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.mint.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.lightbulb, color: AppColors.mint, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Suggestion',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mint,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _results!['ai_suggestion'] ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: isDark ? AppColors.textLight.withOpacity(0.85) : AppColors.textDark.withOpacity(0.85),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Accept All button
                FadeInUp(
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _acceptAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.mint, AppColors.purple]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(CupertinoIcons.checkmark_circle, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Save All Tasks',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({required this.icon, required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}