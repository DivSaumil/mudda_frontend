/// Core dependency injection providers.
///
/// Defines Riverpod providers for core services that are used
/// throughout the application.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mudda_frontend/api/services/storage_service.dart';
import 'package:mudda_frontend/api/services/auth_interceptor.dart';
import 'package:mudda_frontend/api/services/auth_service.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/services/vote_service.dart';
import 'package:mudda_frontend/api/services/comment_service.dart';
import 'package:mudda_frontend/api/services/user_service.dart';
import 'package:mudda_frontend/api/services/category_service.dart';
import 'package:mudda_frontend/api/services/location_service.dart';
import 'package:mudda_frontend/api/services/role_service.dart';
import 'package:mudda_frontend/api/services/amazon_service.dart';
import 'package:mudda_frontend/api/services/account_service.dart';
import 'package:mudda_frontend/api/services/issue_cache_service.dart';
import 'package:mudda_frontend/api/repositories/issue_repository.dart';
import 'package:mudda_frontend/api/repositories/vote_repository.dart';
import 'package:mudda_frontend/api/repositories/comment_repository.dart';
import 'package:mudda_frontend/api/repositories/amazon_repository.dart';
import 'package:mudda_frontend/api/repositories/account_repository.dart';
import 'package:mudda_frontend/api/config/constants.dart';

part 'providers.g.dart';

/// Storage service for token management.
@Riverpod(keepAlive: true)
StorageService storageService(Ref ref) {
  return StorageService();
}

/// Dio HTTP client with auth interceptor.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final storage = ref.watch(storageServiceProvider);
  final interceptor = AuthInterceptor(storage);

  final dio = Dio(
    BaseOptions(
      baseUrl: '${AppConstants.baseUrl}/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  dio.interceptors.add(interceptor);

  return dio;
}

/// Auth service.
@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final d = ref.watch(dioProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthService(dio: d, storageService: storage);
}

/// Issue service + repository.
@Riverpod(keepAlive: true)
IssueService issueService(Ref ref) {
  final d = ref.watch(dioProvider);
  return IssueService(d);
}

/// Issue cache service for offline support.
@Riverpod(keepAlive: true)
IssueCacheService issueCacheService(Ref ref) {
  return IssueCacheService();
}

@Riverpod(keepAlive: true)
IssueRepository issueRepository(Ref ref) {
  final service = ref.watch(issueServiceProvider);
  final cacheService = ref.watch(issueCacheServiceProvider);
  return IssueRepository(service: service, cacheService: cacheService);
}

/// Vote service + repository.
@Riverpod(keepAlive: true)
VoteService voteService(Ref ref) {
  final d = ref.watch(dioProvider);
  return VoteService(d);
}

@Riverpod(keepAlive: true)
VoteRepository voteRepository(Ref ref) {
  final service = ref.watch(voteServiceProvider);
  return VoteRepository(service: service);
}

/// Comment service + repository.
@Riverpod(keepAlive: true)
CommentService commentService(Ref ref) {
  final d = ref.watch(dioProvider);
  return CommentService(d);
}

@Riverpod(keepAlive: true)
CommentRepository commentRepository(Ref ref) {
  final service = ref.watch(commentServiceProvider);
  return CommentRepository(service: service);
}

/// User service.
@Riverpod(keepAlive: true)
UserService userService(Ref ref) {
  final d = ref.watch(dioProvider);
  return UserService(d);
}

/// Category service.
@Riverpod(keepAlive: true)
CategoryService categoryService(Ref ref) {
  final d = ref.watch(dioProvider);
  return CategoryService(d);
}

/// Location service.
@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) {
  final d = ref.watch(dioProvider);
  return LocationService(d);
}

/// Role service.
@Riverpod(keepAlive: true)
RoleService roleService(Ref ref) {
  final d = ref.watch(dioProvider);
  return RoleService(d);
}

/// Amazon image service + repository.
@Riverpod(keepAlive: true)
AmazonImageService amazonImageService(Ref ref) {
  final d = ref.watch(dioProvider);
  return AmazonImageService(d);
}

@Riverpod(keepAlive: true)
AmazonImageRepository amazonImageRepository(Ref ref) {
  final service = ref.watch(amazonImageServiceProvider);
  return AmazonImageRepository(service: service);
}

/// Account service + repository.
@Riverpod(keepAlive: true)
AccountService accountService(Ref ref) {
  final d = ref.watch(dioProvider);
  return AccountService(d);
}

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  final service = ref.watch(accountServiceProvider);
  return AccountRepository(service: service);
}
