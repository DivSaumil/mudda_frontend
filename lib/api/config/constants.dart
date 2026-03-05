import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://Mudda-backend-env.eba-p7eppepp.ap-south-1.elasticbeanstalk.com";
    } else {
      return "http://Mudda-backend-env.eba-p7eppepp.ap-south-1.elasticbeanstalk.com";
    }
  }

  /// Base URL specifically for auth routes.
  static String get authBaseUrl {
    return "http://Mudda-backend-env.eba-p7eppepp.ap-south-1.elasticbeanstalk.com";
  }

  /// CDN origin for resolving image keys to full URLs.
  static const String cdnOrigin =
      'https://media-url-devbucket-20256.s3.us-east-1.amazonaws.com';

  /// Resolves an image value from the API into a full displayable URL.
  ///
  /// The backend returns image **keys** (e.g. `"profile-images/abc.jpg"`)
  /// for most responses. Seed/test data may already contain full URLs.
  ///
  /// Use this for EVERY image field: `profileImageUrl`, `author_image_url`,
  /// and each item in `media_urls`.
  static String resolveImageUrl(String? imageValue) {
    if (imageValue == null || imageValue.isEmpty) return '';
    if (imageValue.startsWith('http://') || imageValue.startsWith('https://')) {
      return imageValue; // Already a full URL (seed data)
    }
    return '$cdnOrigin/$imageValue'; // Prepend CDN origin to key
  }
}
