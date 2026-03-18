import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/orb_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: 'flowmind://reset-password',
      );

      setState(() {
        _isLoading = false;
        _isSent = true;
      });
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Back button
                FadeInDown(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textDark,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Icon
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.mint.withOpacity(0.2),
                          AppColors.purple.withOpacity(0.2),
                        ],
                      ),
                      border: Border.all(
                          color: AppColors.mint.withOpacity(0.3)),
                    ),
                    child: Icon(
                      _isSent
                          ? Icons.mark_email_read_outlined
                          : Icons.lock_reset_rounded,
                      color: AppColors.mint,
                      size: 36,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    _isSent ? 'Check Your Email' : 'Forgot Password',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    _isSent
                        ? 'We sent a password reset link to\n${_emailController.text.trim()}'
                        : 'Enter your email and we will send you\na password reset link',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.mutedDark
                          : AppColors.mutedLight,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                if (!_isSent) ...[
                  // Email input
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          GlassTextField(
                            hint: 'Email Address',
                            suffixIcon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.orangeRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.orangeRed
                                        .withOpacity(0.3)),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppColors.orangeRed),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _sendResetLink,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                                padding: EdgeInsets.zero,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.mint,
                                      AppColors.purple
                                    ],
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
                                                  strokeWidth: 2.5))
                                      : Text(
                                          'SEND RESET LINK',
                                          style: GoogleFonts
                                              .plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Success state
                  FadeInUp(
                    child: GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.mint.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      AppColors.mint.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: AppColors.mint, size: 32),
                                const SizedBox(height: 10),
                                Text(
                                  'Reset link sent successfully!',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mint,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Check your inbox and click the link to reset your password. The link will open FlowMind app directly.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.mutedDark
                                        : AppColors.mutedLight,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Resend button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _isSent = false);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color:
                                        AppColors.mint.withOpacity(0.4)),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Resend Link',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.mint,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: 'Remember your password? ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.mutedDark
                              : AppColors.mutedLight,
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
