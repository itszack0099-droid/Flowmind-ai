import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ExamRoomScreen extends StatefulWidget {
  const ExamRoomScreen({super.key});

  @override
  State<ExamRoomScreen> createState() => _ExamRoomScreenState();
}

class _ExamRoomScreenState extends State<ExamRoomScreen> {
  final List<Map<String, dynamic>> _exams = [
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
    {
      'subject': 'Chemistry',
      'date': 'April 2, 2026',
      'daysLeft': 19,
      'progress': 0.20,
      'color': Color(0xFF38B6FF),
      'icon': CupertinoIcons.drop,
      'topics': ['Organic', 'Inorganic', 'Physical'],
      'completed': 1,
      'total': 5,
    },
  ];

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
                            Text(
                              'Exam War Room',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Battle plan for every exam',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
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

            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      _StatCard(value: '3', label: 'Upcoming', color: AppColors.mint, icon: CupertinoIcons.calendar),
                      const SizedBox(width: 12),
                      _StatCard(value: '6', label: 'Days to Next', color: AppColors.orangeRed, icon: CupertinoIcons.clock),
                      const SizedBox(width: 12),
                      _StatCard(value: '42%', label: 'Avg Ready', color: AppColors.purple, icon: CupertinoIcons.chart_bar),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    'Your Exams',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final exam = _exams[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 200 + (index * 100)),
                    duration: const Duration(milliseconds: 500),
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
                                      Text(
                                        exam['subject'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textLight : AppColors.textDark,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(CupertinoIcons.calendar, size: 11, color: AppColors.mutedDark),
                                          const SizedBox(width: 4),
                                          Text(
                                            exam['date'],
                                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.mutedDark),
                                          ),
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
                                Text(
                                  'Syllabus Progress',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.mutedDark),
                                ),
                                Text(
                                  '${exam['completed']}/${exam['total']} topics',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: exam['color'] as Color,
                                  ),
                                ),
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
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (exam['topics'] as List<String>).map((t) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                                  ),
                                  child: Text(
                                    t,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textLight.withOpacity(0.7) : AppColors.textDark.withOpacity(0.7),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: (exam['color'] as Color).withOpacity(0.4)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.map, color: exam['color'] as Color, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'View Battle Plan',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: exam['color'] as Color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
