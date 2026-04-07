import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdfx/pdfx.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:http/http.dart' as http;
import 'local_llm_service.dart';

class SummarizerService {
  static final LocalLLMService _llm = LocalLLMService();

  static Future<String> extractTextFromFile(File file) async {
    final extension = file.path.split('.').last.toLowerCase();

    try {
      if (extension == 'pdf') {
        return await _extractPdfText(file);
      } else if (extension == 'docx') {
        return await _extractDocxText(file);
      } else if (extension == 'txt') {
        return await file.readAsString();
      } else {
        return "Unsupported file type: $extension";
      }
    } catch (e) {
      debugPrint("File extraction error: $e");
      return "Error reading file: $e";
    }
  }

  static Future<String> _extractPdfText(File file) async {
    try {
      final document = await PdfDocument.openFile(file.path);
      final pageCount = document.pagesCount;
      final buffer = StringBuffer();

      for (int i = 1; i <= pageCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width,
          height: page.height,
          format: PdfPageImageFormat.png,
        );
        await page.close();
        pageImage?.bytes;
        buffer.writeln('[Page $i rendered]');
      }

      await document.close();

      return 'PDF: ${file.path.split('/').last} ($pageCount pages)\n'
          'Note: Full text extraction from PDF is not available on Android. '
          'For best results, copy-paste the text directly or use a .txt file.';
    } catch (e) {
      debugPrint("PDF extraction error: $e");
      return "Could not read PDF file: $e";
    }
  }

  static Future<String> _extractDocxText(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final text = docxToText(bytes);
      return text.trim().isEmpty ? "No text found in document." : text;
    } catch (e) {
      debugPrint("DOCX extraction error: $e");
      return "Could not read DOCX file: $e";
    }
  }

  static Future<String> getYouTubeTranscript(String videoId) async {
    try {
      final url = Uri.parse(
        'https://www.youtube.com/watch?v=$videoId',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0',
      });

      if (response.statusCode != 200) {
        return "Could not access YouTube video. Check the video ID and try again.";
      }

      final captionTrackPattern = RegExp(r'"captionTracks":(\[.*?\])', dotAll: true);
      final match = captionTrackPattern.firstMatch(response.body);
      if (match == null) {
        return "No transcript available for this video (captions may be disabled).";
      }

      final tracksJson = match.group(1)!;
      final tracks = jsonDecode(tracksJson) as List;
      if (tracks.isEmpty) {
        return "No transcript tracks found for this video.";
      }

      String? captionUrl;
      for (final track in tracks) {
        if (track['languageCode'] == 'en' || track['kind'] != 'asr') {
          captionUrl = track['baseUrl'] as String?;
          break;
        }
      }
      captionUrl ??= tracks.first['baseUrl'] as String?;

      if (captionUrl == null) {
        return "Could not find a usable caption track.";
      }

      final captionResponse = await http.get(Uri.parse(captionUrl));
      if (captionResponse.statusCode != 200) {
        return "Could not fetch transcript data.";
      }

      final textPattern = RegExp(r'<text[^>]*>(.*?)</text>', dotAll: true);
      final matches = textPattern.allMatches(captionResponse.body);
      final transcript = matches
          .map((m) => m.group(1)!
              .replaceAll('&amp;', '&')
              .replaceAll('&quot;', '"')
              .replaceAll('&#39;', "'")
              .replaceAll('&lt;', '<')
              .replaceAll('&gt;', '>')
              .trim())
          .where((t) => t.isNotEmpty)
          .join(' ');

      return transcript.isEmpty
          ? "Transcript is empty or could not be parsed."
          : transcript;
    } catch (e) {
      debugPrint("YouTube transcript error: $e");
      return "Could not fetch YouTube transcript: $e";
    }
  }

  static Future<String> processWithAI(String text, String action) async {
    if (!_llm.isInitialized) {
      await _llm.initializeModel();
    }

    String prompt;
    switch (action.toLowerCase()) {
      case 'summarize':
        prompt = "Summarize the following text concisely:\n\n$text";
        break;
      case 'explain':
        prompt = "Explain the following text in simple terms like a friendly teacher:\n\n$text";
        break;
      case 'quiz':
        prompt = "Create 5 short quiz questions from this text with answers:\n\n$text";
        break;
      case 'keypoints':
        prompt = "Extract 5-7 important key points from this text:\n\n$text";
        break;
      default:
        prompt = "Process this text and give useful insights:\n\n$text";
    }

    try {
      return await _llm.getResponse(prompt);
    } catch (e) {
      return "Sorry, AI processing failed. Please try again.";
    }
  }
}
