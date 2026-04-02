import 'flashcards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/banner_ad_widget.dart'; // ⭐ ADDED
import '../services/supabase_service.dart';

import 'brain_dump_screen.dart';
import 'ai_chat_screen.dart';
import 'exam_room_screen.dart';
import 'analytics_screen.dart';
import 'candle_focus_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final profile =
          await SupabaseService.getProfile();

      final tasks =
          await SupabaseService.getTasks();

      setState(() {
        _profile = profile;
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning,';
    }

    if (hour < 17) {
      return 'Good Afternoon,';
    }

    return 'Good Evening,';
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  int _getLevelXPRequired(int level) {
    return level * 500;
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final name =
        _profile?['name'] ?? 'User';

    final xp =
        _profile?['xp'] ?? 0;

    final level =
        _profile?['level'] ?? 1;

    final streak =
        _profile?['streak'] ?? 0;

    final xpRequired =
        _getLevelXPRequired(level);

    final xpProgress =
        (xp / xpRequired)
            .clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : AppColors.bgLight,

      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                        20,
                        16,
                        20,
                        0),
                child: FadeInDown(
                  child: Row(
                    children: [

                      Container(
                        width: 46,
                        height: 46,
                        decoration:
                            const BoxDecoration(
                          shape:
                              BoxShape.circle,
                          gradient:
                              LinearGradient(
                            colors: [
                              AppColors.mint,
                              AppColors.purple,
                            ],
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons
                              .person_fill,
                          color:
                              Colors.white,
                        ),
                      ),

                      const SizedBox(
                          width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            Text(
                              _getGreeting(),
                              style:
                                  GoogleFonts
                                      .plusJakartaSans(
                                fontSize:
                                    12,
                                color:
                                    AppColors
                                        .mutedDark,
                              ),
                            ),

                            Text(
                              name,
                              style:
                                  GoogleFonts
                                      .plusJakartaSans(
                                fontSize:
                                    20,
                                fontWeight:
                                    FontWeight
                                        .w800,
                                color:
                                    AppColors
                                        .textLight,
                              ),
                            ),

                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: _loadData,
                        child: const Icon(
                          CupertinoIcons
                              .refresh,
                          color:
                              Colors.white,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),

            // ⭐ BANNER AD — TOP
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.only(
                        top: 12,
                        left: 16,
                        right: 16),
                child:
                    const BannerAdWidget(),
              ),
            ),

            // DATE STRIP
            SliverToBoxAdapter(
              child: Container(
                margin:
                    const EdgeInsets.only(
                        top: 22),
                height: 72,
                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal,
                  padding:
                      const EdgeInsets
                          .symmetric(
                              horizontal:
                                  16),
                  itemCount:
                      _dates.length,
                  itemBuilder:
                      (context, index) {
                    final isSelected =
                        index ==
                            _selectedDateIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDateIndex =
                              index;
                        });
                      },
                      child:
                          Container(
                        width: 50,
                        margin:
                            const EdgeInsets
                                .symmetric(
                                    horizontal:
                                        4),
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      14),
                          gradient:
                              isSelected
                                  ? const LinearGradient(
                                      colors: [
                                          AppColors
                                              .mint,
                                          AppColors
                                              .purple
                                        ])
                                  : null,
                          color:
                              isSelected
                                  ? null
                                  : Colors
                                      .white
                                      .withOpacity(
                                          0.06),
                        ),
                        child:
                            Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [

                            Text(
                              _dates[index]
                                  ['day'],
                              style:
                                  const TextStyle(
                                fontSize:
                                    10,
                                color: Colors
                                    .white,
                              ),
                            ),

                            const SizedBox(
                                height: 4),

                            Text(
                              '${_dates[index]['date']}',
                              style:
                                  const TextStyle(
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color: Colors
                                    .white,
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
// XP CARD
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                            20,
                            20,
                            20,
                            0),
                child: GlassCard(
                  borderRadius: 20,
                  padding:
                      const EdgeInsets
                          .all(18),

                  child: Column(
                    children: [

                      Row(
                        children: [

                          Text(
                            "Level $level",
                            style:
                                GoogleFonts
                                    .plusJakartaSans(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color:
                                  Colors.white,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "$streak Day Streak",
                            style:
                                const TextStyle(
                              color:
                                  AppColors
                                      .orangeRed,
                            ),
                          ),

                        ],
                      ),

                      const SizedBox(
                          height: 16),

                      LinearProgressIndicator(
                        value:
                            xpProgress,
                        color:
                            AppColors.mint,
                        backgroundColor:
                            Colors.white
                                .withOpacity(
                                    0.1),
                      ),

                    ],
                  ),
                ),
              ),
            ),

            // QUICK ACTIONS
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets
                        .all(20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisSpacing:
                      14,
                  mainAxisSpacing:
                      14,

                  children: [

                    _buildActionCard(
                      "Brain Dump",
                      CupertinoIcons
                          .pencil,
                      () => _navigateTo(
                        const BrainDumpScreen(),
                      ),
                    ),

                    _buildActionCard(
                      "AI Chat",
                      CupertinoIcons
                          .chat_bubble,
                      () => _navigateTo(
                        const AiChatScreen(),
                      ),
                    ),

                    _buildActionCard(
                      "Exam Room",
                      CupertinoIcons
                          .book,
                      () => _navigateTo(
                        const ExamRoomScreen(),
                      ),
                    ),

                    _buildActionCard(
                      "Focus",
                      CupertinoIcons
                          .flame,
                      () => _navigateTo(
                        const CandleFocusScreen(),
                      ),
                    ),

                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      String title,
      IconData icon,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 18,
        padding:
            const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: GoogleFonts
                  .plusJakartaSans(
                fontSize: 14,
                fontWeight:
                    FontWeight.w600,
                color: Colors.white,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
