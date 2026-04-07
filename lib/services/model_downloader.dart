import 'package:http/http.dart' as http;

class ModelDownloader {
  static const String defaultBaseUrl = 'http://10.0.2.2:11434';

  static Future<bool> checkOllamaConnectivity({
    String baseUrl = defaultBaseUrl,
    Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.3);
      final response = await http
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 8));
      onProgress?.call(1.0);
      return response.statusCode == 200;
    } catch (_) {
      onProgress?.call(0.0);
      return false;
    }
  }

  static Future<String?> downloadModel({
    required Function(double) onProgress,
    String baseUrl = defaultBaseUrl,
  }) async {
    final connected = await checkOllamaConnectivity(
      baseUrl: baseUrl,
      onProgress: onProgress,
    );
    return connected ? baseUrl : null;
  }
}
