// Unit tests for AuthService
// Tests authentication operations: login, signup, logout

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mudda_frontend/api/services/auth_service.dart';
import 'package:mudda_frontend/api/services/storage_service.dart';
import 'package:mudda_frontend/api/models/auth_models.dart';

import '../../mocks/mock_services.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late MockStorageService mockStorage;
  late AuthService authService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.api/api/v1'));
    dioAdapter = DioAdapter(dio: dio);
    mockStorage = MockStorageService();
    authService = AuthService(dio: dio, storageService: mockStorage);
  });

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(LoginRequest(username: '', password: ''));
    registerFallbackValue(
      SignupRequest(
        userName: '',
        name: '',
        email: '',
        dateOfBirth: '',
        phoneNumber: '',
        password: '',
      ),
    );
  });

  group('AuthService.login', () {
    test('returns LoginResponse on successful login', () async {
      // Arrange
      const testToken = 'test_jwt_token_12345';
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(200, {'token': testToken}),
        data: Matchers.any,
      );
      when(() => mockStorage.saveToken(any())).thenAnswer((_) async {});

      // Act
      final result = await authService.login(
        LoginRequest(username: 'testuser', password: 'password123'),
      );

      // Assert
      expect(result.token, testToken);
      verify(() => mockStorage.saveToken(testToken)).called(1);
    });

    test('saves token to storage after successful login', () async {
      // Arrange
      const testToken = 'saved_token';
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(200, {'token': testToken}),
        data: Matchers.any,
      );
      when(() => mockStorage.saveToken(any())).thenAnswer((_) async {});

      // Act
      await authService.login(LoginRequest(username: 'user', password: 'pass'));

      // Assert
      verify(() => mockStorage.saveToken(testToken)).called(1);
    });

    test('throws exception on 401 unauthorized', () async {
      // Arrange
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.throws(
          401,
          DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            response: Response(
              statusCode: 401,
              data: {'error': 'Invalid credentials'},
              requestOptions: RequestOptions(path: '/auth/login'),
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
        data: Matchers.any,
      );

      // Act & Assert
      expect(
        () => authService.login(
          LoginRequest(username: 'wrong', password: 'wrong'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('throws exception on network error', () async {
      // Arrange
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.throws(
          500,
          DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            type: DioExceptionType.connectionError,
            message: 'Connection failed',
          ),
        ),
        data: Matchers.any,
      );

      // Act & Assert
      expect(
        () =>
            authService.login(LoginRequest(username: 'user', password: 'pass')),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthService.signup', () {
    test('completes successfully on 201 status', () async {
      // Arrange
      dioAdapter.onPost(
        '/auth/signup',
        (server) => server.reply(201, {'message': 'User created'}),
        data: Matchers.any,
      );

      // Act & Assert
      await expectLater(
        authService.signup(
          SignupRequest(
            userName: 'newuser',
            name: 'New User',
            email: 'new@example.com',
            dateOfBirth: '1990-01-01',
            phoneNumber: '+1234567890',
            password: 'securePass123',
          ),
        ),
        completes,
      );
    });

    test('throws exception on non-201 status', () async {
      // Arrange
      dioAdapter.onPost(
        '/auth/signup',
        (server) => server.reply(400, {'error': 'Email already exists'}),
        data: Matchers.any,
      );

      // Act & Assert
      expect(
        () => authService.signup(
          SignupRequest(
            userName: 'user',
            name: 'User',
            email: 'existing@example.com',
            dateOfBirth: '1990-01-01',
            phoneNumber: '+1234567890',
            password: 'pass',
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthService.logout', () {
    test('clears token from storage', () async {
      // Arrange
      when(() => mockStorage.deleteToken()).thenAnswer((_) async {});

      // Act
      await authService.logout();

      // Assert
      verify(() => mockStorage.deleteToken()).called(1);
    });
  });

  group('AuthService.getProfile', () {
    test('returns profile data on success', () async {
      // Arrange
      final profileData = {
        'id': 1,
        'userName': 'testuser',
        'name': 'Test User',
        'email': 'test@example.com',
      };
      dioAdapter.onGet(
        '/users/profile',
        (server) => server.reply(200, profileData),
      );

      // Act
      final result = await authService.getProfile();

      // Assert
      expect(result['id'], 1);
      expect(result['userName'], 'testuser');
      expect(result['name'], 'Test User');
    });

    test('throws exception on failure', () async {
      // Arrange
      dioAdapter.onGet(
        '/users/profile',
        (server) => server.throws(
          401,
          DioException(
            requestOptions: RequestOptions(path: '/users/profile'),
            type: DioExceptionType.badResponse,
          ),
        ),
      );

      // Act & Assert
      expect(() => authService.getProfile(), throwsA(isA<Exception>()));
    });
  });
}
