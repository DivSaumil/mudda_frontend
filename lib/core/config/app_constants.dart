/// Core configuration constants for the application.
///
/// Contains environment-specific settings like API URLs.
library;

import 'package:flutter/foundation.dart';

/// Application-wide constants and configuration.
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  /// Base URL for the API server.
  ///
  /// Uses different URLs based on platform:
  /// - Web: Direct URL to backend
  /// - Mobile: Same for now (deployed backend)
  static String get baseUrl {
    if (kIsWeb) {
      return "http://mudda.us-east-1.elasticbeanstalk.com/";
    } else {
      // For Android Emulator, use 10.0.2.2
      // For iOS Simulator, localhost usually works or use machine IP
      // For physical device, use machine IP
      return "http://mudda.us-east-1.elasticbeanstalk.com/";
    }
  }

  /// API version path prefix
  static const String apiVersion = '/api/v1';

  /// Full API base URL including version
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  /// Default pagination page size
  static const int defaultPageSize = 20;

  /// HTTP timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
