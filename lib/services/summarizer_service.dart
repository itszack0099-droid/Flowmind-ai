import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'groq_service.dart';

class SummarizerService {
  static const String _groqApiKey =
      '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';

  // ─── YOUTUBE TRANSCRIPT ─────────────────────────────

  static Future<String> getYouTubeTranscript(String url) async {
    try {
      // Extract video ID
      final videoId = _extractVideoId(url);
      if (videoId == null) return 'ERROR: Invalid YouTube URL';

      // Use youtubetranscript.com free API
      final response = await http.get(
        Uri.parse(
            'https://youtubetranscript.com/?server_vid2=$videoId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final text = response.body;
        // Clean HTML tags
        final cleaned =
            text.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
        if (cleaned.length > 100) return cleaned;
      }

      // Fallback: try another free transcript API
      final response2 = await http.get(
        Uri.parse(
            'https://www.searchapi.io/api/v1/search?engine=youtube_transcripts&video_id=$videoId'),
      ).timeout(const Duration(seconds: 10));

      if (response2.statusCode == 200) {
        final data = jsonDecode(response2.body);
        if (data['transcripts'] != null) {
          final transcripts = data['transcripts'] as List;
          return transcripts
              .map((t) => t['text'].toString())
              .join(' ');
        }
      }

      return 'ERROR: Could not get transcript. Make sure the video has captions enabled.';
    } catch (e) {
      return 'ERROR: $e';
    }
  }

  static String? _extractVideoId(String url) {
    final patterns = [
      RegExp(r'(?:v=)([0-9A-Za-z_-]{11})'),
      RegExp(r'(?:youtu\.be\/)([0-9A-Za-z_-]{11})'),
      RegExp(r'(?:shorts\/)([0-9A-Za-z_-]{11})'),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) return match.group(1);
    }
    return null;
  }

  // ─── AUDIO TRANSCRIPTION (Groq Whisper) ─────────────

  static Future<String> transcribeAudio(
      String filePath, String fileName) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      // Groq Whisper API
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.groq.com/openai/v1/audio/transcriptions'),
      );

      request.headers['Authorization'] = 'Bearer $_groqApiKey';

      String mimeType = 'audio/mpeg';
      if (fileName.endsWith('.wav')) mimeType = 'audio/wav';
      if (fileName.endsWith('.mp4')) mimeType = 'video/mp4';
      if (fileName.endsWith('.m4a')) mimeType = 'audio/m4a';
      if (fileName.endsWith('.webm')) mimeType = 'audio/webm';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );
      request.fields['model'] = 'whisper-large-v3';
      request.fields['response_format'] = 'text';

      final response = await request.send().timeout(
            const Duration(seconds: 60),
          );
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return body;
      } else {
        return 'ERROR: Audio transcription failed. ${response.statusCode}';
      }
    } catch (e) {
      return 'ERROR: $e';
    }
  }

  // ─── PDF TEXT EXTRACTION ─────────────────────────────

  static Future<String> extractPdfText(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      return await _extractPdfFromBytes(bytes);
    } catch (e) {
      return 'ERROR: Could not read PDF: $e';
    }
  }

  static Future<String> _extractPdfFromBytes(
      Uint8List bytes) async {
    try {
      // Simple PDF text extraction — look for text between BT and ET markers
      final content = String.fromCharCodes(bytes);
      final textParts = <String>[];

      // Extract readable ASCII text from PDF bytes
      final buffer = StringBuffer();
      for (int i = 0; i < bytes.length; i++) {
        final b = bytes[i];
        if (b >= 32 && b <= 126) {
          buffer.writeCharCode(b);
        } else if (b == 10 || b == 13) {
          final line = buffer.toString().trim();
          if (line.length > 3 &&
              !line.startsWith('/') &&
              !line.startsWith('<<') &&
              !line.contains('obj') &&
              RegExp(r'[a-zA-Z\s]{4,}').hasMatch(line)) {
            textParts.add(line);
          }
          buffer.clear();
        }
      }

      final result = textParts.join(' ').trim();
      if (result.length > 50) return result;

      return 'Could not extract text. PDF may be scanned/image-based.';
    } catch (e) {
      return 'ERROR: $e';
    }
  }

  // ─── DOCX TEXT EXTRACTION ────────────────────────────

  static Future<String> extractDocxText(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      // DOCX is a ZIP file — extract word/document.xml
      // Simple approach: find text between XML tags
      final content = String.fromCharCodes(bytes
          .where((b) => b >= 32 && b <= 126 || b == 10)
          .toList());

      // Extract text between w:t tags
      final regex = RegExp(r'<w:t[^>]*>([^<]+)<\/w:t>');
      final matches = regex.allMatches(content);
      final texts = matches.map((m) => m.group(1) ?? '').toList();

      if (texts.isNotEmpty) {
        return texts.join(' ').trim();
      }

      return 'Could not extract text from DOCX file.';
    } catch (e) {
      return 'ERROR: $e';
    }
  }

  // ─── TXT FILE ────────────────────────────────────────

  static Future<String> readTextFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      return 'ERROR: $e';
    }
  }

  // ─── AI PROCESS (Summarize/Explain/Quiz) ─────────────

  static Future<String> processWithAI({
    required String text,
    required String action,
    required String fileName,
  }) async {
    final truncated = text.length > 8000
        ? '${text.substring(0, 8000)}...[truncated]'
        : text;

    String prompt;
    switch (action) {
      case 'summarize':
        prompt =
            'Summarize this content from "$fileName" in clear bullet points. Be concise and highlight key information:\n\n$truncated';
        break;
      case 'explain':
        prompt =
            'Explain the main concepts from "$fileName" in simple terms that a student can understand:\n\n$truncated';
        break;
      case 'quiz':
        prompt =
            'Create 5 quiz questions with answers based on this content from "$fileName". Format: Q1: [question]\nA1: [answer]\n\n$truncated';
        break;
      case 'keypoints':
        prompt =
            'Extract the 10 most important key points from "$fileName":\n\n$truncated';
        break;
      default:
        prompt = '$action\n\nContent from "$fileName":\n\n$truncated';
    }

    return await GroqService.chat(
      userMessage: prompt,
      history: [],
    );
  }
}
