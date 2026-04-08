import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/model_downloader.dart';
import '../services/local_llm_service.dart';

class ModelDownloadScreen extends StatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen>
    with TickerProviderStateMixin {
  String _status = "Checking for downloaded model...";
  bool _isDownloading = false;
  bool _isLoading = false;
  bool _isReady = false;
  bool _modelExists = false;
  double _downloadProgress = 0.0;

  late AnimationController _robotController;
  final LocalLLMService _llmService = LocalLLMService();

  @override
  void initState() {
    super.initState();
    _robotController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _checkModelExists();
  }

  Future<void> _checkModelExists() async {
    final exists = await ModelDownloader.isModelDownloaded();
    if (!mounted) return;
    setState(() {
      _modelExists = exists;
      _status = exists
          ? "Model found! Tap 'Load Model' to start AI."
          : "Qwen2.5-0.5B model not found.\nDownload once (~400 MB) for fully offline AI.";
    });
  }

  Future<void> _downloadModel() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _status = "Starting download...";
    });

    final path = await ModelDownloader.downloadModel(
      onProgress: (progress) {
        if (mounted) setState(() => _downloadProgress = progress);
      },
      onStatus: (status) {
        if (mounted) setState(() => _status = status);
      },
    );

    if (!mounted) return;

    if (path != null) {
      setState(() {
        _isDownloading = false;
        _modelExists = true;
        _status = "✅ Download complete! Tap 'Load Model' to start.";
      });
    } else {
      setState(() {
        _isDownloading = false;
        _status = "Download failed. Check your internet and try again.";
      });
    }
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
      _status = "Loading model into memory...";
    });

    await _llmService.initializeModel(
      onStatus: (s) {
        if (mounted) setState(() => _status = s);
      },
    );

    if (!mounted) return;

    if (_llmService.isInitialized) {
      setState(() {
        _isReady = true;
        _isLoading = false;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
        _status = "Failed to load model. Try re-downloading.";
      });
    }
  }

  @override
  void dispose() {
    _robotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 60),
            AnimatedBuilder(
              animation: _robotController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _robotController.value * 8 - 4),
                child: const Icon(Icons.memory, size: 100, color: Colors.deepPurpleAccent),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "FlowMind Local AI",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Qwen2.5-0.5B · Fully Offline · On-Device",
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.deepPurpleAccent),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 15, color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 30),

            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Text(
                "${(_downloadProgress * 100).toStringAsFixed(1)}%",
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white54),
              ),
            ],

            if (_isLoading)
              const CircularProgressIndicator(color: Colors.deepPurpleAccent),

            if (_isReady)
              const Icon(Icons.check_circle, color: Colors.green, size: 60),

            if (!_isDownloading && !_isLoading && !_isReady) ...[
              const SizedBox(height: 10),

              if (!_modelExists) ...[
                _buildInfoCard(),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _downloadModel,
                  icon: const Icon(Icons.download),
                  label: const Text(
                    "Download Model (~400 MB)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],

              if (_modelExists) ...[
                ElevatedButton.icon(
                  onPressed: _loadModel,
                  icon: const Icon(Icons.bolt),
                  label: const Text(
                    "Load Model & Start AI",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _downloadModel,
                  icon: const Icon(Icons.refresh, color: Colors.white38, size: 16),
                  label: const Text("Re-download model", style: TextStyle(color: Colors.white38, fontSize: 13)),
                ),
              ],

              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Skip for now", style: TextStyle(color: Colors.white38)),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Fully Offline AI",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "• Download once (~400 MB Wi-Fi recommended)\n"
            "• Model: Qwen2.5-0.5B Q4_K_M GGUF\n"
            "• Stored privately on your device\n"
            "• Works 100% offline after download\n"
            "• No data sent to any server",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white70,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
