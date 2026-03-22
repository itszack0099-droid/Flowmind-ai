import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/groq_service.dart';

class ExamRoomScreen extends StatefulWidget {
  const ExamRoomScreen({super.key});

  @override
  State<ExamRoomScreen> createState() => _ExamRoomScreenState();
}

class _ExamRoomScreenState extends State<ExamRoomScreen> {
  List<Map<String, dynamic>> _exams = [
    {
      'subject': 'Physics',
      'date': 'March 20, 2026',
      'daysLeft': 6,
      'progress': 0.65,
      'color': AppColors.mint,
      'icon': CupertinoIcons.book,
      'topics': ['Mechanics', 'Waves', 'Thermodynamics', 'Optics'],
      'completed': 3,
      'total': 6,
    },
    {
      'subject': 'Mathematics',
      'date': 'March 25, 2026',
      'daysLeft': 11,
      'progress': 0.40,
      'color': AppColors.purple,
      'icon': CupertinoIcons.pencil,
      'topics': ['Calculus', 'Algebra', 'Trigonometry'],
      'completed': 2,
      'total': 5,
    },
  ];

  void _showAddExamSheet() {
    final subjectController = TextEditingController();
    final dateController = TextEditingController();
    final topicsController = TextEditingController();
    int daysLeft = 7;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 24,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Exam',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 20),
              _buildModalField(subjectController, 'Subject (e.g. Physics)', CupertinoIcons.book),
              const SizedBox(height: 12),
              _buildModalField(dateController, 'Exam Date (e.g. March 20)', CupertinoIcons.calendar),
              const SizedBox(height: 12),
              _buildModalField(topicsController, 'Topics (comma separated)', CupertinoIcons.list_bullet),
              const SizedBox(height: 12),
              Text(
                'Days until exam: $daysLeft',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.mutedDark),
              ),
              Slider(
                value: daysLeft.toDouble(),
                min: 1,
                max: 90,
                divisions: 89,
                activeColor: AppColors.mint,
                inactiveColor: Colors.white.withOpacity(0.1),
                onChanged: (v) => setModalState(() => daysLeft = v.toInt()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (subjectController.text.isNotEmpty) {
                      final topics = topicsController.text.isEmpty
                          ? ['General']
                          : topicsController.text.split(',').map((t) => t.trim()).toList();

                      setState(() {
                        _exams.add({
                          'subject': subjectController.text,
                          'date': dateController.text.isEmpty ? 'TBD' : dateController.text,
                          'daysLeft': daysLeft,
                          'progress': 0.0,
                          'color': [AppColors.mint, AppColors.purple, Color(0xFF38B6FF), AppColors.orangeRed][_exams.length % 4],
                          'icon': CupertinoIcons.book,
                          'topics': topics,
                          'completed': 0,
                          'total': topics.length,
                        });
                      });
                      Navigator.pop(context);
                    }
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
                      child: Text(
                        'Add Exam',
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textLight),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.mutedDark),
          prefixIcon: Icon(icon, color: AppColors.mutedDark, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  void _showBattlePlan(Map<String, dynamic> exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BattlePlanSheet(exam: exam),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: AppColors.orangeRed.withOpacity(0.12),
                          border: Border.all(color: AppColors.orangeRed.withOpacity(0.25)),
                        ),
                        child: const Icon(CupertinoIcons.shield, color: AppColors.orangeRed, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Exam War Room', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            Text('AI-powered battle plans', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAddExamSheet,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(colors: [AppColors.mint, AppColors.purple]),
                          ),
                          child: const Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Stats
            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      _StatCard(value: '${_exams.length}', label: 'Upcoming', color: AppColors.mint, icon: CupertinoIcons.calendar),
                      const SizedBox(width: 12),
                      _StatCard(
                        value: _exams.isEmpty ? '0' : '${_exams.map((e) => e['daysLeft'] as int).reduce((a, b) => a < b ? a : b)}d',
                        label: 'Next Exam',
                        color: AppColors.orangeRed,
                        icon: CupertinoIcons.clock,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        value: _exams.isEmpty ? '0%' : '${(_exams.map((e) => e['progress'] as double).reduce((a, b) => a + b) / _exams.length * 100).toInt()}%',
                        label: 'Avg Ready',
                        color: AppColors.purple,
                        icon: CupertinoIcons.chart_bar,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Text(
                  'Your Exams',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textLight : AppColors.textDark),
                ),
              ),
            ),

            _exams.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: GlassCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(CupertinoIcons.shield, color: AppColors.mutedDark, size: 48),
                            const SizedBox(height: 16),
                            Text('No exams added yet', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textLight)),
                            const SizedBox(height: 8),
                            Text('Tap + to add your first exam', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.mutedDark)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final exam = _exams[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: 200 + (index * 100)),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                            child: GlassCard(
                              borderRadius: 20,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(13),
                                          color: (exam['color'] as Color).withOpacity(0.15),
                                        ),
                                        child: Icon(exam['icon'] as IconData, color: exam['color'] as Color, size: 22),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(exam['subject'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                            Row(
                                              children: [
                                                const Icon(CupertinoIcons.calendar, size: 11, color: AppColors.mutedDark),
                                                const SizedBox(width: 4),
                                                Text(exam['date'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.mutedDark)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: exam['daysLeft'] <= 7
                                              ? AppColors.orangeRed.withOpacity(0.15)
                                              : (exam['color'] as Color).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: exam['daysLeft'] <= 7
                                                ? AppColors.orangeRed.withOpacity(0.4)
                                                : (exam['color'] as Color).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          '${exam['daysLeft']}d left',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: exam['daysLeft'] <= 7 ? AppColors.orangeRed : exam['color'] as Color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Syllabus Progress', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.mutedDark)),
                                      Text('${exam['completed']}/${exam['total']} topics', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: exam['color'] as Color)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: exam['progress'] as double,
                                      minHeight: 7,
                                      backgroundColor: Colors.white.withOpacity(0.08),
                                      valueColor: AlwaysStoppedAnimation<Color>(exam['color'] as Color),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: (exam['topics'] as List<String>).map((t) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                                        ),
                                        child: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isDark ? AppColors.textLight.withOpacity(0.7) : AppColors.textDark.withOpacity(0.7))),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 44,
                                          child: OutlinedButton(
                                            onPressed: () => _showBattlePlan(exam),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: (exam['color'] as Color).withOpacity(0.4)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.auto_awesome_rounded, color: exam['color'] as Color, size: 16),
                                                const SizedBox(width: 6),
                                                Text('AI Battle Plan', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: exam['color'] as Color)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() => _exams.removeAt(index));
                                        },
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: AppColors.orangeRed.withOpacity(0.1),
                                            border: Border.all(color: AppColors.orangeRed.withOpacity(0.2)),
                                          ),
                                          child: const Icon(CupertinoIcons.trash, color: AppColors.orangeRed, size: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _exams.length,
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}

// Battle Plan Bottom Sheet with real AI
class _BattlePlanSheet extends StatefulWidget {
  final Map<String, dynamic> exam;
  const _BattlePlanSheet({required this.exam});

  @override
  State<_BattlePlanSheet> createState() => _BattlePlanSheetState();
}

class _BattlePlanSheetState extends State<_BattlePlanSheet> {
  bool _isLoading = true;
  String _battlePlan = '';

  @override
  void initState() {
    super.initState();
    _generatePlan();
  }

  Future<void> _generatePlan() async {
    final plan = await GroqService.generateBattlePlan(
      subject: widget.exam['subject'],
      daysLeft: widget.exam['daysLeft'],
      topics: List<String>.from(widget.exam['topics']),
    );
    if (mounted) {
      setState(() {
        _battlePlan = plan;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: (exam['color'] as Color).withOpacity(0.15),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: exam['color'] as Color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${exam['subject']} Battle Plan',
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textLight),
                    ),
                    Text(
                      '${exam['daysLeft']} days remaining',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.mutedDark),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(CupertinoIcons.xmark_circle, color: AppColors.mutedDark, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.mint),
                        const SizedBox(height: 16),
                        Text(
                          'AI is creating your battle plan...',
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.mutedDark),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.07)),
                      ),
                      child: Text(
                        _battlePlan,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.textLight,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ),
          ),
          if (!_isLoading) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _battlePlan = '';
                  });
                  _generatePlan();
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
                        const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('Regenerate Plan', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({required this.value, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? AppColors.textLight : AppColors.textDark)),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
          ],
        ),
      ),
    );
  }
}
