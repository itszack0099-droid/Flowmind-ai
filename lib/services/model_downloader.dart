import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ModelDownloader {
  static const String modelUrl = "https://huggingface.co/QuantFactory/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/Qwen2.5-0.5B-Instruct.Q4_K_M.gguf";
  static const String modelFileName = "flowmind_ai_model.gguf";

  static Future<String?> downloadModel({required Function(double) onProgress}) async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$modelFileName';
    final file = File(filePath);

    if (await file.exists()) {
      onProgress(1.0);
      return filePath;
    }

    final response = await http.Client().send(http.Request('GET', Uri.parse(modelUrl)));
    final contentLength = response.contentLength ?? 0;
    int received = 0;

    final sink = file.openWrite();
    await response.stream.forEach((chunk) {
      sink.add(chunk);
      received += chunk.length;
      onProgress(received / contentLength);
    });
    await sink.close();

    return filePath;
  }
}
