import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:llamadart/llamadart.dart';
import 'package:path_provider/path_provider.dart';

class LocalLLMService {
  LlamaEngine? _engine;
  bool _isInitialized = false;

  static const String _modelFileName = 'qwen2.5-0.5b-q4_k_m.gguf';
  static const String _systemPrompt =
      'You are FlowMind AI, a personal AI mentor for Gen Z students. '
      'Be concise, encouraging, and helpful. '
      'Keep responses under 150 words unless more detail is requested.';

  Future<void> initializeModel({
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call("Checking model file...");
      final dir = await getApplicationDocumentsDirectory();
      final modelPath = '${dir.path}/$_modelFileName';

      if (!await File(modelPath).exists()) {
        onStatus?.call("Model not found. Please download it first.");
        return;
      }

      onStatus?.call("Loading local AI model...");
      _engine = LlamaEngine(LlamaBackend());
      await _engine!.loadModel(modelPath);
      _isInitialized = true;
      onStatus?.call("AI ready (offline mode)");
    } catch (e) {
      debugPrint("LLM init error: $e");
      _engine = null;
      _isInitialized = false;
      onStatus?.call("Failed to load model. Please re-download.");
    }
  }

  Future<String> getResponse(String prompt) async {
    if (_engine == null || !_isInitialized) {
      return "AI model not loaded. Please download the model first from the home screen.";
    }

    final formatted = '<|im_start|>system\n$_systemPrompt\n<|im_end|>\n'
        '<|im_start|>user\n$prompt\n<|im_end|>\n'
        '<|im_start|>assistant\n';

    try {
      final buffer = StringBuffer();
      await for (final token in _engine!.generate(formatted)) {
        buffer.write(token);
      }
      final result = buffer.toString().trim();
      return result.isEmpty
          ? "I couldn't generate a response. Please try again."
          : result;
    } catch (e) {
      debugPrint("LLM getResponse error: $e");
      return "Sorry, something went wrong. Please try again.";
    }
  }

  void dispose() {
    _engine?.dispose().catchError((e) => debugPrint("LLM dispose error: $e"));
    _engine = null;
    _isInitialized = false;
  }

  bool get isInitialized => _isInitialized;
}
