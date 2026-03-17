import 'package:flutter/foundation.dart';

void logMessage(String message) {
  if (kDebugMode) {
    print(message);
  }
}
