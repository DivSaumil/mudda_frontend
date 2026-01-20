// Mock classes for testing
// Using Mocktail for null-safe mocking

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mudda_frontend/api/services/storage_service.dart';
import 'package:mudda_frontend/api/services/auth_service.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/services/vote_service.dart';
import 'package:mudda_frontend/api/services/comment_service.dart';
import 'package:mudda_frontend/api/services/user_service.dart';
import 'package:mudda_frontend/api/services/location_service.dart';
import 'package:mudda_frontend/api/services/category_service.dart';
import 'package:mudda_frontend/api/repositories/issue_repository.dart';
import 'package:mudda_frontend/api/repositories/vote_repository.dart';
import 'package:mudda_frontend/api/repositories/comment_repository.dart';

/// Mock for StorageService - handles secure token storage
class MockStorageService extends Mock implements StorageService {}

/// Mock for AuthService - handles login, signup, logout
class MockAuthService extends Mock implements AuthService {}

/// Mock for IssueService - handles issue CRUD operations
class MockIssueService extends Mock implements IssueService {}

/// Mock for VoteService - handles voting on issues
class MockVoteService extends Mock implements VoteService {}

/// Mock for CommentService - handles comments on issues
class MockCommentService extends Mock implements CommentService {}

/// Mock for UserService - handles user operations
class MockUserService extends Mock implements UserService {}

/// Mock for LocationService - handles location operations
class MockLocationService extends Mock implements LocationService {}

/// Mock for CategoryService - handles category operations
class MockCategoryService extends Mock implements CategoryService {}

/// Mock for IssueRepository - repository layer for issues
class MockIssueRepository extends Mock implements IssueRepository {}

/// Mock for VoteRepository - repository layer for votes
class MockVoteRepository extends Mock implements VoteRepository {}

/// Mock for CommentRepository - repository layer for comments
class MockCommentRepository extends Mock implements CommentRepository {}

/// Mock for Dio - HTTP client
class MockDio extends Mock implements Dio {}
