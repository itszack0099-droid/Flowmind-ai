import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/groq_service.dart';
import '../services/supabase_service.dart';

// ⭐ NEW
import '../services/brain_dump_limit_service.dart';
import '../services/rewarded_ad_service.dart';

class BrainDumpScreen extends StatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  State<BrainDumpScreen> createState() =>
      _BrainDumpScreenState();
}

class _BrainDumpScreenState
    extends State<BrainDumpScreen> {
  final _controller =
      TextEditingController();

  bool _isProcessing = false;
  bool _showResults = false;
  bool _isRecording = false;
  bool _isSaving = false;

  Map<String, dynamic>? _results;

  // ⭐ NEW — main logic
  Future<void> handleProcessDump() async {
    if (_controller.text
        .trim()
        .isEmpty) return;

    bool allowed =
        await BrainDumpLimitService.canUse();

    if (allowed) {
      await BrainDumpLimitService.increment();

      _processDump();
      return;
    }

    // Show rewarded dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
              "Daily limit reached"),
          content: const Text(
            "You've used today's free Brain Dumps.\n\n"
            "Watch a short ad to continue.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                RewardedAdService.showAd(() {
                  _processDump();
                });
              },
              child:
                  const Text("Watch Ad"),
            ),
          ],
        );
      },
    );
  }

  // original processing
  void _processDump() async {
    setState(() {
      _isProcessing = true;
      _showResults = false;
      _results = null;
    });

    final result =
        await GroqService.processBrainDump(
      _controller.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _showResults = true;
        _results = result;
      });
    }
  }

  Future<void> _acceptAll() async {
    if (_results == null) return;

    setState(() => _isSaving = true);

    try {
      final tasks =
          _results!['tasks'] as List? ?? [];

      for (final task in tasks) {
        await SupabaseService.addTask(
          title:
              task['title'] ??
                  'Untitled Task',
          subject:
              task['subject'] ??
                  'General',
          time:
              task['time'] ?? '',
        );
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
          _showResults = false;
          _results = null;
          _controller.clear();
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              '${tasks.length} tasks saved successfully!',
              style: GoogleFonts
                  .plusJakartaSans(
                      color:
                          Colors.white),
            ),
            backgroundColor:
                AppColors.mint,
          ),
        );
      }
    } catch (e) {
      setState(
          () => _isSaving = false);
    }
  }

  Color _getPriorityColor(
      String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.orangeRed;
      case 'medium':
        return AppColors.purple;
      case 'low':
        return AppColors.mint;
      default:
        return AppColors.mint;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
GestureDetector(
  onTap:
      _isProcessing
          ? null
          : handleProcessDump,
  child: Container(
    padding:
        const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 12,
    ),
    decoration:
        BoxDecoration(
      gradient:
          const LinearGradient(
        colors: [
          AppColors.mint,
          AppColors.purple,
        ],
      ),
      borderRadius:
          BorderRadius.circular(12),
    ),
    child: _isProcessing
        ? const SizedBox(
            width: 18,
            height: 18,
            child:
                CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : Row(
            children: [
              const Icon(
                Icons
                    .auto_awesome_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Process',
                style: GoogleFonts
                    .plusJakartaSans(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
  ),
),

const SizedBox(height: 20),

if (_isProcessing)
  FadeIn(
    child: GlassCard(
      borderRadius: 16,
      padding:
          const EdgeInsets.all(18),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child:
                CircularProgressIndicator(
              color: AppColors.mint,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'AI is organizing your thoughts...',
            style: GoogleFonts
                .plusJakartaSans(
              fontSize: 14,
              color:
                  AppColors.textLight,
            ),
          ),
        ],
      ),
    ),
  ),

if (_showResults &&
    _results != null)
  const SizedBox(height: 24),

if (_showResults &&
    _results != null)
  SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed:
          _isSaving
              ? null
              : _acceptAll,
      style:
          ElevatedButton.styleFrom(
        backgroundColor:
            Colors.transparent,
        shadowColor:
            Colors.transparent,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
                  14),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient:
              const LinearGradient(
            colors: [
              AppColors.mint,
              AppColors.purple
            ],
          ),
          borderRadius:
              BorderRadius.circular(
                  14),
        ),
        child: Container(
          alignment:
              Alignment.center,
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      CircularProgressIndicator(
                    color:
                        Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Save All Tasks',
                  style: GoogleFonts
                      .plusJakartaSans(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w700,
                    color: Colors.white,
                  ),
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
);
}
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(
      BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            color: color,
            size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts
              .plusJakartaSans(
            fontSize: 16,
            fontWeight:
                FontWeight.w700,
            color:
                AppColors.textLight,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($count)',
          style: GoogleFonts
              .plusJakartaSans(
            fontSize: 12,
            color:
                AppColors.mutedDark,
          ),
        ),
      ],
    );
  }
}