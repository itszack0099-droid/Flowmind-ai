import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocalLLMService {
  bool _isInitialized = false;
  String _baseUrl = 'http://10.0.2.2:11434';
  String _model = 'qwen2.5:0.5b';

  static const String _prefKeyUrl = 'ollama_base_url';
  static const String _prefKeyModel = 'ollama_model';

  Future<void> initializeModel({
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString(_prefKeyUrl) ?? _baseUrl;
      _model = prefs.getString(_prefKeyModel) ?? _model;

      if (onStatus != null) onStatus("Connecting to local AI...");

      final reachable = await checkConnectivity();
      if (reachable) {
        _isInitialized = true;
        if (onStatus != null) onStatus("✅ Local AI connected");
      } else {
        _isInitialized = true;
        if (onStatus != null) onStatus("⚠️ Local AI not reachable — responses will be offline");
      }
    } catch (e) {
      _isInitialized = true;
      debugPrint("LocalLLM init error: $e");
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/tags'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String> getResponse(String prompt) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _model,
              'prompt': prompt,
              'stream': false,
              'options': {
                'temperature': 0.7,
                'num_predict': 512,
              },
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['response'] as String? ?? "No response from local AI.";
      } else {
        return "Local AI returned an error (${response.statusCode}). Please check your Ollama server.";
      }
    } catch (e) {
      debugPrint("LLM Response Error: $e");
      return "Local AI is not reachable. Please ensure Ollama is running at $_baseUrl with model '$_model'.";
    }
  }

  Future<void> saveSettings(String baseUrl, String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyUrl, baseUrl);
    await prefs.setString(_prefKeyModel, model);
    _baseUrl = baseUrl;
    _model = model;
    _isInitialized = false;
  }

  String get baseUrl => _baseUrl;
  String get model => _model;

  void dispose() {
    _isInitialized = false;
  }

  bool get isInitialized => _isInitialized;
}
