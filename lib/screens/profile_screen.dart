import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = true;
  bool _notifications = true;
  bool _dailyReminder = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.06),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Icon(
                        CupertinoIcons.pencil,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              FadeInUp(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 500),
                child: GlassCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.mint, AppColors.purple],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mint.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(CupertinoIcons.person_fill, color: Colors.white, size: 40),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.mint,
                                border: Border.all(
                                  color: isDark ? AppColors.bgDark : AppColors.bgLight,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nike',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textLight : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'nike@flowmind.ai',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.mint, AppColors.purple]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.star_fill, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Level 5  —  Scholar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _ProfileStat(value: '340', label: 'XP Points'),
                          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.08), margin: const EdgeInsets.symmetric(horizontal: 16)),
                          _ProfileStat(value: '7', label: 'Day Streak'),
                          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.08), margin: const EdgeInsets.symmetric(horizontal: 16)),
                          _ProfileStat(value: '23', label: 'Tasks Done'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              FadeInUp(
                delay: const Duration(milliseconds: 150),
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.mint.withOpacity(0.15), AppColors.purple.withOpacity(0.15)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.mint.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppColors.mint, AppColors.purple]),
                        ),
                        child: const Icon(CupertinoIcons.bolt_fill, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upgrade to Pro',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Unlock all features — Rs.149/month',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.mint, AppColors.purple]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Upgrade',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: GlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _ToggleSetting(icon: CupertinoIcons.moon_fill, label: 'Dark Mode', color: AppColors.purple, value: _darkMode, onChanged: (v) => setState(() => _darkMode = v)),
                      _Divider(),
                      _ToggleSetting(icon: CupertinoIcons.bell_fill, label: 'Notifications', color: AppColors.mint, value: _notifications, onChanged: (v) => setState(() => _notifications = v)),
                      _Divider(),
                      _ToggleSetting(icon: CupertinoIcons.alarm_fill, label: 'Daily Reminder', color: Color(0xFF38B6FF), value: _dailyReminder, onChanged: (v) => setState(() => _dailyReminder = v)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              FadeInUp(
                delay: const Duration(milliseconds: 250),
                duration: const Duration(milliseconds: 500),
                child: GlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _TapSetting(icon: CupertinoIcons.globe, label: 'Language', value: 'English', color: AppColors.mint, onTap: () {}),
                      _Divider(),
                      _TapSetting(icon: CupertinoIcons.lock_fill, label: 'Privacy & Security', color: AppColors.purple, onTap: () {}),
                      _Divider(),
                      _TapSetting(icon: CupertinoIcons.question_circle_fill, label: 'Help & Support', color: Color(0xFF38B6FF), onTap: () {}),
                      _Divider(),
                      _TapSetting(icon: CupertinoIcons.info_circle_fill, label: 'About FlowMind', color: AppColors.mutedDark, value: 'v1.0.0', onTap: () {}),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              FadeInUp(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
                child: GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _TapSetting(
                    icon: CupertinoIcons.square_arrow_left,
                    label: 'Logout',
                    color: AppColors.orangeRed,
                    onTap: () {},
                    isDestructive: true,
                  ),
                ),
              ),

              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? AppColors.textLight : AppColors.textDark)),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: Colors.white.withOpacity(0.06), height: 1),
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSetting({required this.icon, required this.label, required this.color, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color.withOpacity(0.12)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppColors.textLight : AppColors.textDark)),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged, activeColor: AppColors.mint),
        ],
      ),
    );
  }
}

class _TapSetting extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? value;
  final VoidCallback onTap;
  final bool isDestructive;

  const _TapSetting({required this.icon, required this.label, required this.color, required this.onTap, this.value, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color.withOpacity(0.12)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.orangeRed : (isDark ? AppColors.textLight : AppColors.textDark),
                ),
              ),
            ),
            if (value != null) ...[
              Text(value!, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
              const SizedBox(width: 6),
            ],
            if (!isDestructive)
              Icon(CupertinoIcons.chevron_right, color: isDark ? AppColors.mutedDark : AppColors.mutedLight, size: 16),
          ],
        ),
      ),
    );
  }
}
