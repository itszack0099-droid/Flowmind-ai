import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ModelDownloader {
  // Qwen2.5-0.5B Q4_K_M GGUF model (≈380 MB)
  static const String modelUrl =
      'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-q4_k_m.gguf';

  /// Model download with progress callback
  static Future<String?> downloadModel({
    required Function(double) onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final modelPath = '${dir.path}/qwen2.5-0.5b-q4_k_m.gguf';
    final file = File(modelPath);

    // Agar model pehle se hai toh direct return kar do
    if (await file.exists()) {
      return modelPath;
    }

    try {
      final request = http.Request('GET', Uri.parse(modelUrl));
      final response = await http.Client().send(request);

      final contentLength = response.contentLength ?? 0;
      final sink = file.openWrite();
      int receivedBytes = 0;

      await response.stream.forEach((chunk) {
        sink.add(chunk);
        receivedBytes += chunk.length;

        if (contentLength > 0) {
          final progress = receivedBytes / contentLength;
          onProgress(progress);
        }
      });

      await sink.close();
      return modelPath;
    } catch (e) {
      debugPrint("Model download error: $e");
      // Agar download fail ho toh file delete kar do (partial file na rahe)
      if (await file.exists()) {
        await file.delete();
      }
      return null;
    }
  }
}