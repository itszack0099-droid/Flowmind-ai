import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/supabase_service.dart';
import 'brain_dump_screen.dart';
import 'ai_chat_screen.dart';
import 'exam_room_screen.dart';
import 'analytics_screen.dart';
import 'candle_focus_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDateIndex = 3;
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _tasks = [];

  final List<Map<String, dynamic>> _dates = [
    {'day': 'MON', 'date': 10},
    {'day': 'TUE', 'date': 11},
    {'day': 'WED', 'date': 12},
    {'day': 'THU', 'date': 13},
    {'day': 'FRI', 'date': 14},
    {'day': 'SAT', 'date': 15},
    {'day': 'SUN', 'date': 16},
  ];

  final List<Color> _taskColors = [
    AppColors.mint,
    AppColors.purple,
    Color(0xFF38B6FF),
    AppColors.orangeRed,
  ];

  final List<IconData> _taskIcons = [
    CupertinoIcons.book,
    CupertinoIcons.pencil,
    CupertinoIcons.chat_bubble_text,
    CupertinoIcons.star,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await SupabaseService.getProfile();
      final tasks = await SupabaseService.getTasks();
      setState(() {
        _profile = profile;
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTask(String taskId, bool isDone) async {
    await SupabaseService.toggleTask(taskId, isDone);
    await _loadData();
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    final timeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
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
              'Add New Task',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 20),
            _buildModalField(
                titleController, 'Task Title', CupertinoIcons.pencil),
            const SizedBox(height: 12),
            _buildModalField(
                subjectController, 'Subject', CupertinoIcons.book),
            const SizedBox(height: 12),
            _buildModalField(timeController, 'Time (e.g. 9:00 AM)',
                CupertinoIcons.clock),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    await SupabaseService.addTask(
                      title: titleController.text,
                      subject: subjectController.text.isEmpty
                          ? 'General'
                          : subjectController.text,
                      time: timeController.text.isEmpty
                          ? 'All Day'
                          : timeController.text,
                    );
                    Navigator.pop(context);
                    _loadData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.mint, AppColors.purple]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Add Task',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalField(
      TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 14, color: AppColors.textLight),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: AppColors.mutedDark),
          prefixIcon: Icon(icon, color: AppColors.mutedDark, size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  int _getLevelXPRequired(int level) => level * 500;

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = _profile?['name'] ?? 'User';
    final xp = _profile?['xp'] ?? 0;
    final level = _profile?['level'] ?? 1;
    final streak = _profile?['streak'] ?? 0;
    final xpRequired = _getLevelXPRequired(level);
    final xpProgress = (xp / xpRequired).clamp(0.0, 1.0);
    final levels = [
      'Beginner', 'Student', 'Scholar',
      'Expert', 'Master', 'Legend'
    ];
    final levelTitle =
        level <= levels.length ? levels[level - 1] : 'Legend';

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.mint, AppColors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(CupertinoIcons.person_fill,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.mutedDark
                                    : AppColors.mutedLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              name,
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
                      GestureDetector(
                        onTap: _loadData,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: Colors.white.withOpacity(0.06),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Icon(CupertinoIcons.refresh,
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textDark,
                              size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _navigateTo(const AnalyticsScreen()),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: Colors.white.withOpacity(0.06),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(CupertinoIcons.bell,
                                  color: isDark
                                      ? AppColors.textLight
                                      : AppColors.textDark,
                                  size: 20),
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
                                ? const LinearGradient(colors: [
                                    AppColors.mint,
                                    AppColors.purple
                                  ])
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
                                      : AppColors.mutedDark,
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(18),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: AppColors.mint, strokeWidth: 2),
                            ),
                          )
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors: [
                                            AppColors.mint,
                                            AppColors.purple
                                          ]),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(CupertinoIcons.star_fill,
                                            color: Colors.white, size: 11),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Level $level  —  $levelTitle',
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
                                  Row(
                                    children: [
                                      const Icon(CupertinoIcons.flame_fill,
                                          color: AppColors.orangeRed, size: 16),
                                      const SizedBox(width: 5),
                                      Text(
                                        '$streak Day Streak',
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
                                    '$xp XP',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppColors.mint,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                                                        '$xpRequired XP to Level ${level + 1}',
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
                                  value: xpProgress,
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
                            onTap: () =>
                                _navigateTo(const BrainDumpScreen()),
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: CupertinoIcons.flame,
                            label: 'Focus\nMode',
                            color: Color(0xFFFF8C42),
                            onTap: () =>
                                _navigateTo(const CandleFocusScreen()),
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: CupertinoIcons.chat_bubble_text,
                            label: 'AI\nMentor',
                            color: Color(0xFF38B6FF),
                            onTap: () =>
                                _navigateTo(const AiChatScreen()),
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: CupertinoIcons.shield,
                            label: 'Exam\nRoom',
                            color: AppColors.orangeRed,
                            onTap: () =>
                                _navigateTo(const ExamRoomScreen()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // TASKS HEADER
            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 250),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.mint.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.mint.withOpacity(0.3)),
                            ),
                            child: Text(
                              '${_tasks.length} Tasks',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mint,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showAddTaskDialog,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [
                                  AppColors.mint,
                                  AppColors.purple
                                ]),
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // TASK LIST
            _isLoading
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.mint)),
                    ),
                  )
                : _tasks.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: GlassCard(
                            borderRadius: 16,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(CupertinoIcons.checkmark_circle,
                                    color: AppColors.mutedDark, size: 40),
                                const SizedBox(height: 12),
                                Text('No tasks yet',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textLight
                                          : AppColors.textDark,
                                    )),
                                const SizedBox(height: 4),
                                Text('Tap + to add your first task',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AppColors.mutedDark,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = _tasks[index];
                            final color = _taskColors[
                                index % _taskColors.length];
                            final icon =
                                _taskIcons[index % _taskIcons.length];
                            final isDone = task['is_done'] as bool;

                            return FadeInUp(
                              delay: Duration(
                                  milliseconds: 300 + (index * 80)),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 10, 20, 0),
                                child: GlassCard(
                                  borderRadius: 16,
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          color: color.withOpacity(
                                              isDone ? 0.05 : 0.15),
                                        ),
                                        child: Icon(icon,
                                            color: color.withOpacity(
                                                isDone ? 0.4 : 1.0),
                                            size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task['title'],
                                              style: GoogleFonts
                                                  .plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isDone
                                                    ? AppColors.mutedDark
                                                    : (isDark
                                                        ? AppColors.textLight
                                                        : AppColors.textDark),
                                                decoration: isDone
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
                                                    color:
                                                        AppColors.mutedDark),
                                                const SizedBox(width: 4),
                                                Text(
                                                  task['time'] ?? 'All Day',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                          fontSize: 11,
                                                          color: AppColors
                                                              .mutedDark),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                    width: 3,
                                                    height: 3,
                                                    decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppColors
                                                            .mutedDark)),
                                                const SizedBox(width: 8),
                                                Text(
                                                  task['subject'] ??
                                                      'General',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 11,
                                                    color: color.withOpacity(
                                                        isDone ? 0.4 : 0.9),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            _toggleTask(task['id'], !isDone),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: isDone
                                                ? const LinearGradient(
                                                    colors: [
                                                      AppColors.mint,
                                                      AppColors.purple
                                                    ])
                                                : null,
                                            border: isDone
                                                ? null
                                                : Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    width: 1.5),
                                          ),
                                          child: isDone
                                              ? const Icon(Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 16)
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

            // AI TIP
            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 550),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GestureDetector(
                    onTap: () => _navigateTo(const AiChatScreen()),
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
                            color: AppColors.mint.withOpacity(0.2)),
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
                            child: const Icon(CupertinoIcons.lightbulb,
                                color: AppColors.mint, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            ? AppColors.textLight.withOpacity(0.8)
                                        : AppColors.textDark.withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(CupertinoIcons.chevron_right,
                              color: AppColors.mint, size: 16),
                        ],
                      ),
                    ),
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
            border: Border.all(color: color.withOpacity(0.2), width: 1),
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
