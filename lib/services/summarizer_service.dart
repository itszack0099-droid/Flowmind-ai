import 'dart:io';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_transcript_api/youtube_transcript_api.dart'; // agar already added hai toh theek, nahi toh pubspec mein add kar lena
import '../services/local_llm_service.dart';

class SummarizerService {
  static final LocalLLMService _llm = LocalLLMService();

  // ─── FILE EXTRACTION (Local & Offline) ─────────────────────────────────
  static Future<String> extractPdfText(String filePath) async {
    try {
      final document = await PdfDocument.openFile(filePath);
      String fullText = '';
      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        final pageText = await page.text;
        fullText += '${pageText.text}\n';
      }
      return fullText.trim();
    } catch (e) {
      return 'ERROR: Could not read PDF file';
    }
  }

  static Future<String> extractDocxText(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final docxText = await DocxToText(bytes).parse();
      return docxText;
    } catch (e) {
      return 'ERROR: Could not read DOCX file';
    }
  }

  static Future<String> readTextFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      return 'ERROR: Could not read text file';
    }
  }

  static Future<String> transcribeAudio(String filePath, String fileName) async {
    // Currently placeholder (Whisper local model heavy hai)
    // Future mein local whisper add kar sakte hain
    return 'ERROR: Audio transcription coming soon with local model. For now use text/PDF/DOCX.';
  }

  static Future<String> getYouTubeTranscript(String url) async {
    try {
      final videoId = url.split('v=')[1].split('&')[0];
      final transcript = await YoutubeTranscriptApi().getTranscript(videoId);
      return transcript.map((line) => line.text).join(' ');
    } catch (e) {
      return 'ERROR: Could not fetch YouTube transcript. Make sure video has captions enabled.';
    }
  }

  // ─── MAIN AI PROCESSING (Local LLM) ─────────────────────────────────
  static Future<String> processWithAI({
    required String text,
    required String action,
    required String fileName,
  }) async {
    String systemPrompt = '';

    switch (action) {
      case 'summarize':
        systemPrompt = '''
You are FlowMind AI - expert summarizer.
Create a clean, short, bullet-point summary of the content.
Focus on key points, important facts, and actionable takeaways.
Keep it under 300 words. Use Hindi + English mix if needed.
''';
        break;

      case 'explain':
        systemPrompt = '''
You are FlowMind AI - friendly study coach.
Explain the content in very simple language for students.
Use easy examples, analogies, and step-by-step breakdown.
Make it engaging and motivating.
''';
        break;

      case 'quiz':
        systemPrompt = '''
You are FlowMind AI - quiz master.
Create 5 high-quality multiple choice questions with 4 options each.
Include correct answer and short explanation for every question.
Format it nicely with emojis.
''';
        break;

      case 'keypoints':
        systemPrompt = '''
You are FlowMind AI - key points extractor.
Extract the top 8-10 most important key points from the content.
Number them and make them short and powerful.
''';
        break;

      default:
        systemPrompt = 'You are FlowMind AI. Help the user with the given content.';
    }

    final fullPrompt = '''
<system>
$systemPrompt
</system>

<content>
$text
</content>

<task>
$fileName - $action
</task>
''';

    try {
      final response = await _llm.getResponse(fullPrompt);
      return response;
    } catch (e) {
      return 'ERROR: Local AI failed to process. Please try again.';
    }
  }
}