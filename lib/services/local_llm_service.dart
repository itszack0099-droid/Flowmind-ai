import 'dart:io';
import 'package:flutter/material.dart';
import 'package:llamadart/llamadart.dart';
import 'model_downloader.dart';

class LocalLLMService {
  Llama? _llama;
  bool _isInitialized = false;

  static const bool _devModeSkipDownload = false; // testing ke liye true kar sakte ho

  Future<void> initializeModel({
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    if (_isInitialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final modelPath = '${dir.path}/qwen2.5-0.5b-q4_k_m.gguf';
      final modelFile = File(modelPath);

      // Model download
      if (!await modelFile.exists() && !_devModeSkipDownload) {
        if (onStatus != null) onStatus("Downloading AI Model...");
        await ModelDownloader.downloadModel(onProgress: onProgress ?? (p) {});
      }

      if (onStatus != null) onStatus("Loading model into memory...");

      _llama = Llama();
      await _llama!.loadModel(
        modelPath: modelPath,
        contextSize: 4096,
        threads: 4,
      );

      _isInitialized = true;
      if (onStatus != null) onStatus("✅ Model loaded successfully");
    } catch (e) {
      debugPrint("LLM Initialization Error: $e");
      rethrow;
    }
  }

  Future<String> getResponse(String prompt) async {
    if (_llama == null) {
      throw Exception("Model not initialized. Call initializeModel() first.");
    }

    try {
      final response = await _llama!.getResponse(
        prompt: prompt,
        temperature: 0.7,
        maxTokens: 1024,
      );
      return response;
    } catch (e) {
      debugPrint("LLM Response Error: $e");
      return "Sorry, I couldn't generate a response right now. Please try again.";
    }
  }

  void dispose() {
    _llama?.dispose();
    _llama = null;
    _isInitialized = false;
  }

  bool get isInitialized => _isInitialized;
}