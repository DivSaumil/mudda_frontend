import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  String? _cachedToken;
  bool _hasFetched = false;

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    _hasFetched = true;
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  Future<String?> getToken() async {
    if (_hasFetched) return _cachedToken;

    try {
      _cachedToken = await _storage.read(key: _tokenKey);
      _hasFetched = true;
      return _cachedToken;
    } catch (e) {
      debugPrint('Error reading token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    _cachedToken = null;
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('Error deleting token: $e');
    }
  }
}
