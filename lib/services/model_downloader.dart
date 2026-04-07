import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ModelDownloader {
  static const String modelUrl = 'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-q4_k_m.gguf';

  static Future<String?> downloadModel({
    required Function(double) onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final modelPath = '${dir.path}/qwen2.5-0.5b-q4_k_m.gguf';
    final file = File(modelPath);

    if (await file.exists()) return modelPath;

    try {
      final response = await http.Client().send(http.Request('GET', Uri.parse(modelUrl)));
      final contentLength = response.contentLength ?? 0;
      final sink = file.openWrite();
      int received = 0;

      await response.stream.forEach((chunk) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0) {
          onProgress(received / contentLength);
        }
      });

      await sink.close();
      return modelPath;
    } catch (e) {
      debugPrint("Download error: $e");
      if (await file.exists()) await file.delete();
      return null;
    }
  }
}