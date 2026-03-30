import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../services/groq_service.dart';
import '../services/summarizer_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _urlController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _showAttachMenu = false;
  bool _showYoutubeInput = false;

  final List<Map<String, String>> _history = [];
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'ai',
      'text':
          'Hello! I am your AI Mentor. Ask me anything, or use the attachment button to summarize YouTube videos, PDFs, audio files, and more!',
      'time': '10:00 AM',
    },
  ];

  final List<String> _suggestions = [
    'Help me study',
    'Plan my day',
    'Career advice',
    'I am feeling stuck',
  ];

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final time = TimeOfDay.now().format(context);
    setState(() {
      _messages.add({'role': 'user', 'text': text, 'time': time});
      _history.add({'role': 'user', 'content': text});
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();

    final response = await GroqService.chat(
      userMessage: text,
      history: _history.length > 10
          ? _history.sublist(_history.length - 10)
          : _history,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'ai',
          'text': response,
          'time': TimeOfDay.now().format(context),
        });
        _history.add({'role': 'assistant', 'content': response});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _history.clear();
      _messages.add({
        'role': 'ai',
        'text': 'Chat cleared. How can I help you today?',
        'time': TimeOfDay.now().format(context),
      });
    });
  }

  // ─── ATTACHMENT HANDLERS ─────────────────────────────

  void _toggleAttachMenu() {
    setState(() {
      _showAttachMenu = !_showAttachMenu;
      _showYoutubeInput = false;
    });
  }

  void _showActionPicker(String transcript, String fileName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What to do with "$fileName"?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 20),
            _ActionTile(
              icon: CupertinoIcons.doc_text,
              label: 'Summarize',
              subtitle: 'Get key points in bullet form',
              color: AppColors.mint,
              onTap: () {
                Navigator.pop(context);
                _processContent(transcript, 'summarize', fileName);
              },
            ),
            _ActionTile(
              icon: CupertinoIcons.lightbulb,
              label: 'Explain',
              subtitle: 'Simple explanation for students',
              color: AppColors.purple,
              onTap: () {
                Navigator.pop(context);
                _processContent(transcript, 'explain', fileName);
              },
            ),
            _ActionTile(
              icon: CupertinoIcons.question_circle,
              label: 'Create Quiz',
              subtitle: '5 questions with answers',
              color: Color(0xFF38B6FF),
              onTap: () {
                Navigator.pop(context);
                _processContent(transcript, 'quiz', fileName);
              },
            ),
            _ActionTile(
              icon: CupertinoIcons.list_bullet,
              label: 'Key Points',
              subtitle: 'Top 10 important points',
              color: AppColors.orangeRed,
              onTap: () {
                Navigator.pop(context);
                _processContent(transcript, 'keypoints', fileName);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processContent(
      String transcript, String action, String fileName) async {
    if (transcript.startsWith('ERROR:')) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'text': transcript,
          'time': TimeOfDay.now().format(context),
          'isError': true,
        });
      });
      return;
    }

    final actionLabel = {
      'summarize': 'Summarizing',
      'explain': 'Explaining',
      'quiz': 'Creating quiz from',
      'keypoints': 'Extracting key points from',
    }[action]!;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': '$actionLabel: $fileName',
        'time': TimeOfDay.now().format(context),
        'isFile': true,
      });
      _isTyping = true;
    });
    _scrollToBottom();

    final response = await SummarizerService.processWithAI(
      text: transcript,
      action: action,
      fileName: fileName,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'ai',
          'text': response,
          'time': TimeOfDay.now().format(context),
        });
        _history.add({'role': 'assistant', 'content': response});
      });
      _scrollToBottom();
    }
  }

  // YouTube
  void _handleYouTube() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _showYoutubeInput = false;
      _showAttachMenu = false;
      _messages.add({
        'role': 'user',
        'text': 'YouTube: $url',
        'time': TimeOfDay.now().format(context),
        'isFile': true,
      });
      _isTyping = true;
    });
    _urlController.clear();
    _scrollToBottom();

    // Show loading message
    setState(() {
      _messages.add({
        'role': 'ai',
        'text': 'Getting transcript from YouTube video...',
        'time': TimeOfDay.now().format(context),
        'isLoading': true,
      });
    });
    _scrollToBottom();

    final transcript =
        await SummarizerService.getYouTubeTranscript(url);

    // Remove loading message
    setState(() {
      _messages.removeWhere((m) => m['isLoading'] == true);
      _isTyping = false;
    });

    if (transcript.startsWith('ERROR:')) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'text':
              'Could not get transcript. Make sure the video has captions/subtitles enabled.',
          'time': TimeOfDay.now().format(context),
        });
      });
    } else {
      _showActionPicker(transcript, 'YouTube Video');
    }
  }

  // File picker
  void _handleFilePick() async {
    setState(() {
      _showAttachMenu = false;
      _showYoutubeInput = false;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'docx', 'txt', 'mp3', 'mp4', 'wav', 'm4a', 'webm'
      ],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final path = file.path;
    final name = file.name;
    final ext = name.split('.').last.toLowerCase();

    if (path == null) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': 'File uploaded: $name',
        'time': TimeOfDay.now().format(context),
        'isFile': true,
      });
      _isTyping = true;
    });

    setState(() {
      _messages.add({
        'role': 'ai',
        'text': 'Reading "$name"...',
        'time': TimeOfDay.now().format(context),
        'isLoading': true,
      });
    });
    _scrollToBottom();

    String text = '';

    if (ext == 'pdf') {
      text = await SummarizerService.extractPdfText(path);
    } else if (ext == 'docx') {
      text = await SummarizerService.extractDocxText(path);
    } else if (ext == 'txt') {
      text = await SummarizerService.readTextFile(path);
    } else if (['mp3', 'mp4', 'wav', 'm4a', 'webm'].contains(ext)) {
      setState(() {
        _messages.removeWhere((m) => m['isLoading'] == true);
      });
      setState(() {
        _messages.add({
          'role': 'ai',
          'text': 'Transcribing audio with Whisper AI...',
          'time': TimeOfDay.now().format(context),
          'isLoading': true,
        });
      });
      text = await SummarizerService.transcribeAudio(path, name);
    }

    setState(() {
      _messages.removeWhere((m) => m['isLoading'] == true);
      _isTyping = false;
    });

    if (text.startsWith('ERROR:')) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'text': 'Could not read this file. Please try a different format.',
          'time': TimeOfDay.now().format(context),
        });
      });
    } else {
      _showActionPicker(text, name);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _urlController.dispose();
    _scrollController.dispose();
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
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: Colors.white.withOpacity(0.07)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.mint, AppColors.purple],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mint.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FlowMind AI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textDark,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.mint,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _isTyping
                                    ? 'Thinking...'
                                    : 'Online — Always ready',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.mint,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearChat,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Icon(CupertinoIcons.trash,
                            color: isDark
                                ? AppColors.mutedDark
                                : AppColors.mutedLight,
                            size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.fromLTRB(20, 16, 20, 8),
                itemCount: _messages.length +
                    (_isTyping ? 1 : 0) +
                    (_messages.length == 1 ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_messages.length == 1 && index == 1) {
                    return _buildSuggestions();
                  }
                  final msgIndex =
                      _messages.length == 1 ? index - 1 : index;
                  if (_isTyping &&
                      msgIndex == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  if (msgIndex < 0 ||
                      msgIndex >= _messages.length) {
                    return const SizedBox();
                  }
                  final msg = _messages[msgIndex];
                  final isAI = msg['role'] == 'ai';
                  final isFile = msg['isFile'] == true;

                  return FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        mainAxisAlignment: isAI
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          if (isAI) ...[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [
                                  AppColors.mint,
                                  AppColors.purple
                                ]),
                              ),
                              child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                  size: 14),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: !isAI
                                    ? (isFile
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF38B6FF),
                                              AppColors.purple
                                            ],
                                          )
                                        : const LinearGradient(
                                            colors: [
                                              AppColors.mint,
                                              AppColors.purple
                                            ],
                                          ))
                                    : null,
                                color: isAI
                                    ? Colors.white.withOpacity(0.06)
                                    : null,
                                borderRadius: BorderRadius.only(
                                  topLeft:
                                      const Radius.circular(18),
                                  topRight:
                                      const Radius.circular(18),
                                  bottomLeft: Radius.circular(
                                      isAI ? 4 : 18),
                                  bottomRight: Radius.circular(
                                      isAI ? 18 : 4),
                                ),
                                border: isAI
                                    ? Border.all(
                                        color: Colors.white
                                            .withOpacity(0.08))
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  if (isFile && !isAI) ...[
                                    Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        const Icon(
                                            CupertinoIcons
                                                .paperclip,
                                            color: Colors.white,
                                            size: 14),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            msg['text']!,
                                            style: 