import 'package:flutter/material.dart';
import 'package:llamadart/llamadart.dart';
import 'model_downloader.dart';

class LocalLLMService {
  Llama? _llama;
  String? _modelPath;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  Future<void> initializeModel({
    required Function(double) onDownloadProgress,
    required Function(String) onStatusUpdate,
  }) async {
    try {
      onStatusUpdate("AI Model download ho raha hai...");
      _modelPath = await ModelDownloader.downloadModel(onProgress: onDownloadProgress);

      if (_modelPath == null) {
        onStatusUpdate("Download failed");
        return;
      }

      onStatusUpdate("Model load ho raha hai...");

      _llama = Llama(modelPath: _modelPath!, contextSize: 4096, threads: 4);
      await _llama!.loadModel();
      _isModelLoaded = true;

      onStatusUpdate("✅ AI Model ready hai!");
    } catch (e) {
      onStatusUpdate("Error: $e");
    }
  }

  Future<String> getResponse(String userMessage) async {
    if (_llama == null || !_isModelLoaded) {
      return "AI abhi load ho raha hai...";
    }

    try {
      final response = await _llama!.chat(
        prompt: """
<system>
Tu FlowMind AI ka smart mentor hai. Productivity, study aur life management mein help kar. Hindi + English mix mein friendly jawab de.
</system>

<user>
$userMessage
</user>
""",
        maxTokens: 1024,
        temperature: 0.7,
      );
      return response.text.trim();
    } catch (e) {
      return "Kuch error aa gaya. Baad mein try karo.";
    }
  }

  void dispose() {
    _llama?.dispose();
    _llama = null;
    _isModelLoaded = false;
  }
}