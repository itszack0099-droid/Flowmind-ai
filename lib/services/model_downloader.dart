import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ModelDownloader {
  static const String modelUrl =
      'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-q4_k_m.gguf';
  static const String _modelFileName = 'qwen2.5-0.5b-q4_k_m.gguf';

  static Future<bool> isModelDownloaded() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final modelFile = File('${dir.path}/$_modelFileName');
      return modelFile.existsSync();
    } catch (e) {
      debugPrint("isModelDownloaded error: $e");
      return false;
    }
  }

  static Future<String?> downloadModel({
    required Function(double) onProgress,
    Function(String)? onStatus,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final modelPath = '${dir.path}/$_modelFileName';
    final file = File(modelPath);

    if (await file.exists()) {
      onStatus?.call("Model already downloaded!");
      return modelPath;
    }

    try {
      onStatus?.call("Connecting to server...");
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(modelUrl));
      final response = await client.send(request);
      final contentLength = response.contentLength ?? 0;
      final sink = file.openWrite();
      int received = 0;

      await response.stream.forEach((chunk) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0) {
          final progress = received / contentLength;
          onProgress(progress);
          final mb = received ~/ (1024 * 1024);
          final totalMb = contentLength ~/ (1024 * 1024);
          onStatus?.call("Downloading... $mb MB / $totalMb MB");
        }
      });

      await sink.close();
      client.close();
      onStatus?.call("Download complete!");
      return modelPath;
    } catch (e) {
      debugPrint("Download error: $e");
      onStatus?.call("Download failed. Please check your connection.");
      if (await file.exists()) await file.delete();
      return null;
    }
  }

  static Future<void> deleteModel() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_modelFileName');
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint("deleteModel error: $e");
    }
  }
}
