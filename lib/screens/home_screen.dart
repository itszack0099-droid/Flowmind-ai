import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDateIndex = 3;

  final List<Map<String, dynamic>> _dates = [
    {'day': 'MON', 'date': 10},
    {'day': 'TUE', 'date': 11},
    {'day': 'WED', 'date': 12},
    {'day': 'THU', 'date': 13},
    {'day': 'FRI', 'date': 14},
    {'day': 'SAT', 'date': 15},
    {'day': 'SUN', 'date': 16},
  ];

  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Physics Chapter 3',
      'subject': 'Science',
      'time': '9:00 AM',
      'done': true,
      'color': AppColors.mint,
      'icon': CupertinoIcons.atom,
    },
    {
      'title': 'Maths Practice',
      'subject': 'Mathematics',
      'time': '11:00 AM',
      'done': false,
      'color': AppColors.purple,
      'icon': CupertinoIcons.function,
    },
    {
      'title': 'AI Chat Session',
      'subject': 'Study',
      'time': '2:00 PM',
      'done': false,
      'color': Color(0xFF38B6FF),
      'icon': CupertinoIcons.chat_bubble_text,
    },
    {
      'title': 'English Essay',
      'subject': 'Language',
      'time': '4:00 PM',
      'done': false,
      'color': AppColors.orangeRed,
      'icon': CupertinoIcons.pencil,
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

            // TOP HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.mint, AppColors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons.person_fill,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning,',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.mutedDark
                                    : AppColors.mutedLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Nike',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Notification
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.bell,
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textDark,
                              size: 20,
                            ),
                            Positioned(
                              top: 9,
                              right: 9,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.orangeRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Settings
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.settings,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textDark,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // DATE STRIP
            SliverToBoxAdapter(
              child: FadeInDown(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 500),
                child: Container(
                  margin: const EdgeInsets.only(top: 22),
                  height: 72,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _dates.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedDateIndex;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDateIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.mint,
                                      AppColors.purple
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : Colors.white.withOpacity(0.06),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _dates[index]['day'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.mutedDark
                                          : AppColors.mutedLight),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_dates[index]['date']}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.textLight
                                          : AppColors.textDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // XP BANNER
            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 150),
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Level badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.mint,
                                    AppColors.purple
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.star_fill,
                                    color: Colors.white,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Level 5  —  Scholar',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Streak
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.flame_fill,
                                  color: AppColors.orangeRed,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '7 Day Streak',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.orangeRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '340 XP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.mint,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '500 XP to Level 6',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.mutedDark
                                    : AppColors.mutedLight,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.68,
                            minHeight: 8,
                            backgroundColor:
                                Colors.white.withOpacity(0.08),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    AppColors.mint),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // QUICK ACTIONS
            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _QuickAction(
                            icon: CupertinoIcons.cloud_upload,
                            label: 'Brain\nDump',
                            color: AppColors.mint,
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: CupertinoIcons.book,
                            label: 'Study\nMode',
                            color: AppColors.purple,
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: CupertinoIcons.chat_bubble_text,
                            label: 'AI\nMentor',
                            color: const Color(0xFF38B6FF),
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: CupertinoIcons.shield,
                            label: 'Exam\nRoom',
                            color: AppColors.orangeRed,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // TODAY'S TASKS HEADER
            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 250),
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Tasks",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.mint.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.mint.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '4 Tasks',
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
              ),
            ),

            // TASK LIST
      SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = _tasks[index];
                  return FadeInUp(
                    delay:
                        Duration(milliseconds: 300 + (index * 80)),
                    duration: const Duration(milliseconds: 400),
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icon box
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(13),
                                color: (task['color'] as Color)
                                    .withOpacity(0.15),
                              ),
                              child: Icon(
                                task['icon'] as IconData,
                                color: task['color'] as Color,
                                size: 20,
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Task info
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['title'],
                                    style:
                                        GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textLight
                                          : AppColors.textDark,
                                      decoration: task['done']
                                          ? TextDecoration
                                              .lineThrough
                                          : null,
                                      decorationColor:
                                          AppColors.mutedDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.clock,
                                        size: 11,
                                        color: AppColors.mutedDark,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        task['time'],
                                        style: GoogleFonts
                                            .plusJakartaSans(
                                          fontSize: 11,
                                          color: AppColors.mutedDark,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 3,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.mutedDark,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        task['subject'],
                                        style: GoogleFonts
                                            .plusJakartaSans(
                                          fontSize: 11,
                                          color: (task['color']
                                                  as Color)
                                              .withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Checkbox
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tasks[index]['done'] =
                                      !_tasks[index]['done'];
                                });
                              },
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: task['done']
                                      ? const LinearGradient(
                                          colors: [
                                            AppColors.mint,
                                            AppColors.purple
                                          ],
                                        )
                                      : null,
                                  border: task['done']
                                      ? null
                                      : Border.all(
                                          color: Colors.white
                                              .withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                ),
                                child: task['done']
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: _tasks.length,
              ),
            ),

            // AI TIP CARD
            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 550),
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.mint.withOpacity(0.2),
                          AppColors.purple.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.mint.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.mint.withOpacity(0.15),
                          ),
                          child: const Icon(
                            CupertinoIcons.lightbulb,
                            color: AppColors.mint,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Tip of the Day',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mint,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Study in 25-minute focused blocks with 5-minute breaks. Your brain retains 40% more.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.textLight
                                          .withOpacity(0.8)
                                      : AppColors.textDark
                                          .withOpacity(0.8),
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
              ),
            ),

            // BOTTOM PADDING
            const SliverToBoxAdapter(
              child: SizedBox(height: 110),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Action Widget
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
