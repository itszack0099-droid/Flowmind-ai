import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../services/groq_service.dart';

class CandleFocusScreen extends StatefulWidget {
  const CandleFocusScreen({super.key});

  @override
  State<CandleFocusScreen> createState() => _CandleFocusScreenState();
}

class _CandleFocusScreenState extends State<CandleFocusScreen>
    with TickerProviderStateMixin {

  // ─── STATE ──────────────────────────────────────────
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isFinished = false;
  bool _isAIMode = false;
  bool _isLoadingAI = false;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  String _aiMessage = '';
  String _sessionGoal = '';
  int _earnedXP = 0;

  final List<int> _manualOptions = [15, 25, 45, 60, 90];
  int _selectedMinutes = 25;

  // ─── ANIMATION CONTROLLERS ──────────────────────────
  late AnimationController _flameController;
  late AnimationController _flickerController;
  late AnimationController _smokeController;
  late AnimationController _glowController;
  late AnimationController _successController;
  late AnimationController _waxController;

  late Animation<double> _flameHeight;
  late Animation<double> _flickerX;
  late Animation<double> _flickerY;
  late Animation<double> _glowRadius;
  late Animation<double> _successScale;
  late Animation<double> _smokeOpacity;

  // Timer
  late Ticker _ticker;
  Duration _elapsed = Duration.zero;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Flame flicker
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat(reverse: true);

    _flickerX = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _flickerController, curve: Curves.easeInOut),
    );

    _flickerY = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(parent: _flickerController, curve: Curves.easeInOut),
    );

    // Flame height — shrinks as time passes
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flameHeight = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _flameController, curve: Curves.easeOut),
    );

    // Glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowRadius = Tween<double>(begin: 60, end: 100).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Smoke after extinguish
    _smokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _smokeOpacity = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _smokeController, curve: Curves.easeOut),
    );

    // Success
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _successScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _successController, curve: Curves.elasticOut));

    // Wax drip
    _waxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Ticker for countdown
    _ticker = createTicker(_onTick);
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastTick;
    _lastTick = elapsed;

    if (!_isRunning || _isPaused) return;

    final newRemaining = _remainingSeconds - 1;

    if (newRemaining <= 0) {
      _onSessionComplete();
      return;
    }

    // Update flame height based on progress
    final progress = 1.0 - (newRemaining / _totalSeconds);
    _flameController.value = progress;

    // Random flicker speed
    if (newRemaining < 60) {
      _flickerController.duration =
          Duration(milliseconds: 80 + Random().nextInt(100));
    }

    setState(() => _remainingSeconds = newRemaining);

    // Reschedule next tick after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRunning && !_isPaused && mounted) {
        _onTick(_lastTick + const Duration(seconds: 1));
      }
    });
  }

  void _startSession() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _isFinished = false;
      _remainingSeconds = _totalSeconds;
      _flameController.value = 0.0;
    });

    // Start countdown
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRunning && !_isPaused && mounted) {
        _tick();
      }
    });
  }

  void _tick() {
    if (!_isRunning || _isPaused || !mounted) return;

    final newRemaining = _remainingSeconds - 1;

    if (newRemaining <= 0) {
      _onSessionComplete();
      return;
    }

    final progress = 1.0 - (newRemaining / _totalSeconds);
    _flameController.value = progress;

    setState(() => _remainingSeconds = newRemaining);

    Future.delayed(const Duration(seconds: 1), _tick);
  }

  void _pauseSession() {
    HapticFeedback.lightImpact();
    setState(() => _isPaused = !_isPaused);
    if (!_isPaused) {
      Future.delayed(const Duration(seconds: 1), _tick);
    }
  }

  void _stopSession() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _totalSeconds;
      _flameController.value = 0.0;
    });
  }

  void _onSessionComplete() async {
    HapticFeedback.heavyImpact();

    // Blow out candle
    setState(() {
      _isRunning = false;
      _isFinished = true;
      _remainingSeconds = 0;
    });

    _smokeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _successController.forward();

    // Calculate XP
    final xpEarned = (_totalSeconds ~/ 60) * 2;
    setState(() => _earnedXP = xpEarned);

    // Save study session
    try {
      await SupabaseService.addStudySession(
        subject: _sessionGoal.isEmpty ? 'Focus Session' : _sessionGoal,
        durationMinutes: _totalSeconds ~/ 60,
      );
    } catch (e) {}
  }

  Future<void> _getAISuggestion() async {
    setState(() => _isLoadingAI = true);

    try {
      final profile = await SupabaseService.getProfile();
      final tasks = await SupabaseService.getTasks();
      final sessions = await SupabaseService.getStudySessions();

      final pendingTasks = tasks.where((t) => t['is_done'] == false).length;
      final xp = profile?['xp'] ?? 0;
      final streak = profile?['streak'] ?? 0;
      final name = profile?['name'] ?? 'Student';
      final hour = DateTime.now().hour;

      String timeOfDay;
      if (hour < 12) timeOfDay = 'morning';
      else if (hour < 17) timeOfDay = 'afternoon';
      else timeOfDay = 'evening';

      final prompt = '''
You are a smart study coach. Based on this student's data, suggest optimal focus session duration in minutes.

Student: $name
Time of day: $timeOfDay
XP: $xp
Streak: $streak days
Pending tasks: $pendingTasks
Recent sessions: ${sessions.length}

Rules:
- Morning: suggest 45-60 min (fresh mind)
- Afternoon: suggest 25-45 min
- Evening: suggest 15-25 min (tired)
- If streak is 0: suggest shorter session (15-25 min) to rebuild habit
- If many pending tasks: suggest longer session

Respond in this EXACT format only:
MINUTES: [number]
GOAL: [one short sentence about what to focus on]
MESSAGE: [one motivational sentence for $name]

Example:
MINUTES: 45
GOAL: Complete 3 pending tasks
MESSAGE: Your $streak day streak shows you have what it takes!
''';

      final response = await GroqService.chat(
        userMessage: prompt,
        history: [],
      );

      // Parse response
      int suggestedMinutes = 25;
      String goal = 'Deep focus session';
      String message = 'You got this!';

      for (final line in response.split('\n')) {
        if (line.startsWith('MINUTES:')) {
          final num = int.tryParse(line.replaceAll('MINUTES:', '').trim());
          if (num != null && num > 0 && num <= 120) suggestedMinutes = num;
        }
        if (line.startsWith('GOAL:')) {
          goal = line.replaceAll('GOAL:', '').trim();
        }
        if (line.startsWith('MESSAGE:')) {
          message = line.replaceAll('MESSAGE:', '').trim();
        }
      }

      setState(() {
        _selectedMinutes = suggestedMinutes;
        _totalSeconds = suggestedMinutes * 60;
        _remainingSeconds = suggestedMinutes * 60;
        _sessionGoal = goal;
        _aiMessage = message;
        _isLoadingAI = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAI = false;
        _aiMessage = 'Start with 25 minutes. Stay focused!';
      });
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _candleProgress =>
      _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 1.0;

  @override
  void dispose() {
    _flickerController.dispose();
    _flameController.dispose();
    _glowController.dispose();
    _smokeController.dispose();
    _successController.dispose();
    _waxController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: SafeArea(
        child: _isFinished ? _buildSuccessScreen() : _buildMainScreen(),
      ),
    );
  }

  // ─── MAIN SCREEN ────────────────────────────────────

  Widget _buildMainScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Header
          FadeInDown(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white54, size: 16),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Focus Mode',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20, fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                      Text('Candle burns while you focus',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: Colors.white38,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ─── CANDLE ─────────────────────────────────
          _buildCandle(),

          const SizedBox(height: 32),

          // Timer
          if (_isRunning)
            FadeIn(
              child: Text(
                _formatTime(_remainingSeconds),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 64, fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
            )
          else
            FadeIn(
              child: Text(
                _formatTime(_totalSeconds),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 64, fontWeight: FontWeight.w800,
                  color: Colors.white54,
                  letterSpacing: -2,
                ),
              ),
            ),

          const SizedBox(height: 8),

          if (_sessionGoal.isNotEmpty)
            Text(
              _sessionGoal,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: const Color(0xFFFF8C42),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

          if (_aiMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _aiMessage,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: Colors.white38,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 32),

          // ─── MODE TOGGLE ────────────────────────────
          if (!_isRunning) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _ModeTab(
                      label: 'Manual',
                      icon: CupertinoIcons.timer,
                      isActive: !_isAIMode,
                      onTap: () => setState(() => _isAIMode = false),
                    ),
                    _ModeTab(
                      label: 'AI Mode',
                      icon: Icons.auto_awesome_rounded,
                      isActive: _isAIMode,
                      onTap: () {
                        setState(() => _isAIMode = true);
                        _getAISuggestion();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Manual time selector
            if (!_isAIMode)
              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _manualOptions.map((min) {
                    final isSelected = _selectedMinutes == min;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedMinutes = min;
                          _totalSeconds = min * 60;
                          _remainingSeconds = min * 60;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isSelected
                              ? const Color(0xFFFF8C42).withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF8C42).withOpacity(0.6)
                                : Colors.white.withOpacity(0.08),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$min',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? const Color(0xFFFF8C42)
                                    : Colors.white54,
                              ),
                            ),
                            Text(
                              'min',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                color: isSelected
                                    ? const Color(0xFFFF8C42).withOpacity(0.7)
                                    : Colors.white30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // AI loading
            if (_isAIMode && _isLoadingAI)
              FadeIn(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            color: Color(0xFFFF8C42), strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text('AI analyzing your data...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: Colors.white54,
                          )),
                    ],
                  ),
                ),
              ),

            // AI suggestion card
            if (_isAIMode && !_isLoadingAI && _aiMessage.isNotEmpty)
              FadeInUp(
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C42).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFFF8C42).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: Color(0xFFFF8C42), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI recommends: $_selectedMinutes minutes',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: const Color(0xFFFF8C42),
                              ),
                            ),
                            if (_sessionGoal.isNotEmpty)
                              Text(_sessionGoal,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, color: Colors.white54,
                                  )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 28),
          ],

          // ─── CONTROLS ───────────────────────────────
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _isRunning
                ? Row(
                    children: [
                      Expanded(
                        child: _ControlButton(
                          icon: _isPaused
                              ? CupertinoIcons.play_fill
                              : CupertinoIcons.pause_fill,
                          label: _isPaused ? 'Resume' : 'Pause',
                          color: Colors.white,
                          onTap: _pauseSession,
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ControlButton(
                          icon: CupertinoIcons.stop_fill,
                          label: 'Give Up',
                          color: Colors.redAccent,
                          onTap: _stopSession,
                          isPrimary: false,
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: GestureDetector(
                      onTap: _startSession,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B1A), Color(0xFFFF8C42)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B1A).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(CupertinoIcons.flame_fill,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Light the Candle',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16, fontWeight: FontWeight.w800,
                                  color: Colors.white, letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── CANDLE WIDGET ──────────────────────────────────

  Widget _buildCandle() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _flickerController, _glowController, _flameController,
      ]),
      builder: (context, _) {
        final flameSize = _isRunning
            ? (1.0 - _flameController.value).clamp(0.05, 1.0)
            : (_isFinished ? 0.0 : 1.0);

        final candleHeight = 160.0;
        final waxLevel = _isRunning
            ? candleHeight * _candleProgress
            : candleHeight;

        return SizedBox(
          width: 200,
          height: 260,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [

              // Glow effect
              if (!_isFinished && (_isRunning || true))
                Positioned(
                  bottom: candleHeight * 0.6,
                  child: Container(
                    width: _glowRadius.value * 2,
                    height: _glowRadius.value * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFF8C42).withOpacity(
                              _isRunning ? 0.15 * flameSize : 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // Candle body
              Positioned(
                bottom: 0,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Base shadow
                    Container(
                      width: 64,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.black.withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),

                    // Candle body
                    Container(
                      width: 56,
                      height: candleHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFE8D5B0),
                            const Color(0xFFD4B896),
                            const Color(0xFFC4A882),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),

                    // Wax melt effect (dark top showing burn)
                    if (_isRunning)
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 56,
                          height: (candleHeight - waxLevel).clamp(0, candleHeight),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF8B6914).withOpacity(0.8),
                                const Color(0xFFB8860B).withOpacity(0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                    // Wax drip left
                    Positioned(
                      top: candleHeight * 0.1,
                      left: 8,
                      child: Container(
                        width: 6,
                        height: candleHeight * 0.15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: const Color(0xFFE8D5B0).withOpacity(0.8),
                        ),
                      ),
                    ),

                    // Wax drip right
                    Positioned(
                      top: candleHeight * 0.2,
                      right: 10,
                      child: Container(
                        width: 5,
                        height: candleHeight * 0.1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: const Color(0xFFE8D5B0).withOpacity(0.6),
                        ),
                      ),
                    ),

                    // Candle highlight
                    Positioned(
                      left: 8,
                      top: 10,
                      child: Container(
                        width: 6,
                        height: candleHeight - 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),

                    // Wick
                    Positioned(
                      top: -14,
                      child: Container(
                        width: 2,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          color: const Color(0xFF2C1A00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Flame
              if (!_isFinished)
                Positioned(
                  bottom: candleHeight + 2,
                  child: Transform.translate(
                    offset: Offset(
                      _isRunning ? _flickerX.value : 0,
                      _isRunning ? _flickerY.value : 0,
                    ),
                    child: _buildFlame(flameSize),
                  ),
                ),

              // Smoke after extinguish
              if (_isFinished)
                Positioned(
                  bottom: candleHeight + 10,
                  child: AnimatedBuilder(
                    animation: _smokeOpacity,
                    builder: (context, _) => Opacity(
                      opacity: _smokeOpacity.value,
                      child: Column(
                        children: List.generate(4, (i) {
                          return Transform.translate(
                            offset: Offset(
                              sin(i * 1.2) * 8,
                              -i * 12.0,
                            ),
                            child: Container(
                              width: 4 + i * 2.0,
                              height: 4 + i * 2.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(
                                    0.3 - i * 0.05),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlame(double size) {
    final flameH = 70.0 * size;
    final flameW = 36.0 * size;

    if (flameH < 4) return const SizedBox.shrink();

    return SizedBox(
      width: flameW,
      height: flameH,
      child: CustomPaint(
        painter: _FlamePainter(size: size),
      ),
    );
  }

  // ─── SUCCESS SCREEN ─────────────────────────────────

  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: AnimatedBuilder(
          animation: _successController,
          builder: (context, _) => Transform.scale(
            scale: _successScale.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Extinguished candle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF8C42).withOpacity(0.1),
                    border: Border.all(
                        color: const Color(0xFFFF8C42).withOpacity(0.3)),
                  ),
                  child: const Icon(CupertinoIcons.flame_fill,
                      color: Color(0xFFFF8C42), size: 36),
                ),

                const SizedBox(height: 24),

                Text(
                  'Session Complete!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${_totalSeconds ~/ 60} minutes of deep focus',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, color: Colors.white54,
                  ),
                ),

                const SizedBox(height: 32),

                // XP earned
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C42).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFFF8C42).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.star_fill,
                          color: Color(0xFFFF8C42), size: 22),
                      const SizedBox(width: 10),
                      Text(
                        '+$_earnedXP XP Earned!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF8C42),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isFinished = false;
                        _isRunning = false;
                        _remainingSeconds = _totalSeconds;
                        _flameController.value = 0.0;
                        _smokeController.reset();
                        _successController.reset();
                        _earnedXP = 0;
                      });
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
                            colors: [Color(0xFFFF6B1A), Color(0xFFFF8C42)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text('Another Session',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Back to Home',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, color: Colors.white38,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── FLAME PAINTER ──────────────────────────────────────

class _FlamePainter extends CustomPainter {
  final double size;
  _FlamePainter({required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final w = canvasSize.width;
    final h = canvasSize.height;

    // Outer flame (orange)
    final outerPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 1.0,
        colors: [
          const Color(0xFFFFCC00),
          const Color(0xFFFF8C00),
          const Color(0xFFFF4400).withOpacity(0.8),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final outerPath = Path();
    outerPath.moveTo(w / 2, 0);
    outerPath.cubicTo(w * 0.9, h * 0.3, w * 1.1, h * 0.7, w / 2, h);
    outerPath.cubicTo(-w * 0.1, h * 0.7, w * 0.1, h * 0.3, w / 2, 0);
    outerPath.close();

    canvas.drawPath(outerPath, outerPaint);

    // Inner flame (yellow/white)
    final innerPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.3),
        radius: 0.6,
        colors: [
          Colors.white.withOpacity(0.9),
          const Color(0xFFFFEE88).withOpacity(0.7),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.6, h * 0.5));

    final innerPath = Path();
    innerPath.moveTo(w / 2, h * 0.1);
    innerPath.cubicTo(w * 0.7, h * 0.35, w * 0.75, h * 0.65, w / 2, h * 0.9);
    innerPath.cubicTo(w * 0.25, h * 0.65, w * 0.3, h * 0.35, w / 2, h * 0.1);
    innerPath.close();

    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(_FlamePainter old) => old.size != size;
}

// ─── HELPER WIDGETS ─────────────────────────────────────

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label, required this.icon,
    required this.isActive, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isActive
                ? const Color(0xFFFF8C42).withOpacity(0.15)
                : Colors.transparent,
            border: Border.all(
              color: isActive
                  ? const Color(0xFFFF8C42).withOpacity(0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isActive ? const Color(0xFFFF8C42) : Colors.white38,
                  size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFFFF8C42) : Colors.white38,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ControlButton({
    required this.icon, required this.label,
    required this.color, required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: color,
                )),
          ],
        ),
      ),
    );
  }
}

double sin(double x) {
  double r = x, t = x;
  for (int i = 1; i <= 8; i++) {
    t *= -x * x / ((2 * i) * (2 * i + 1));
    r += t;
  }
  return r;
}
