import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/model_downloader.dart';
import '../services/local_llm_service.dart';

class ModelDownloadScreen extends StatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen> with TickerProviderStateMixin {
  double _downloadProgress = 0.0;
  String _status = "AI Model download kar rahe hain...";
  bool _isDownloading = false;
  bool _isDownloaded = false;

  late AnimationController _robotController;
  late Animation<double> _robotAnimation;

  final LocalLLMService _llmService = LocalLLMService();

  @override
  void initState() {
    super.initState();
    _robotController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _robotAnimation = Tween<double>(begin: -10, end: 10).animate(_robotController);

    _checkIfModelExists();
  }

  Future<void> _checkIfModelExists() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelFile = File('${dir.path}/qwen2.5-0.5b-q4_k_m.gguf');

    if (await modelFile.exists()) {
      setState(() => _isDownloaded = true);
      if (mounted) Navigator.pop(context);
    } else {
      _showDownloadConfirmation();
    }
  }

  void _showDownloadConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "AI Model Download",
          style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: const Text(
          "FlowMind AI ke liye \~380 MB ka smart local model download karna padega.\n\nEk baar download ho jaane ke baad app offline chalegi.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startModelDownload();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Download Now"),
          ),
        ],
      ),
    );
  }

  Future<void> _startModelDownload() async {
    await Permission.storage.request();

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _status = "Downloading AI Model...";
    });

    try {
      await ModelDownloader.downloadModel(
        onProgress: (progress) {
          if (mounted) setState(() => _downloadProgress = progress);
        },
      );

      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
        _status = "✅ Model downloaded successfully!";
      });

      await _llmService.initializeModel();

      if (mounted) Navigator.pop(context);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.smart_toy, size: 100, color: Colors.blue),
          const SizedBox(height: 30),
          Text(
            "FlowMind AI Model",
            style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 17, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 40),

          if (_isDownloading)
            Column(
              children: [
                LinearProgressIndicator(value: _downloadProgress, minHeight: 12, color: Colors.blue),
                const SizedBox(height: 12),
                Text(
                  "${(_downloadProgress * 100).toStringAsFixed(0)}%",
                  style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),

          const Spacer(),

          if (!_isDownloading)
            Padding(
              padding: const EdgeInsets.all(30),
              child: ElevatedButton(
                onPressed: _startModelDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: const Text("Start Download (\~380 MB)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}