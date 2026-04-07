import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:youtube_transcript_api/youtube_transcript_api.dart';
import 'local_llm_service.dart';

class SummarizerService {
  static final LocalLLMService _llm = LocalLLMService();

  // Extract text from any file
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
    final document = await PdfDocument.openFile(file.path);
    String fullText = '';
    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageText = await page.text;           // Correct method in pdfx
      fullText += pageText + '\n';
      await page.close();
    }
    await document.close();
    return fullText;
  }

  static Future<String> _extractDocxText(File file) async {
    final bytes = await file.readAsBytes();
    return await DocxToText(bytes).parse();
  }

  // YouTube transcript
  static Future<String> getYouTubeTranscript(String videoId) async {
    try {
      final transcript = await YoutubeTranscriptApi().getTranscript(videoId);
      return transcript.map((line) => line.text).join(' ');
    } catch (e) {
      return "Could not fetch YouTube transcript.";
    }
  }

  // Process with AI (summarize, explain, quiz, etc.)
  static Future<String> processWithAI(String text, String action) async {
    String prompt = '';

    switch (action.toLowerCase()) {
      case 'summarize':
        prompt = "Summarize the following text in simple Hindi-English mix:\n\n$text";
        break;
      case 'explain':
        prompt = "Explain the following text like a friendly teacher:\n\n$text";
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