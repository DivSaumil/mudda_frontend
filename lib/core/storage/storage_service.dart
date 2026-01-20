/// Secure storage service for persisting sensitive data.
///
/// Uses flutter_secure_storage for encrypted storage on device.
/// Provides error handling for all operations.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and retrieving sensitive data.
///
/// Currently used for storing the JWT authentication token.
/// All operations include error handling to prevent crashes.
class StorageService {
  final FlutterSecureStorage _storage;

  /// Key used for storing the JWT token.
  static const String _tokenKey = 'jwt_token';

  /// Creates a new StorageService instance.
  ///
  /// Optionally accepts a [FlutterSecureStorage] instance for testing.
  StorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Saves the authentication token to secure storage.
  ///
  /// [token] The JWT token to store.
  /// Logs any errors that occur during saving.
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('StorageService: Error saving token: $e');
    }
  }

  /// Retrieves the stored authentication token.
  ///
  /// Returns the token if found, or null if not stored or on error.
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('StorageService: Error reading token: $e');
      return null;
    }
  }

  /// Deletes the stored authentication token.
  ///
  /// Used for logout operations. Logs any errors.
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('StorageService: Error deleting token: $e');
    }
  }

  /// Checks if a token is currently stored.
  ///
  /// Returns true if a token exists, false otherwise.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clears all stored data.
  ///
  /// Use with caution - this removes all secure storage data.
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('StorageService: Error clearing storage: $e');
    }
  }
}
