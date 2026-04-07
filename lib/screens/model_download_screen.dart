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
  String _status = "Checking local AI connection...";
  bool _isChecking = false;
  bool _isConnected = false;

  late AnimationController _robotController;
  final LocalLLMService _llmService = LocalLLMService();
  final TextEditingController _urlController =
      TextEditingController(text: 'http://10.0.2.2:11434');
  final TextEditingController _modelController =
      TextEditingController(text: 'qwen2.5:0.5b');

  @override
  void initState() {
    super.initState();
    _robotController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _status = "Checking local AI connection...";
    });

    final connected = await ModelDownloader.checkOllamaConnectivity(
      baseUrl: _urlController.text.trim(),
    );

    if (!mounted) return;

    if (connected) {
      await _llmService.saveSettings(
          _urlController.text.trim(), _modelController.text.trim());
      await _llmService.initializeModel();
      setState(() {
        _isConnected = true;
        _status = "✅ Local AI connected!";
        _isChecking = false;
      });
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _isConnected = false;
        _isChecking = false;
        _status =
            "Could not connect to local AI.\nMake sure Ollama is running.";
      });
    }
  }

  Future<void> _saveAndConnect() async {
    await _llmService.saveSettings(
        _urlController.text.trim(), _modelController.text.trim());
    await _checkConnection();
  }

  @override
  void dispose() {
    _robotController.dispose();
    _urlController.dispose();
    _modelController.dispose();
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
            const Icon(Icons.smart_toy, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              "FlowMind Local AI",
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              _status,
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 30),

            if (_isChecking)
              const CircularProgressIndicator(color: Colors.blue),

            if (!_isChecking && !_isConnected) ...[
              _buildSetupCard(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveAndConnect,
                icon: const Icon(Icons.wifi_find),
                label: const Text("Connect to Ollama",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Skip for now",
                    style: TextStyle(color: Colors.white54)),
              ),
            ],

            if (_isConnected)
              const Icon(Icons.check_circle, color: Colors.green, size: 60),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupCard() {
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
          Text("Setup Instructions",
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 10),
          Text(
            "1. Install Ollama on your PC/Mac\n"
            "2. Run: ollama pull qwen2.5:0.5b\n"
            "3. Start: ollama serve\n"
            "4. Connect phone to same WiFi\n"
            "5. Enter your machine's IP below",
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: Colors.white70, height: 1.6),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _urlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Ollama URL",
              labelStyle: const TextStyle(color: Colors.white54),
              hintText: "http://192.168.1.x:11434",
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: const Color(0xFF0F0F1E),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _modelController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Model name",
              labelStyle: const TextStyle(color: Colors.white54),
              hintText: "qwen2.5:0.5b",
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: const Color(0xFF0F0F1E),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
