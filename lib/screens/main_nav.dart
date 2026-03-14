import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const _PlaceholderScreen(
      title: 'Brain Dump',
      icon: CupertinoIcons.cloud_upload,
      subtitle: 'Speak or type anything — AI organizes it instantly.',
    ),
    const _PlaceholderScreen(
      title: 'AI Mentor',
      icon: CupertinoIcons.chat_bubble_text,
      subtitle: 'Ask anything. Get mentor-level answers.',
    ),
    const _PlaceholderScreen(
      title: 'Analytics',
      icon: CupertinoIcons.chart_bar,
      subtitle: 'Track your progress and growth over time.',
    ),
    const _PlaceholderScreen(
      title: 'Profile',
      icon: CupertinoIcons.person,
      subtitle: 'Manage your account and preferences.',
    ),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Home',
    ),
    _NavItem(
      icon: CupertinoIcons.cloud_upload,
      activeIcon: CupertinoIcons.cloud_upload_fill,
      label: 'Dump',
    ),
    _NavItem(
      icon: CupertinoIcons.chat_bubble_text,
      activeIcon: CupertinoIcons.chat_bubble_text_fill,
      label: 'Chat',
    ),
    _NavItem(
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
      label: 'Stats',
    ),
    _NavItem(
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      label: 'Me',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0D0D18).withOpacity(0.97)
              : Colors.white.withOpacity(0.97),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.07),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(
                _navItems.length,
                (index) {
                  final item = _navItems[index];
                  final isActive = index == _currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _currentIndex = index),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Active indicator dot
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isActive ? 20 : 0,
                            height: isActive ? 3 : 0,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.mint,
                                  AppColors.purple,
                                ],
                              ),
                            ),
                          ),

                          // Icon
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isActive
                                  ? AppColors.mint.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: Icon(
                              isActive ? item.activeIcon : item.icon,
                              size: 22,
                              color: isActive
                                  ? AppColors.mint
                                  : (isDark
                                      ? AppColors.mutedDark
                                      : AppColors.mutedLight),
                            ),
                          ),

                          const SizedBox(height: 2),

                          // Label
                          Text(
                            item.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isActive
                                  ? AppColors.mint
                                  : (isDark
                                      ? AppColors.mutedDark
                                      : AppColors.mutedLight),
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
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.mint.withOpacity(0.15),
                      AppColors.purple.withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.mint.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 38,
                  color: AppColors.mint,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textLight
                      : AppColors.textDark,
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.mutedDark
                        : AppColors.mutedLight,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Coming soon badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.mint.withOpacity(0.15),
                      AppColors.purple.withOpacity(0.15),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.mint.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mint,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Coming Soon',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mint,
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
  }
}
