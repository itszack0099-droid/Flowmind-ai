import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/orb_background.dart';
import '../services/supabase_service.dart';
import 'main_nav.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  bool _keyboardVisible = false;
  bool _isTyping = false;
  bool _isSuccess = false;
  String? _errorMessage;
  int _resendTimer = 60;
  bool _canResend = false;

  late AnimationController _bobController;
  late AnimationController _handController;
  late AnimationController _blinkController;
  late AnimationController _successController;
  late AnimationController _shakeController;

  late Animation<double> _bobAnim;
  late Animation<double> _handAnim;
  late Animation<double> _eyeAnim;
  late Animation<double> _successAnim;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startResendTimer();
    _setupFocusListeners();
    _autoBlink();
  }

  void _initAnimations() {
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bobAnim = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );

    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _handAnim = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
    );

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _eyeAnim = Tween<double>(begin: 1.0, end: 0.05).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _successAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.25), weight: 35),
      TweenSequenceItem(tween: Tween<double>(begin: 1.25, end: 0.92), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.92, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _successController, curve: Curves.easeInOut));

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -12), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: -12, end: 12), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 12, end: -8), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: -8, end: 8), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 8, end: 0), weight: 10),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  void _setupFocusListeners() {
    for (final node in _focusNodes) {
      node.addListener(() {
        final focused = _focusNodes.any((n) => n.hasFocus);
        if (focused != _keyboardVisible) {
          setState(() => _keyboardVisible = focused);
          if (focused) {
            _blinkController.forward();
            _bobController.stop();
            _handController.stop();
          } else {
            _blinkController.reverse();
            _bobController.repeat(reverse: true);
            _handController.repeat(reverse: true);
          }
        }
      });
    }
  }

  void _autoBlink() {
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted || _keyboardVisible || _isSuccess) return;
      await _blinkController.forward();
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      await _blinkController.reverse();
      _autoBlink();
    });
  }

  void _startResendTimer() {
    setState(() { _resendTimer = 60; _canResend = false; });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendTimer--);
      if (_resendTimer <= 0) {
        setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    final filled = _controllers.where((c) => c.text.isNotEmpty).length;
    setState(() => _isTyping = filled > 0 && filled < 6);
    if (_otp.length == 6) {
      _focusNodes[5].unfocus();
      Future.delayed(const Duration(milliseconds: 300), _verifyOtp);
    }
  }

  void _verifyOtp() async {
    if (_otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit code');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final response = await SupabaseService.verifyOtpAndCreateProfile(
        email: widget.email,
        token: _otp,
      );
      if (response.session == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Verification failed. Please try again.';
        });
        for (final c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
        _shakeController.forward(from: 0);
        HapticFeedback.heavyImpact();
        return;
      }
      setState(() { _isSuccess = true; _isLoading = false; });
      _blinkController.reverse();
      _successController.forward();
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNav()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      setState(() { _isLoading = false; _errorMessage = e.message; });
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('[OtpScreen] Verification error: $e');
      setState(() { _isLoading = false; _errorMessage = 'Invalid code. Please try again.'; });
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
    }
  }

  void _resendOtp() async {
    if (!_canResend) return;
    setState(() => _isResending = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      _startResendTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Code resent!', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
          backgroundColor: AppColors.mint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to resend. Try again.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _bobController.dispose();
    _handController.dispose();
    _blinkController.dispose();
    _successController.dispose();
    _shakeController.dispose();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
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

                FadeInDown(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: isDark ? AppColors.textLight : AppColors.textDark, size: 16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Watch Character
                AnimatedBuilder(
                  animation: Listenable.merge([_bobController, _successController, _shakeController]),
                  builder: (context, _) => Transform.translate(
                    offset: Offset(
                      _isSuccess ? 0 : _shakeAnim.value,
                      _isSuccess ? 0 : _bobAnim.value,
                    ),
                    child: Transform.scale(
                      scale: _isSuccess ? _successAnim.value : 1.0,
                      child: _WatchCharacter(
                        isDark: isDark,
                        isKeyboardVisible: _keyboardVisible,
                        isTyping: _isTyping,
                        isSuccess: _isSuccess,
                        eyeAnim: _eyeAnim,
                        handAnim: _handAnim,
                        blinkController: _blinkController,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    _isSuccess ? 'Verified!' : 'Check Your Email',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _isSuccess ? AppColors.mint : (isDark ? AppColors.textLight : AppColors.textDark),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    _isSuccess ? 'Welcome to FlowMind! Taking you in...' : 'We sent a 6-digit verification code to',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                if (!_isSuccess) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mint,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // OTP Boxes
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (i) => _OtpBox(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        isDark: isDark,
                        onChanged: (val) => _onDigitChanged(i, val),
                        onBackspace: () {
                          if (i > 0 && _controllers[i].text.isEmpty) {
                            _controllers[i - 1].clear();
                            _focusNodes[i - 1].requestFocus();
                          }
                        },
                      )),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    FadeIn(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.orangeRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.orangeRed.withOpacity(0.3)),
                        ),
                        child: Text(_errorMessage!,
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.orangeRed),
                          textAlign: TextAlign.center),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFF4E1F), Color(0xFFFF7849)]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const SizedBox(width: 22, height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Text('VERIFY CODE',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15, fontWeight: FontWeight.w700,
                                      color: Colors.white, letterSpacing: 1.5)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  FadeInUp(
                    delay: const Duration(milliseconds: 350),
                    child: GestureDetector(
                      onTap: _canResend ? _resendOtp : null,
                      child: _isResending
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: AppColors.mint, strokeWidth: 2))
                          : RichText(
                              text: TextSpan(
                                text: "Didn't receive the code? ",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                                ),
                                children: [
                                  TextSpan(
                                    text: _canResend ? 'Resend now' : 'Resend in ${_resendTimer}s',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _canResend ? AppColors.mint : AppColors.mutedDark,
                                    ),
                                  ),
                                ],
                              ),
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

// Watch Character Widget
class _WatchCharacter extends StatelessWidget {
  final bool isDark;
  final bool isKeyboardVisible;
  final bool isTyping;
  final bool isSuccess;
  final Animation<double> eyeAnim;
  final Animation<double> handAnim;
  final AnimationController blinkController;

  const _WatchCharacter({
    required this.isDark,
    required this.isKeyboardVisible,
    required this.isTyping,
    required this.isSuccess,
    required this.eyeAnim,
    required this.handAnim,
    required this.blinkController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Strap top
          Positioned(
            top: 8,
            child: Container(
              width: 34, height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          // Strap bottom
          Positioned(
            bottom: 8,
            child: Container(
              width: 34, height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          // Watch face
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A0A14),
              border: Border.all(
                color: isSuccess ? AppColors.mint : AppColors.purple,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSuccess ? AppColors.mint : AppColors.purple).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Clock hands
                AnimatedBuilder(
                  animation: handAnim,
                  builder: (context, _) => CustomPaint(
                    size: const Size(132, 132),
                    painter: _HandsPainter(
                      angle: isSuccess ? 0 : (isKeyboardVisible ? 1.57 : handAnim.value),
                      isSuccess: isSuccess,
                    ),
                  ),
                ),

                // Eyes
                Positioned(
                  top: 32,
                  child: AnimatedBuilder(
                    animation: eyeAnim,
                    builder: (context, _) {
                      return Row(
                        children: [
                          _Eye(
                            scaleY: isSuccess ? 0.1 : (isKeyboardVisible ? eyeAnim.value : (1.0 - blinkController.value * 0.95)),
                            color: isSuccess ? AppColors.mint : Colors.white,
                          ),
                          const SizedBox(width: 22),
                          _Eye(
                            scaleY: isSuccess
                                ? 0.1
                                : isKeyboardVisible && isTyping
                                    ? 0.35
                                    : isKeyboardVisible
                                        ? eyeAnim.value
                                        : (1.0 - blinkController.value * 0.95),
                            color: isSuccess ? AppColors.mint : Colors.white,
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Mouth
                Positioned(
                  bottom: 24,
                  child: CustomPaint(
                    size: const Size(44, 18),
                    painter: _MouthPainter(
                      isSuccess: isSuccess,
                      isKeyboard: isKeyboardVisible,
                    ),
                  ),
                ),

                // Center dot
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSuccess ? AppColors.mint : AppColors.mint,
                  ),
                ),
              ],
            ),
          ),

          // Success sparkles
          if (isSuccess) ...[
            Positioned(top: 20, right: 20, child: _Sparkle(color: AppColors.mint, size: 12)),
            Positioned(top: 30, left: 18, child: _Sparkle(color: AppColors.purple, size: 8)),
            Positioned(bottom: 30, right: 16, child: _Sparkle(color: AppColors.mint, size: 10)),
            Positioned(bottom: 25, left: 22, child: _Sparkle(color: Colors.white, size: 7)),
          ],
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  final double scaleY;
  final Color color;
  const _Eye({required this.scaleY, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleY: scaleY.clamp(0.05, 1.0),
      child: Container(
        width: 17, height: 19,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Container(
            width: 7, height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF0A0A14),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final Color color;
  final double size;
  const _Sparkle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)],
      ),
    );
  }
}

class _HandsPainter extends CustomPainter {
  final double angle;
  final bool isSuccess;

  _HandsPainter({required this.angle, required this.isSuccess});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final minutePaint = Paint()
      ..color = isSuccess ? AppColors.mint : AppColors.mint
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final hourPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final mAngle = isSuccess ? -1.5708 : (3.14159 + angle);
    final hAngle = isSuccess ? -0.5236 : (1.5708 + angle * 0.5);

    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + 36 * _sin(mAngle), cy - 36 * _cos(mAngle)),
      minutePaint,
    );

    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + 24 * _sin(hAngle), cy - 24 * _cos(hAngle)),
      hourPaint,
    );
  }

  double _sin(double x) {
    x = x % (2 * 3.14159265358979);
    double r = x, t = x;
    for (int i = 1; i <= 8; i++) {
      t *= -x * x / ((2 * i) * (2 * i + 1));
      r += t;
    }
    return r;
  }

  double _cos(double x) {
    x = x % (2 * 3.14159265358979);
    double r = 1, t = 1;
    for (int i = 1; i <= 8; i++) {
      t *= -x * x / ((2 * i - 1) * (2 * i));
      r += t;
    }
    return r;
  }

  @override
  bool shouldRepaint(_HandsPainter old) =>
      old.angle != angle || old.isSuccess != isSuccess;
}

class _MouthPainter extends CustomPainter {
  final bool isSuccess;
  final bool isKeyboard;

  _MouthPainter({required this.isSuccess, required this.isKeyboard});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;

    if (isSuccess) {
      paint.color = AppColors.mint;
      path.moveTo(cx - 16, cy - 2);
      path.quadraticBezierTo(cx, cy + 14, cx + 16, cy - 2);
    } else if (isKeyboard) {
      path.moveTo(cx - 10, cy + 2);
      path.quadraticBezierTo(cx, cy + 5, cx + 10, cy + 2);
    } else {
      path.moveTo(cx - 13, cy);
      path.quadraticBezierTo(cx, cy + 9, cx + 13, cy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MouthPainter old) =>
      old.isSuccess != isSuccess || old.isKeyboard != isKeyboard;
}

// OTP Box Widget
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final bool isDark;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 46,
      height: 58,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.mint,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.mint, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
