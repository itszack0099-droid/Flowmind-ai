import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';
  static const String _apiKey =
      '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';

  static Future<String> _sendRequest({
    required List<Map<String, String>> messages,
    int maxTokens = 1024,
  }) async {
    try {
      final body = jsonEncode({
        'model': _model,
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': 0.7,
        'stream': false,
      });

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        // Return actual error for debugging
        return 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }

  // ─── AI MENTOR CHAT ─────────────────────────────────

  static Future<String> chat({
    required String userMessage,
    required List<Map<String, String>> history,
  }) async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are FlowMind AI, a smart and professional AI mentor for students. Help with studies, career advice, planning, motivation, and productivity. Keep responses concise and encouraging. Never use emojis.',
      },
      ...history.take(10),
      {'role': 'user', 'content': userMessage},
    ];

    return await _sendRequest(messages: messages);
  }

  // ─── BRAIN DUMP PROCESSOR ───────────────────────────

  static Future<Map<String, dynamic>> processBrainDump(
      String dump) async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are a productivity AI. Analyze the user brain dump and extract structured data. Respond ONLY with valid JSON, no markdown, no extra text. Format: {"tasks":[{"title":"","subject":"","priority":"high/medium/low","time":""}],"schedule":[{"event":"","time":"","detail":""}],"reminders":[{"title":"","deadline":""}],"ai_suggestion":""}',
      },
      {
        'role': 'user',
        'content': 'Brain dump: $dump',
      },
    ];

    final result =
        await _sendRequest(messages: messages, maxTokens: 1024);

    try {
      String cleaned = result.trim();
      if (cleaned.contains('```json')) {
        cleaned =
            cleaned.split('```json')[1].split('```')[0].trim();
      } else if (cleaned.contains('```')) {
        cleaned =
            cleaned.split('```')[1].split('```')[0].trim();
      }
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      return {
        'tasks': [
          {
            'title': dump.length > 50
                ? '${dump.substring(0, 50)}...'
                : dump,
            'subject': 'General',
            'priority': 'medium',
            'time': '',
          }
        ],
        'schedule': [],
        'reminders': [],
        'ai_suggestion': 'Focus on your most important task first.',
      };
    }
  }

  // ─── EXAM BATTLE PLAN ───────────────────────────────

  static Future<String> generateBattlePlan({
    required String subject,
    required int daysLeft,
    required List<String> topics,
  }) async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are an expert study coach. Create clear, practical exam battle plans. Be specific and actionable. No emojis.',
      },
      {
        'role': 'user',
        'content':
            'Create a battle plan for: Subject: $subject, Days until exam: $daysLeft, Topics: ${topics.join(', ')}. Give day-by-day schedule under 300 words.',
      },
    ];

    return await _sendRequest(messages: messages, maxTokens: 512);
  }

  // ─── DAILY TIP ──────────────────────────────────────

  static Future<String> getDailyTip() async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are a study coach. Give one short practical study tip in maximum 2 sentences. No emojis.',
      },
      {
        'role': 'user',
        'content': 'Give me one practical study tip for today.',
      },
    ];

    return await _sendRequest(messages: messages, maxTokens: 100);
  }
}
