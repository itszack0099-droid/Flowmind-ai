import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocalLLMService {
  static const String _groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqModel = 'llama3-8b-8192';
  static const String _prefKey = 'groq_api_key';

  String? _apiKey;
  bool _isInitialized = false;

  Future<void> initializeModel({
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      if (onStatus != null) onStatus("Loading AI configuration...");
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString(_prefKey) ?? '';
      _isInitialized = true;
      if (onStatus != null) onStatus("✅ AI ready");
    } catch (e) {
      debugPrint("LocalLLMService init error: $e");
      _isInitialized = true;
    }
  }

  Future<String> getResponse(String prompt) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return "🔑 AI not configured. Please add your Groq API key in Profile → Settings.";
    }

    try {
      final response = await http.post(
        Uri.parse(_groqBaseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _groqModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are FlowMind AI, a personal AI mentor for students. Be concise, encouraging, and helpful.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else if (response.statusCode == 401) {
        return "❌ Invalid API key. Please check your Groq API key in Profile → Settings.";
      } else {
        debugPrint("Groq API error: ${response.statusCode} ${response.body}");
        return "Sorry, I couldn't generate a response right now. Please try again.";
      }
    } catch (e) {
      debugPrint("LLM Response Error: $e");
      return "Sorry, I couldn't reach the AI service. Check your internet connection.";
    }
  }

  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, apiKey);
  }

  static Future<String> getStoredApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey) ?? '';
  }

  void dispose() {
    _isInitialized = false;
    _apiKey = null;
  }

  bool get isInitialized => _isInitialized;
}
