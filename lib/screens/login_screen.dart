import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/orb_background.dart';
import 'signup_screen.dart';
import 'main_nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNav()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: OrbBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Logo
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.transparent,
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'FlowMind',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Title
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Login',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'WELCOME BACK! PLEASE LOGIN TO YOUR ACCOUNT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.mutedDark
                          : AppColors.mutedLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Glass form card
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 700),
                  child: GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Username field
                        GlassTextField(
                          hint: 'User Name',
                          suffixIcon: Icons.person_outline_rounded,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        GlassTextField(
                          hint: 'Password',
                          suffixIcon: _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          onSuffixTap: () {
                            setState(() =>
                                _obscurePassword = !_obscurePassword);
                          },
                        ),

                        const SizedBox(height: 20),

                        // Remember me
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(
                                  () => _rememberMe = !_rememberMe),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(6),
                                  gradient: _rememberMe
                                      ? const LinearGradient(
                                          colors: [
                                            AppColors.mint,
                                            AppColors.purple,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  border: _rememberMe
                                      ? null
                                      : Border.all(
                                          color: AppColors.mutedDark,
                                          width: 1.5,
                                        ),
                                ),
                                child: _rememberMe
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Remember Me',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // LOGIN button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF4E1F),
                                    Color(0xFFFF7849),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child:
                                            CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'LOGIN',
                                        style: GoogleFonts
                                            .plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 2,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Forgot password
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // OR divider
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        child: Text(
                          'OR',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.mutedDark
                                : AppColors.mutedLight,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Google button
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: GlassCard(
                    borderRadius: 14,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                color: Color(0xFF4285F4),
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Continue with Google',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Signup link
                FadeInUp(
                  delay: const Duration(milliseconds: 450),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.mutedDark
                                : AppColors.mutedLight,
                          ),
                          children: [
                            TextSpan(
                              text: 'Signup',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.mint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
