import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';
import '../widgets/orb_background.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.psychology_rounded,
      gradientColors: [Color(0xFF6B21A8), Color(0xFF0A0A12)],
      title: 'Dump Your\nBrain',
      highlightWord: 'Brain',
      subtitle: 'Speak or type anything — AI automatically organizes your chaotic thoughts into clear actions.',
    ),
    _OnboardingData(
      icon: Icons.calendar_today_rounded,
      gradientColors: [Color(0xFF1E3A5F), Color(0xFF0A0A12)],
      title: 'AI Plans\nYour Day',
      highlightWord: 'Day',
      subtitle: 'AI builds your perfect daily schedule based on your energy levels and deadlines — every single day.',
    ),
    _OnboardingData(
      icon: Icons.trending_up_rounded,
      gradientColors: [Color(0xFF064E3B), Color(0xFF0A0A12)],
      title: 'Level Up\nDaily',
      highlightWord: 'Up',
      subtitle: 'Turn productivity into a game — earn XP, build streaks, and become a legend.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _OnboardingPage(data: _pages[index]);
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
              child: Column(
                children: [
                  // Dot indicator
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.mint,
                      dotColor: Colors.white.withOpacity(0.25),
                      dotHeight: 6,
                      dotWidth: 6,
                      expansionFactor: 4,
                      spacing: 6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.mint, AppColors.purple],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skip
                  if (_currentPage < _pages.length - 1)
                    GestureDetector(
                      onTap: _goToLogin,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String highlightWord;
  final String subtitle;

  _OnboardingData({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.highlightWord,
    required this.subtitle,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: data.gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Glow orb top center
        Positioned(
          top: -size.height * 0.1,
          left: size.width * 0.1,
          right: size.width * 0.1,
          child: Container(
            height: size.height * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  data.gradientColors[0].withOpacity(0.9),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),

                // Icon illustration — clean Material/Cupertino icon
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        data.icon,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Title with highlight
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 600),
                  child: _buildTitle(data.title, data.highlightWord),
                ),

                const SizedBox(height: 16),

                // Subtitle
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    data.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 160),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String title, String highlight) {
    final parts = title.split(highlight);
    return RichText(
      text: TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1.1,
          letterSpacing: -1,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: highlight,
            style: const TextStyle(color: AppColors.mint),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}
