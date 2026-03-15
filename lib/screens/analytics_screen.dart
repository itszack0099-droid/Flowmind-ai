import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriod = 0;
  final List<String> _periods = ['Week', 'Month', 'Year'];

  final List<Map<String, dynamic>> _weekData = [
    {'day': 'Mon', 'hours': 3.5},
    {'day': 'Tue', 'hours': 5.0},
    {'day': 'Wed', 'hours': 2.0},
    {'day': 'Thu', 'hours': 6.5},
    {'day': 'Fri', 'hours': 4.0},
    {'day': 'Sat', 'hours': 7.0},
    {'day': 'Sun', 'hours': 1.5},
  ];

  final List<Map<String, dynamic>> _subjects = [
    {'name': 'Physics', 'hours': 12.5, 'color': AppColors.mint, 'percent': 0.35},
    {'name': 'Mathematics', 'hours': 9.0, 'color': AppColors.purple, 'percent': 0.25},
    {'name': 'Chemistry', 'hours': 7.5, 'color': Color(0xFF38B6FF), 'percent': 0.21},
    {'name': 'English', 'hours': 5.0, 'color': AppColors.orangeRed, 'percent': 0.14},
    {'name': 'Other', 'hours': 2.0, 'color': Color(0xFF6B7299), 'percent': 0.05},
  ];

  final List<Map<String, dynamic>> _achievements = [
    {'title': '7-Day Warrior', 'icon': CupertinoIcons.flame_fill, 'color': AppColors.orangeRed, 'earned': true},
    {'title': 'Speed Learner', 'icon': CupertinoIcons.bolt_fill, 'color': AppColors.mint, 'earned': true},
    {'title': 'Exam Slayer', 'icon': CupertinoIcons.shield_fill, 'color': AppColors.purple, 'earned': false},
    {'title': 'Goal Crusher', 'icon': CupertinoIcons.checkmark_seal_fill, 'color': Color(0xFF38B6FF), 'earned': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxHours = _weekData.map((d) => d['hours'] as double).reduce((a, b) => a > b ? a : b);

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analytics',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textLight : AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Your progress at a glance',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: List.generate(_periods.length, (i) {
                            final isSelected = i == _selectedPeriod;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedPeriod = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: isSelected
                                      ? const LinearGradient(colors: [AppColors.mint, AppColors.purple])
                                      : null,
                                ),
                                child: Text(
                                  _periods[i],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
                                  ),
                                ),
                              ),
                            );
                          }),
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
                      _MiniStat(value: '7', label: 'Day Streak', icon: CupertinoIcons.flame_fill, color: AppColors.orangeRed),
                      const SizedBox(width: 10),
                      _MiniStat(value: '23', label: 'Tasks Done', icon: CupertinoIcons.checkmark_circle_fill, color: AppColors.mint),
                      const SizedBox(width: 10),
                      _MiniStat(value: '4.2h', label: 'Daily Avg', icon: CupertinoIcons.clock_fill, color: AppColors.purple),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 150),
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Focus Hours',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Peak: Saturday',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.mint, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 100,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _weekData.map((d) {
                              final height = ((d['hours'] as double) / maxHours) * 100;
                              final isMax = d['hours'] == maxHours;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: height,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          gradient: isMax
                                              ? const LinearGradient(
                                                  colors: [AppColors.mint, AppColors.purple],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                )
                                              : LinearGradient(
                                                  colors: [AppColors.mint.withOpacity(0.4), AppColors.mint.withOpacity(0.6)],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        d['day'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subject Breakdown',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textLight : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._subjects.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: s['color'] as Color),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        s['name'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: isDark ? AppColors.textLight : AppColors.textDark,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${s['hours']}h',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: s['color'] as Color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: s['percent'] as double,
                                  minHeight: 5,
                                  backgroundColor: Colors.white.withOpacity(0.06),
                                  valueColor: AlwaysStoppedAnimation<Color>(s['color'] as Color),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 250),
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievements',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textLight : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: _achievements.asMap().entries.map((e) {
                          final a = e.value;
                          final isLast = e.key == _achievements.length - 1;
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: isLast ? 0 : 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: a['earned']
                                    ? (a['color'] as Color).withOpacity(0.12)
                                    : Colors.white.withOpacity(0.04),
                                border: Border.all(
                                  color: a['earned']
                                      ? (a['color'] as Color).withOpacity(0.3)
                                      : Colors.white.withOpacity(0.06),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    a['icon'] as IconData,
                                    color: a['earned'] ? a['color'] as Color : AppColors.mutedDark,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    a['title'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: a['earned']
                                          ? (isDark ? AppColors.textLight : AppColors.textDark)
                                          : AppColors.mutedDark,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MiniStat({required this.value, required this.label, required this.icon, required this.color});

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
