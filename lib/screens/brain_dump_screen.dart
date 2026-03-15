import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class BrainDumpScreen extends StatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  State<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends State<BrainDumpScreen> {
  final _controller = TextEditingController();
  bool _isProcessing = false;
  bool _showResults = false;
  bool _isRecording = false;

  final List<Map<String, dynamic>> _results = [
    {
      'type': 'TASK',
      'title': 'Study Physics Chapter 3',
      'detail': 'Due tomorrow',
      'color': AppColors.mint,
      'icon': CupertinoIcons.book,
    },
    {
      'type': 'TASK',
      'title': 'Call Mom',
      'detail': 'Personal',
      'color': AppColors.purple,
      'icon': CupertinoIcons.phone,
    },
    {
      'type': 'SCHEDULE',
      'title': 'Tuition at 3:00 PM',
      'detail': 'Added to schedule',
      'color': Color(0xFF38B6FF),
      'icon': CupertinoIcons.clock,
    },
    {
      'type': 'REMINDER',
      'title': 'Submit Project',
      'detail': 'Deadline: Friday',
      'color': AppColors.orangeRed,
      'icon': CupertinoIcons.bell,
    },
  ];

  void _processDump() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _isProcessing = true;
      _showResults = false;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isProcessing = false;
      _showResults = true;
    });
  }

  @override
  void dispose() {
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
                        border: Border.all(
                          color: AppColors.mint.withOpacity(0.25),
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.cloud_upload,
                        color: AppColors.mint,
                        size: 20,
                      ),
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
                duration: const Duration(milliseconds: 500),
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
                            top: BorderSide(
                              color: Colors.white.withOpacity(0.07),
                            ),
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
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
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

              if (_showResults) ...[
                const SizedBox(height: 24),
                FadeInUp(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AI Organized This',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textLight : AppColors.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.mint.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.mint.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${_results.length} Items',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(_results.length, (index) {
                  final item = _results[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 80),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: (item['color'] as Color).withOpacity(0.15),
                              ),
                              child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textLight : AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    item['detail'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (item['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['type'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: item['color'] as Color,
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
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showResults = false;
                          _controller.clear();
                        });
                      },
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(CupertinoIcons.checkmark_circle, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Accept All & Save',
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
