import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/orb_background.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (_passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter a new password');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(
          () => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
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
                const SizedBox(height: 60),

                // Icon
                FadeInDown(
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
                      _isSuccess
                          ? Icons.check_circle_outline
                          : Icons.lock_outline_rounded,
                      color: AppColors.mint,
                      size: 36,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    _isSuccess ? 'Password Reset!' : 'Set New Password',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _isSuccess
                          ? AppColors.mint
                          : (isDark
                              ? AppColors.textLight
                              : AppColors.textDark),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    _isSuccess
                        ? 'Your password has been updated.\nTaking you to login...'
                        : 'Create a strong new password\nfor your FlowMind account',
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

                if (!_isSuccess) ...[
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: GlassCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          GlassTextField(
                            hint: 'New Password',
                            suffixIcon: _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            obscureText: _obscurePassword,
                            controller: _passwordController,
                            onSuffixTap: () => setState(() =>
                                _obscurePassword = !_obscurePassword),
                          ),

                          const SizedBox(height: 14),

                          GlassTextField(
                            hint: 'Confirm New Password',
                            suffixIcon: _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            obscureText: _obscureConfirm,
                            controller: _confirmController,
                            onSuffixTap: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.orangeRed.withOpacity(0.1),
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

                          const SizedBox(height: 24),

                          // Password strength hints
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.07)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password must:',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.mutedDark
                                        : AppColors.mutedLight,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _PasswordHint(
                                    text: 'Be at least 6 characters',
                                    isMet: _passwordController.text.length >= 6),
                                _PasswordHint(
                                    text: 'Passwords match',
                                    isMet: _passwordController.text ==
                                            _confirmController.text &&
                                        _confirmController.text.isNotEmpty),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _resetPassword,
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
                                      Color(0xFFFF4E1F),
                                      Color(0xFFFF7849)
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
                                          'RESET PASSWORD',
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
                  FadeInUp(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.mint.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.mint.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.mint, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Password updated successfully!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mint,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Redirecting to login...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.mutedDark
                                  : AppColors.mutedLight,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(
                              color: AppColors.mint, strokeWidth: 2),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordHint extends StatelessWidget {
  final String text;
  final bool isMet;

  const _PasswordHint({required this.text, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? AppColors.mint : AppColors.mutedDark,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isMet ? AppColors.mint : AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }
}
