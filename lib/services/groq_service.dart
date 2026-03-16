import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama3-8b-8192';

  static const String _apiKey = String.fromEnvironment(
    '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',
    defaultValue: '',
  );

  // ─── CORE REQUEST ───────────────────────────────────

  static Future<String> _sendRequest({
    required String systemPrompt,
    required String userMessage,
    int maxTokens = 1024,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': maxTokens,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return 'Sorry, I could not process your request. Please try again.';
      }
    } catch (e) {
      return 'Connection error. Please check your internet and try again.';
    }
  }

  // ─── AI MENTOR CHAT ─────────────────────────────────

  static Future<String> chat({
    required String userMessage,
    required List<Map<String, String>> history,
  }) async {
    try {
      final messages = <Map<String, String>>[
        {
          'role': 'system',
          'content': '''You are FlowMind AI, a smart and professional AI mentor for students. 
You help with:
- Study planning and exam preparation
- Career guidance and advice
- Motivation and overcoming procrastination
- Subject-specific questions (Math, Science, English, etc.)
- Life skills and productivity

Keep responses concise, clear, and encouraging. 
Use a professional but friendly tone.
Format answers with clear structure when needed.
Never use emojis in responses.''',
        },
        ...history.map((m) => {'role': m['role']!, 'content': m['content']!}),
        {'role': 'user', 'content': userMessage},
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return 'Sorry, I could not respond right now. Please try again.';
      }
    } catch (e) {
      return 'Connection error. Please check your internet.';
    }
  }

  // ─── BRAIN DUMP PROCESSOR ───────────────────────────

  static Future<Map<String, dynamic>> processBrainDump(String dump) async {
    const systemPrompt = '''You are a productivity AI. 
Analyze the user's brain dump text and extract structured information.

IMPORTANT: Respond ONLY with valid JSON. No explanation, no markdown, no extra text.

JSON format:
{
  "tasks": [
    {"title": "task name", "subject": "subject/category", "priority": "high/medium/low", "time": "time if mentioned or empty"}
  ],
  "schedule": [
    {"event": "event name", "time": "time", "detail": "detail"}
  ],
  "reminders": [
    {"title": "reminder", "deadline": "deadline if mentioned"}
  ],
  "ai_suggestion": "one helpful sentence about what to prioritize"
}''';

    final result = await _sendRequest(
      systemPrompt: systemPrompt,
      userMessage: 'Brain dump: $dump',
      maxTokens: 1024,
    );

    try {
      // Clean the response
      String cleaned = result.trim();
      if (cleaned.contains('```json')) {
        cleaned = cleaned.split('```json')[1].split('```')[0].trim();
      } else if (cleaned.contains('```')) {
        cleaned = cleaned.split('```')[1].split('```')[0].trim();
      }
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      return {
        'tasks': [
          {'title': dump.length > 50 ? '${dump.substring(0, 50)}...' : dump, 'subject': 'General', 'priority': 'medium', 'time': ''}
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
    const systemPrompt = '''You are an expert study coach. 
Create a clear, practical exam battle plan.
Be specific and actionable.
Use day-by-day breakdown.
Keep it concise and motivating.
No emojis.''';

    final userMessage = '''
Create a battle plan for:
Subject: $subject
Days until exam: $daysLeft
Topics to cover: ${topics.join(', ')}

Give a day-by-day study schedule with specific tasks for each day.
Include revision strategy for the last 2 days.
Keep total response under 300 words.''';

    return await _sendRequest(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      maxTokens: 512,
    );
  }

  // ─── STUDY TIP ──────────────────────────────────────

  static Future<String> getDailyTip() async {
    const systemPrompt = 'You are a study coach. Give one short, practical study tip. Maximum 2 sentences. No emojis.';
    const userMessage = 'Give me one practical study or productivity tip for today.';
    return await _sendRequest(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      maxTokens: 100,
    );
  }
}
