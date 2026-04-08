import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ModelDownloader {
  static const String modelUrl =
      'https://huggingface.co/bartowski/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/Qwen2.5-0.5B-Instruct-Q4_K_M.gguf';

  static const String modelFileName = 'qwen2.5-0.5b-q4_k_m.gguf';

  static Future<String> get modelPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$modelFileName';
  }

  static Future<bool> isModelDownloaded() async {
    final path = await modelPath;
    return File(path).existsSync();
  }

  static Future<String?> downloadModel({
    required Function(double) onProgress,
    Function(String)? onStatus,
  }) async {
    final path = await modelPath;
    final file = File(path);

    try {
      onStatus?.call("Connecting to model server...");
      final request = http.Request('GET', Uri.parse(modelUrl));
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        onStatus?.call("Download failed: HTTP ${streamedResponse.statusCode}");
        return null;
      }

      final totalBytes = streamedResponse.contentLength ?? 0;
      var receivedBytes = 0;

      final sink = file.openWrite();

      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
        onStatus?.call(
          "Downloading: ${(receivedBytes / 1024 / 1024).toStringAsFixed(1)} MB"
          "${totalBytes > 0 ? ' / ${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB' : ''}",
        );
      }

      await sink.flush();
      await sink.close();
      onStatus?.call("✅ Download complete!");
      return path;
    } catch (e) {
      if (await file.exists()) await file.delete();
      onStatus?.call("Download failed: $e");
      return null;
    }
  }
}
