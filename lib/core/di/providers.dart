/// Core dependency injection providers.
///
/// Defines Riverpod providers for core services that are used
/// throughout the application. These are the foundational providers
/// that other feature providers depend on.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Using existing storage service for compatibility during migration
import '../../api/services/issue_service.dart';
import '../../api/repositories/issue_repository.dart';
import '../../api/services/vote_service.dart';
import '../../api/repositories/vote_repository.dart';
import '../../api/services/comment_service.dart';
import '../../api/repositories/comment_repository.dart';
import '../../api/services/storage_service.dart';
import '../../api/services/auth_interceptor.dart';
import '../../api/config/constants.dart';

part 'providers.g.dart';

/// Provider for the StorageService.
///
/// This is a simple provider that creates a single instance
/// of StorageService to be shared across the app.
@Riverpod(keepAlive: true)
StorageService storageService(Ref ref) {
  return StorageService();
}

/// Provider for the Dio HTTP client.
///
/// Creates a Dio instance configured with authentication
/// interceptor and proper base URL/timeout settings.
/// Depends on [storageServiceProvider] for token management.
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

@Riverpod(keepAlive: true)
IssueService issueService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return IssueService(dio);
}

@Riverpod(keepAlive: true)
IssueRepository issueRepository(Ref ref) {
  final service = ref.watch(issueServiceProvider);
  return IssueRepository(service: service);
}

@Riverpod(keepAlive: true)
VoteService voteService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return VoteService(dio);
}

@Riverpod(keepAlive: true)
VoteRepository voteRepository(Ref ref) {
  final service = ref.watch(voteServiceProvider);
  return VoteRepository(service: service);
}

@Riverpod(keepAlive: true)
CommentService commentService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CommentService(dio);
}

@Riverpod(keepAlive: true)
CommentRepository commentRepository(Ref ref) {
  final service = ref.watch(commentServiceProvider);
  return CommentRepository(service: service);
}
