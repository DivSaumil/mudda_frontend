// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryNotifierHash() => r'bdc17891e4b358ddabc10325eb6ac60e138453cc';

/// Shared provider that fetches categories from the backend and caches them
/// in SharedPreferences. Both the issue feed and create-issue screens
/// watch this provider to stay in sync.
///
/// Copied from [CategoryNotifier].
@ProviderFor(CategoryNotifier)
final categoryNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, List<CategoryResponse>>.internal(
      CategoryNotifier.new,
      name: r'categoryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CategoryNotifier = AsyncNotifier<List<CategoryResponse>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
