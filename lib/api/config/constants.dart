import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8080";
    } else {
      // For Android Emulator, use 10.0.2.2
      // For iOS Simulator, localhost usually works or use machine IP
      // For physical device, use machine IP
      return "http://10.0.2.2:8080";
    }
  }
}
