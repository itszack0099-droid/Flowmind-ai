import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../services/groq_service.dart';
import '../services/summarizer_service.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with TickerProviderStateMixin {

  List<Map<String, String>> _flashcards = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isFlipped = false;
  bool _isComplete = false;
  int _knownCount = 0;
  int _reviewCount = 0;
  String _fileName = '';
  String _subject = '';

  // Flip animation
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Swipe animation
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;

  final List<Color> _cardColors = [
    AppColors.mint,
    AppColors.purple,
    const Color(0xFF38B6FF),
    AppColors.orangeRed,
    const Color(0xFFFF8C42),
    const Color(0xFF00C896),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));
  }

  // ─── FILE UPLOAD ────────────────────────────────────

  Future<void> _uploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'docx'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final path = file.path;
    final name = file.name;
    final ext = name.split('.').last.toLowerCase();

    if (path == null) return;

    setState(() {
      _isLoading = true;
      _fileName = name;
      _flashcards = [];
      _currentIndex = 0;
      _isFlipped = false;
      _isComplete = false;
      _knownCount = 0;
      _reviewCount = 0;
    });

    String text = '';

    if (ext == 'pdf') {
      text = await SummarizerService.extractPdfText(path);
    } else if (ext == 'docx') {
      text = await SummarizerService.extractDocxText(path);
    } else if (ext == 'txt') {
      text = await SummarizerService.readTextFile(path);
    }

    if (text.isEmpty || text.startsWith('ERROR:')) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not read file. Try a different format.',
                style: GoogleFonts.plusJakartaSans(color: Colors.white)),
            backgroundColor: AppColors.orangeRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    await _generateFlashcards(text, name);
  }

  Future<void> _generateFlashcards(String text, String fileName) async {
    setState(() => _isLoading = true);

    final truncated = text.length > 6000
        ? text.substring(0, 6000)
        : text;

    final prompt = '''
You are a flashcard generator. Create exactly 10 flashcards from this content.

IMPORTANT: Respond ONLY with valid JSON array. No explanation, no markdown.

Format:
[
  {"front": "Question or concept", "back": "Answer or explanation", "subject": "topic name"},
  ...
]

Rules:
- Front: Short question or key concept (max 15 words)
- Back: Clear concise answer (max 30 words)  
- Cover most important concepts
- Make it useful for studying

Content from "$fileName":
$truncated
''';

    try {
      final response = await GroqService.chat(
        userMessage: prompt,
        history: [],
      );

      String cleaned = response.trim();
      if (cleaned.contains('```json')) {
        cleaned = cleaned.split('```json')[1].split('```')[0].trim();
      } else if (cleaned.contains('```')) {
        cleaned = cleaned.split('```')[1].split('```')[0].trim();
      }

      // Find JSON array
      final start = cleaned.indexOf('[');
      final end = cleaned.lastIndexOf(']');
      if (start != -1 && end != -1) {
        cleaned = cleaned.substring(start, end + 1);
      }

      final List<dynamic> parsed = List<dynamic>.from(
        _parseJsonArray(cleaned),
      );

      final cards = parsed.map((item) => {
        'front': item['front']?.toString() ?? 'Question',
        'back': item['back']?.toString() ?? 'Answer',
        'subject': item['subject']?.toString() ?? 'General',
      }).toList();

      setState(() {
        _flashcards = List<Map<String, String>>.from(cards);
        _subject = cards.isNotEmpty ? cards[0]['subject'] ?? '' : '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate flashcards. Try again.',
                style: GoogleFonts.plusJakartaSans(color: Colors.white)),
            backgroundColor: AppColors.orangeRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // Simple JSON array parser
  List<dynamic> _parseJsonArray(String json) {
    try {
      // Manual parse for simple JSON arrays
      final items = <Map<String, String>>[];
      final pattern = RegExp(
        r'\{[^}]*"front"\s*:\s*"([^"]*)"[^}]*"back"\s*:\s*"([^"]*)"[^}]*"subject"\s*:\s*"([^"]*)"[^}]*\}',
        dotAll: true,
      );
      for (final match in pattern.allMatches(json)) {
        items.add({
          'front': match.group(1) ?? '',
          'back': match.group(2) ?? '',
          'subject': match.group(3) ?? 'General',
        });
      }
      if (items.isNotEmpty) return items;

      // Try without subject
      final pattern2 = RegExp(
        r'\{[^}]*"front"\s*:\s*"([^"]*)"[^}]*"back"\s*:\s*"([^"]*)"[^}]*\}',
        dotAll: true,
      );
      for (final match in pattern2.allMatches(json)) {
        items.add({
          'front': match.group(1) ?? '',
          'back': match.group(2) ?? '',
          'subject': 'General',
        });
      }
      return items;
    } catch (e) {
      return [];
    }
  }

  // ─── CARD ACTIONS ────────────────────────────────────

  void _flipCard() {
    HapticFeedback.selectionClick();
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard({required bool known}) async {
    HapticFeedback.mediumImpact();

    if (known) {
      setState(() => _knownCount++);
    } else {
      setState(() => _reviewCount++);
    }

    // Swipe animation
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(known ? 2 : -2, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));

    await _swipeController.forward();
    _swipeController.reset();

    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _flipController.reset();
    } else {
      setState(() => _isComplete = true);
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _isFlipped = false;
      _isComplete = false;
      _knownCount = 0;
      _reviewCount = 0;
    });
    _flipController.reset();
    _swipeController.reset();
  }

  Color get _currentColor =>
      _cardColors[_currentIndex % _cardColors.length];

  @override
  void dispose() {
    _flipController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: isDark ? AppColors.textLight : AppColors.textDark,
                            size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Flashcards',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              )),
                          Text(
                            _fileName.isEmpty
                                ? 'Upload a file to start'
                                : _fileName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _uploadFile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.mint, AppColors.purple]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.cloud_upload,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text('Upload',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : _flashcards.isEmpty
                      ? _buildEmptyState(isDark)
                      : _isComplete
                          ? _buildCompleteState(isDark)
                          : _buildFlashcardView(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ─── LOADING ─────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.mint, strokeWidth: 3),
          const SizedBox(height: 20),
          Text('AI is generating flashcards...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: AppColors.mutedDark,
              )),
          const SizedBox(height: 8),
          Text('Reading your file and creating study cards',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.mutedDark,
              )),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ─────────────────────────────────────

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withOpacity(0.1),
                border: Border.all(color: AppColors.mint.withOpacity(0.3)),
              ),
              child: const Icon(CupertinoIcons.doc_text,
                  color: AppColors.mint, size: 44),
            ),
            const SizedBox(height: 24),
            Text('Upload a File',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                )),
            const SizedBox(height: 10),
            Text('Upload a PDF, DOCX, or TXT file\nAI will create 10 flashcards automatically',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, color: AppColors.mutedDark, height: 1.6,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _uploadFile,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.mint, AppColors.purple]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mint.withOpacity(0.3),
                      blurRadius: 16, spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.cloud_upload,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text('Choose File',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Supports: PDF, DOCX, TXT',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.mutedDark,
                )),
          ],
        ),
      ),
    );
  }

  // ─── FLASHCARD VIEW ──────────────────────────────────

  Widget _buildFlashcardView(bool isDark) {
    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_currentIndex + 1} / ${_flashcards.length}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                      )),
                  Row(
                    children: [
                      Icon(CupertinoIcons.checkmark_circle,
                          color: AppColors.mint, size: 14),
                      const SizedBox(width: 4),
                      Text('$_knownCount',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.mint,
                          )),
                      const SizedBox(width: 12),
                      Icon(CupertinoIcons.refresh_circled,
                          color: AppColors.orangeRed, size: 14),
                      const SizedBox(width: 4),
                      Text('$_reviewCount',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.orangeRed,
                          )),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _flashcards.length,
                  minHeight: 4,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(_currentColor),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Flashcard
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SlideTransition(
              position: _swipeAnimation,
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * pi;
                    final isShowingFront = angle < pi / 2;

                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isShowingFront
                          ? _buildCardFace(
                              isDark: isDark,
                              isFront: true,
                              text: _flashcards[_currentIndex]['front'] ?? '',
                              color: _currentColor,
                            )
                          : Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _buildCardFace(
                                isDark: isDark,
                                isFront: false,
                                text: _flashcards[_currentIndex]['back'] ?? '',
                                color: _currentColor,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Tap to flip hint
        if (!_isFlipped)
          FadeIn(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.hand_tap,
                    color: AppColors.mutedDark, size: 14),
                const SizedBox(width: 6),
                Text('Tap card to reveal answer',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppColors.mutedDark,
                    )),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Action buttons
        if (_isFlipped)
          FadeInUp(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Need Review
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _nextCard(known: false),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.orangeRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.orangeRed.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.refresh,
                                color: AppColors.orangeRed, size: 18),
                            const SizedBox(width: 8),
                            Text('Review',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14, fontWeight: FontWeight.w700,
                                  color: AppColors.orangeRed,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Known
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _nextCard(known: true),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.mint, AppColors.purple]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mint.withOpacity(0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.checkmark,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text('Got it!',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14, fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          const SizedBox(height: 56 + 20),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCardFace({
    required bool isDark,
    required bool isFront,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF0D0D1A) : Colors.white,
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background gradient
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.06),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Label
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFront
                            ? CupertinoIcons.question_circle
                            : CupertinoIcons.lightbulb,
                        color: color,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isFront ? 'QUESTION' : 'ANSWER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Main text
                Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isFront ? 20 : 17,
                    fontWeight: isFront ? FontWeight.w800 : FontWeight.w500,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (!isFront) ...[
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.08)),
                  const SizedBox(height: 12),
                  Text(
                    _flashcards[_currentIndex]['subject'] ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── COMPLETE STATE ──────────────────────────────────

  Widget _buildCompleteState(bool isDark) {
    final total = _flashcards.length;
    final percentage = (((_knownCount / total) * 100)).toInt();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [AppColors.mint, AppColors.purple]),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mint.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(CupertinoIcons.checkmark_seal_fill,
                    color: Colors.white, size: 44),
              ),
            ),

            const SizedBox(height: 24),

            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Text('Session Complete!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  )),
            ),

            const SizedBox(height: 24),

            // Stats
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: Row(
                children: [
                  _StatCard(
                    value: '$_knownCount',
                    label: 'Known',
                    color: AppColors.mint,
                    icon: CupertinoIcons.checkmark_circle_fill,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    value: '$_reviewCount',
                    label: 'Review',
                    color: AppColors.orangeRed,
                    icon: CupertinoIcons.refresh_circled_solid,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    value: '$percentage%',
                    label: 'Score',
                    color: AppColors.purple,
                    icon: CupertinoIcons.star_fill,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Restart button
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _restart,
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
                          colors: [AppColors.mint, AppColors.purple]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text('Practice Again',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _uploadFile,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.mint.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Upload New File',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.mint,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                )),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                )),
          ],
        ),
      ),
    );
  }
}
