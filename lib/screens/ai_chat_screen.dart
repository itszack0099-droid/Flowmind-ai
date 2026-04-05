import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../services/local_llm_service.dart';
import '../services/model_downloader.dart';
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
  final LocalLLMService _llm = LocalLLMService();

  bool _isTyping = false;
  bool _showAttachMenu = false;
  bool _showYoutubeInput = false;

  bool _modelLoaded = false;
  bool _downloadConfirmed = false;
  String _modelStatus = "AI Model download ho raha hai...";
  double _downloadProgress = 0.0;

  final List<Map<String, String>> _history = [];
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'ai',
      'text': 'Hello! I am your AI Mentor. Ask me anything, or use the attachment button to summarize YouTube videos, PDFs, audio files, and more!',
      'time': '10:00 AM',
    },
  ];

  final List<String> _suggestions = [
    'Help me study',
    'Plan my day',
    'Career advice',
    'I am feeling stuck',
  ];

  @override
  void initState() {
    super.initState();
    _showDownloadConfirmation();
  }

  void _showDownloadConfirmation() {
    if (_downloadConfirmed) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text("🚀 Download AI Model?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("We need to download \~398 MB model for offline & unlimited use.\n\nOnce downloaded, everything works without internet forever."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Not now"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _downloadConfirmed = true);
              _initializeLocalModel();
            },
            child: const Text("Download Now"),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeLocalModel() async {
    await _llm.initializeModel(
      onDownloadProgress: (progress) {
        if (mounted) setState(() => _downloadProgress = progress);
      },
      onStatusUpdate: (status) {
        if (mounted) {
          setState(() {
            _modelStatus = status;
            if (status.contains("ready")) _modelLoaded = true;
          });
        }
      },
    );
  }

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

    final response = await _llm.getResponse(text);

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

  void _processContent(String transcript, String action, String fileName) async {
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

    setState(() {
      _messages.add({
        'role': 'ai',
        'text': 'Getting transcript from YouTube video...',
        'time': TimeOfDay.now().format(context),
        'isLoading': true,
      });
    });
    _scrollToBottom();

    final transcript = await SummarizerService.getYouTubeTranscript(url);

    setState(() {
      _messages.removeWhere((m) => m['isLoading'] == true);
      _isTyping = false;
    });

    if (transcript.startsWith('ERROR:')) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'text': 'Could not get transcript. Make sure the video has captions/subtitles enabled.',
          'time': TimeOfDay.now().format(context),
        });
      });
    } else {
      _showActionPicker(transcript, 'YouTube Video');
    }
  }

  void _handleFilePick() async {
    setState(() {
      _showAttachMenu = false;
      _showYoutubeInput = false;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt', 'mp3', 'mp4', 'wav', 'm4a', 'webm'],
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
    _llm.dispose();
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
            // Header with model status
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.07))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [AppColors.mint, AppColors.purple]),
                        boxShadow: [BoxShadow(color: AppColors.mint.withOpacity(0.3), blurRadius: 12)],
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
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
                              color: isDark ? AppColors.textLight : AppColors.textDark,
                            ),
                          ),
                          Row(
                            children: [
                              if (!_modelLoaded && _downloadConfirmed)
                                const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                              const SizedBox(width: 6),
                              Text(
                                _modelLoaded ? "Offline — Unlimited AI" : _modelStatus,
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _modelLoaded ? AppColors.mint : Colors.orange),
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
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Icon(CupertinoIcons.trash, color: isDark ? AppColors.mutedDark : AppColors.mutedLight, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Download Progress Bar
            if (_downloadConfirmed && _downloadProgress > 0 && _downloadProgress < 1)
              LinearProgressIndicator(value: _downloadProgress, minHeight: 6),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                itemCount: _messages.length + (_isTyping ? 1 : 0) + (_messages.length == 1 ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_messages.length == 1 && index == 1) return _buildSuggestions();
                  final msgIndex = _messages.length == 1 ? index - 1 : index;
                  if (_isTyping && msgIndex == _messages.length) return _buildTypingIndicator();
                  if (msgIndex < 0 || msgIndex >= _messages.length) return const SizedBox();
                  final msg = _messages[msgIndex];
                  final isAI = msg['role'] == 'ai';
                  final isFile = msg['isFile'] == true;

                  return FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isAI) ...[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.mint, AppColors.purple])),
                              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: !isAI
                                    ? (isFile
                                        ? const LinearGradient(colors: [Color(0xFF38B6FF), AppColors.purple])
                                        : const LinearGradient(colors: [AppColors.mint, AppColors.purple]))
                                    : null,
                                color: isAI ? Colors.white.withOpacity(0.06) : null,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isAI ? 4 : 18),
                                  bottomRight: Radius.circular(isAI ? 18 : 4),
                                ),
                                border: isAI ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isFile && !isAI) ...[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(CupertinoIcons.paperclip, color: Colors.white, size: 14),
                                        const SizedBox(width: 6),
                                        Flexible(child: Text(msg['text']!, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600))),
                                      ],
                                    ),
                                  ] else ...[
                                    Text(
                                      msg['text']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: isAI ? (isDark ? AppColors.textLight : AppColors.textDark) : Colors.white,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    msg['time']!,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 10, color: isAI ? AppColors.mutedDark : Colors.white.withOpacity(0.6)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // YouTube URL input
            if (_showYoutubeInput)
              FadeInUp(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.mint.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.play_circle, color: AppColors.orangeRed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          autofocus: true,
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textLight),
                          decoration: InputDecoration(
                            hintText: 'Paste YouTube URL...',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.mutedDark),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _handleYouTube(),
                        ),
                      ),
                      GestureDetector(
                        onTap: _handleYouTube,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.mint, AppColors.purple]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Go', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Attach menu
            if (_showAttachMenu)
              FadeInUp(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _AttachOption(icon: CupertinoIcons.play_rectangle, label: 'YouTube', color: AppColors.orangeRed, onTap: () => setState(() { _showYoutubeInput = true; _showAttachMenu = false; })),
                      _AttachOption(icon: CupertinoIcons.doc_text, label: 'PDF/Doc', color: AppColors.mint, onTap: _handleFilePick),
                      _AttachOption(icon: CupertinoIcons.music_note, label: 'Audio', color: AppColors.purple, onTap: _handleFilePick),
                      _AttachOption(icon: CupertinoIcons.doc_plaintext, label: 'Text', color: Color(0xFF38B6FF), onTap: _handleFilePick),
                    ],
                  ),
                ),
              ),

            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
                color: isDark ? AppColors.bgDark : AppColors.bgLight,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleAttachMenu,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _showAttachMenu ? AppColors.mint.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                        border: Border.all(color: _showAttachMenu ? AppColors.mint.withOpacity(0.4) : Colors.white.withOpacity(0.1)),
                      ),
                      child: Icon(
                        _showAttachMenu ? CupertinoIcons.xmark : CupertinoIcons.paperclip,
                        color: _showAttachMenu ? AppColors.mint : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: isDark ? AppColors.textLight : AppColors.textDark),
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Ask anything...',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(_controller.text),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.mint, AppColors.purple])),
                      child: const Icon(CupertinoIcons.arrow_up, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 38),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _suggestions.map((s) {
          return GestureDetector(
            onTap: () => _sendMessage(s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.mint.withOpacity(0.1),
                border: Border.all(color: AppColors.mint.withOpacity(0.25)),
              ),
              child: Text(
                s,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mint),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.mint, AppColors.purple])),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: List.generate(3, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.mint.withOpacity(0.6)),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// Attach option button
class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// Action tile in bottom sheet
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textLight)),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.mutedDark)),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}