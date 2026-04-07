import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../services/model_downloader.dart';
import '../services/local_llm_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ModelDownloadScreen extends StatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen>
    with TickerProviderStateMixin {
  double _downloadProgress = 0.0;
  String _status = "AI Model download kar rahe hain...";
  bool _isDownloading = false;
  bool _isDownloaded = false;

  late AnimationController _robotController;
  late Animation<double> _robotAnimation;

  // Mini game variables (robot endless runner)
  double _robotY = 0.0;
  double _obstacleX = 400.0;
  double _score = 0;
  bool _gameRunning = false;
  Timer? _gameTimer;

  final LocalLLMService _llmService = LocalLLMService();

  @override
  void initState() {
    super.initState();
    _robotController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _robotAnimation = Tween<double>(begin: 0, end: 20).animate(_robotController);

    _checkModelAndShowPopup();
  }

  Future<void> _checkModelAndShowPopup() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelFile = File('${dir.path}/qwen2.5-0.5b-q4_k_m.gguf');

    if (await modelFile.exists()) {
      setState(() => _isDownloaded = true);
      Navigator.pop(context); // already downloaded hai toh wapas jaao
    } else {
      _showDownloadPopup();
    }
  }

  void _showDownloadPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "AI Model Download",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: const Text(
          "FlowMind AI ke liye 380MB ka smart model download karna hai.\n\n"
          "Pehli baar thoda time lagega, baad mein offline chalega.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startDownload();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Download Now"),
          ),
        ],
      ),
    );
  }

  Future<void> _startDownload() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied")),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      await ModelDownloader.downloadModel(
        onProgress: (progress) {
          setState(() => _downloadProgress = progress);
        },
      );

      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
        _status = "✅ Model successfully downloaded!";
      });

      // Initialize LLM after download
      await _llmService.initializeModel();

      if (mounted) {
        Navigator.pop(context); // success ke baad wapas jaao
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _status = "Download failed. Please try again.";
      });
    }
  }

  @override
  void dispose() {
    _robotController.dispose();
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy, color: Colors.blue, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    "FlowMind AI Model",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _status,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            // Progress
            if (_isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: Colors.grey[800],
                    color: Colors.blue,
                    minHeight: 12,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(_downloadProgress * 100).toStringAsFixed(0)}%",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

            const Spacer(),

            // Robot Animation + Mini Game Area
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.black12,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Robot running animation
                  AnimatedBuilder(
                    animation: _robotAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _robotAnimation.value),
                        child: const Icon(Icons.smart_toy,
                            size: 80, color: Colors.blue),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            if (!_isDownloading && !_isDownloaded)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _startDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text(
                    "Start Download (≈380 MB)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}