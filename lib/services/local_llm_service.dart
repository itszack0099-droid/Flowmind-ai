import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:llamadart/llamadart.dart';

class LocalLLMService {
  Llama? _llama;
  bool _isInitialized = false;

  static const String modelFileName = 'qwen2.5-0.5b-q4_k_m.gguf';

  static Future<String> get modelPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$modelFileName';
  }

  static Future<bool> isModelDownloaded() async {
    final path = await modelPath;
    return File(path).existsSync();
  }

  Future<void> initializeModel({
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    if (_isInitialized) return;

    try {
      final path = await modelPath;
      if (!File(path).existsSync()) {
        onStatus?.call("⚠️ Model not downloaded yet.");
        return;
      }

      onStatus?.call("Loading AI model into memory...");
      _llama = Llama(path, nCtx: 512, nBatch: 512, nGpuLayers: 0);
      _isInitialized = true;
      onStatus?.call("✅ AI model loaded and ready!");
    } catch (e) {
      debugPrint("LocalLLM init error: $e");
      onStatus?.call("Failed to load model: $e");
    }
  }

  Future<String> getResponse(String prompt) async {
    if (!_isInitialized || _llama == null) {
      return "AI model not loaded. Please download and load the model from the setup screen.";
    }

    try {
      final result = _llama!.generate(prompt);
      return result.trim();
    } catch (e) {
      debugPrint("LLM Response Error: $e");
      return "AI processing failed. Please try again.";
    }
  }

  Stream<String> getResponseStream(String prompt) {
    if (!_isInitialized || _llama == null) {
      return Stream.value("AI model not loaded. Please download and load the model.");
    }
    return _llama!.generateStream(prompt);
  }

  void dispose() {
    _llama?.dispose();
    _llama = null;
    _isInitialized = false;
  }

  bool get isInitialized => _isInitialized;
}
