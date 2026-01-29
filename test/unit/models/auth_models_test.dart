// Unit tests for auth models
// These tests lock in existing JSON parsing behavior before refactoring

import 'package:flutter_test/flutter_test.dart';
import 'package:mudda_frontend/api/models/auth_models.dart';

void main() {
  group('LoginRequest', () {
    test('toJson produces correct output', () {
      final request = LoginRequest(
        username: 'testuser',
        password: 'password123',
      );

      final json = request.toJson();

      expect(json['username'], 'testuser');
      expect(json['password'], 'password123');
    });

    test('toJson includes both required fields', () {
      final request = LoginRequest(
        username: 'user@example.com',
        password: 'securePass!',
      );

      final json = request.toJson();

      expect(json.keys, containsAll(['username', 'password']));
      expect(json.length, 2);
    });
  });

  group('LoginResponse', () {
    test('fromJson parses accessToken correctly', () {
      final json = {
        'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.token',
        'refreshToken': 'refresh_token_value',
        'tokenType': 'Bearer',
        'accessExpiresInMs': 3600000,
      };

      final response = LoginResponse.fromJson(json);

      expect(
        response.accessToken,
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.token',
      );
      // Test backwards-compatible accessor
      expect(response.token, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.token');
    });

    test('fromJson parses all token fields', () {
      final json = {
        'accessToken': 'access_token_123',
        'refreshToken': 'refresh_token_456',
        'tokenType': 'Bearer',
        'accessExpiresInMs': 7200000,
        'user': {'id': 1, 'name': 'Test User'},
      };

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, 'access_token_123');
      expect(response.refreshToken, 'refresh_token_456');
      expect(response.tokenType, 'Bearer');
      expect(response.accessExpiresInMs, 7200000);
      expect(response.user, isNotNull);
      expect(response.user?['id'], 1);
    });

    test('fromJson handles null optional fields', () {
      final json = <String, dynamic>{'accessToken': 'token_only'};

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, 'token_only');
      expect(response.refreshToken, isNull);
      expect(response.tokenType, isNull);
      expect(response.accessExpiresInMs, isNull);
      expect(response.user, isNull);
    });

    test('token getter returns empty string when accessToken is null', () {
      final json = <String, dynamic>{};

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, isNull);
      expect(response.token, ''); // Backwards-compatible accessor
    });
  });

  group('SignupRequest', () {
    test('toJson includes all required fields with correct key names', () {
      final request = SignupRequest(
        userName: 'newuser',
        name: 'New User',
        email: 'newuser@example.com',
        dateOfBirth: '1990-05-15',
        phoneNumber: '+1234567890',
        password: 'securePassword123',
      );

      final json = request.toJson();

      // Note: API expects 'username' not 'userName'
      expect(json['username'], 'newuser');
      expect(json['name'], 'New User');
      expect(json['email'], 'newuser@example.com');
      expect(json['dateOfBirth'], '1990-05-15');
      expect(json['phoneNumber'], '+1234567890');
      expect(json['password'], 'securePassword123');
      expect(json['role'], 'CITIZEN'); // Default role
    });

    test('toJson includes optional profileImageUrl when provided', () {
      final request = SignupRequest(
        userName: 'user',
        name: 'User',
        email: 'user@test.com',
        dateOfBirth: '2000-01-01',
        phoneNumber: '+0987654321',
        password: 'pass123',
        profileImageUrl: 'https://example.com/avatar.jpg',
      );

      final json = request.toJson();

      expect(json['profileImageUrl'], 'https://example.com/avatar.jpg');
    });

    test('toJson includes null profileImageUrl when not provided', () {
      final request = SignupRequest(
        userName: 'user',
        name: 'User',
        email: 'user@test.com',
        dateOfBirth: '2000-01-01',
        phoneNumber: '+0987654321',
        password: 'pass123',
      );

      final json = request.toJson();

      // The current implementation includes null, which we're documenting
      expect(json.containsKey('profileImageUrl'), true);
      expect(json['profileImageUrl'], isNull);
    });
  });
}
