import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // Choose a base URL per platform to avoid fetch errors on web/emulator
  static String get baseUrl {
    if (kIsWeb)
      return "http://localhost:5003/api"; // browser can reach localhost directly
    if (Platform.isAndroid)
      return "http://10.0.2.2:5003/api"; // Android emulator -> host loopback
    return "http://localhost:5003/api"; // iOS simulator/desktop
  }
}
