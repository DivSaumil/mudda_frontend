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
    test('fromJson parses token correctly', () {
      final json = {'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.token'};

      final response = LoginResponse.fromJson(json);

      expect(response.token, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.token');
    });

    test('fromJson handles complex token', () {
      final complexToken =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.'
          'SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

      final json = {'token': complexToken};

      final response = LoginResponse.fromJson(json);

      expect(response.token, complexToken);
    });
  });

  group('SignupRequest', () {
    test('toJson includes all required fields', () {
      final request = SignupRequest(
        userName: 'newuser',
        name: 'New User',
        email: 'newuser@example.com',
        dateOfBirth: '1990-05-15',
        phoneNumber: '+1234567890',
        password: 'securePassword123',
      );

      final json = request.toJson();

      expect(json['userName'], 'newuser');
      expect(json['name'], 'New User');
      expect(json['email'], 'newuser@example.com');
      expect(json['dateOfBirth'], '1990-05-15');
      expect(json['phoneNumber'], '+1234567890');
      expect(json['password'], 'securePassword123');
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
