// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storageServiceHash() => r'62cbe9319bc400f2f78b16bce45d667585b592a2';

/// Provider for the StorageService.
///
/// This is a simple provider that creates a single instance
/// of StorageService to be shared across the app.
///
/// Copied from [storageService].
@ProviderFor(storageService)
final storageServiceProvider = Provider<StorageService>.internal(
  storageService,
  name: r'storageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StorageServiceRef = ProviderRef<StorageService>;
String _$dioHash() => r'0b33c3b3a865b5e8fb59cee38d1cee4f5c8ab52d';

/// Provider for the Dio HTTP client.
///
/// Creates a Dio instance configured with authentication
/// interceptor and proper base URL/timeout settings.
/// Depends on [storageServiceProvider] for token management.
///
/// Copied from [dio].
@ProviderFor(dio)
final dioProvider = Provider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioRef = ProviderRef<Dio>;
String _$issueServiceHash() => r'c6283132ed295af4312f4e7263e0ecabcf12b6d6';

/// See also [issueService].
@ProviderFor(issueService)
final issueServiceProvider = Provider<IssueService>.internal(
  issueService,
  name: r'issueServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$issueServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IssueServiceRef = ProviderRef<IssueService>;
String _$issueRepositoryHash() => r'a234d3a0225f139ea6db3c14b4558153a0f7fa52';

/// See also [issueRepository].
@ProviderFor(issueRepository)
final issueRepositoryProvider = Provider<IssueRepository>.internal(
  issueRepository,
  name: r'issueRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$issueRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IssueRepositoryRef = ProviderRef<IssueRepository>;
String _$voteServiceHash() => r'91ddfbd6afa42503dae08121df89b7429c003191';

/// See also [voteService].
@ProviderFor(voteService)
final voteServiceProvider = Provider<VoteService>.internal(
  voteService,
  name: r'voteServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$voteServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VoteServiceRef = ProviderRef<VoteService>;
String _$voteRepositoryHash() => r'ac6884eb80f27c48d9e5ebc4bbfca7f6db8e41b7';

/// See also [voteRepository].
@ProviderFor(voteRepository)
final voteRepositoryProvider = Provider<VoteRepository>.internal(
  voteRepository,
  name: r'voteRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$voteRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VoteRepositoryRef = ProviderRef<VoteRepository>;
String _$commentServiceHash() => r'8c25362e2636fd4cb473ab7b6a6b9bce9714f124';

/// See also [commentService].
@ProviderFor(commentService)
final commentServiceProvider = Provider<CommentService>.internal(
  commentService,
  name: r'commentServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$commentServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommentServiceRef = ProviderRef<CommentService>;
String _$commentRepositoryHash() => r'f60faf7ea03dd7d3fa1166cc4e947a9773e84613';

/// See also [commentRepository].
@ProviderFor(commentRepository)
final commentRepositoryProvider = Provider<CommentRepository>.internal(
  commentRepository,
  name: r'commentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$commentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommentRepositoryRef = ProviderRef<CommentRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
