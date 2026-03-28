import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import 'onboarding_screen.dart';
import 'main_nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    _initAnimation();

    _startNavigation();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnim =
        Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.6,
          curve: Curves.elasticOut,
        ),
      ),
    );

    _fadeAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.4,
          curve: Curves.easeIn,
        ),
      ),
    );

    _taglineFade =
        Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.5,
          1.0,
          curve: Curves.easeIn,
        ),
      ),
    );

    _controller.forward();
  }

  Future<void> _startNavigation() async {
    try {
      await Future.delayed(
        const Duration(milliseconds: 2800),
      );

      bool loggedIn = false;

      try {
        /// SAFE LOGIN CHECK
        loggedIn =
            SupabaseService.isLoggedIn;
      } catch (e) {
        debugPrint(
            "Login check error: $e");
      }

      if (!mounted) return;

      if (loggedIn) {
        _goToMain();
      } else {
        _goToOnboarding();
      }
    } catch (e) {
      debugPrint(
          "Splash navigation error: $e");

      /// FAILSAFE NAVIGATION
      if (mounted) {
        _goToOnboarding();
      }
    }
  }

  void _goToMain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) =>
                const MainNav(),
        transitionsBuilder:
            (_, anim, __, child) =>
                FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration:
            const Duration(milliseconds: 600),
      ),
    );
  }

  void _goToOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) =>
                const OnboardingScreen(),
        transitionsBuilder:
            (_, anim, __, child) =>
                FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration:
            const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF07090F),
                  Color(0xFF0D0A1E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// CENTER CONTENT
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [

                    FadeTransition(
                      opacity: _fadeAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration:
                              BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                                    32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors
                                    .mint
                                    .withOpacity(
                                        0.25),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                                    32),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit:
                                  BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 28),

                    FadeTransition(
                      opacity: _fadeAnim,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'flowmind ',
                              style:
                                  GoogleFonts
                                      .plusJakartaSans(
                                fontSize: 34,
                                fontWeight:
                                    FontWeight
                                        .w800,
                                color:
                                    Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'ai',
                              style:
                                  GoogleFonts
                                      .plusJakartaSans(
                                fontSize: 34,
                                fontWeight:
                                    FontWeight
                                        .w800,
                                color:
                                    AppColors.mint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 60),

                    FadeTransition(
                      opacity:
                          _taglineFade,
                      child:
                          const _LoadingDots(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() =>
      _LoadingDotsState();
}

class _LoadingDotsState
    extends State<_LoadingDots>
    with TickerProviderStateMixin {

  late List<AnimationController>
      _dotControllers;

  late List<Animation<double>>
      _dotAnims;

  @override
  void initState() {
    super.initState();

    _dotControllers =
        List.generate(
      3,
      (i) =>
          AnimationController(
        vsync: this,
        duration:
            const Duration(
                milliseconds: 600),
      ),
    );

    _dotAnims =
        _dotControllers.map((c) {
      return Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: c,
          curve:
              Curves.easeInOut,
        ),
      );
    }).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(
        Duration(
            milliseconds:
                i * 200),
        () {
          if (mounted) {
            _dotControllers[i]
                .repeat(
                    reverse:
                        true);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    for (final c
        in _dotControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children:
          List.generate(3, (i) {
        return AnimatedBuilder(
          animation:
              _dotAnims[i],
          builder:
              (context, _) =>
                  Container(
            margin:
                const EdgeInsets
                    .symmetric(
                        horizontal:
                            4),
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,
              color: AppColors
                  .mint
                  .withOpacity(
                      _dotAnims[i]
                          .value),
            ),
          ),
        );
      }),
    );
  }
}