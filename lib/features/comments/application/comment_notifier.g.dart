// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentNotifierHash() => r'f66de38e85c20072530409a8303171caa1cef7de';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CommentNotifier
    extends BuildlessAutoDisposeNotifier<CommentState> {
  late final int issueId;

  CommentState build(int issueId);
}

/// Notifier for managing comments on a specific issue.
///
/// Copied from [CommentNotifier].
@ProviderFor(CommentNotifier)
const commentNotifierProvider = CommentNotifierFamily();

/// Notifier for managing comments on a specific issue.
///
/// Copied from [CommentNotifier].
class CommentNotifierFamily extends Family<CommentState> {
  /// Notifier for managing comments on a specific issue.
  ///
  /// Copied from [CommentNotifier].
  const CommentNotifierFamily();

  /// Notifier for managing comments on a specific issue.
  ///
  /// Copied from [CommentNotifier].
  CommentNotifierProvider call(int issueId) {
    return CommentNotifierProvider(issueId);
  }

  @override
  CommentNotifierProvider getProviderOverride(
    covariant CommentNotifierProvider provider,
  ) {
    return call(provider.issueId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'commentNotifierProvider';
}

/// Notifier for managing comments on a specific issue.
///
/// Copied from [CommentNotifier].
class CommentNotifierProvider
    extends AutoDisposeNotifierProviderImpl<CommentNotifier, CommentState> {
  /// Notifier for managing comments on a specific issue.
  ///
  /// Copied from [CommentNotifier].
  CommentNotifierProvider(int issueId)
    : this._internal(
        () => CommentNotifier()..issueId = issueId,
        from: commentNotifierProvider,
        name: r'commentNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$commentNotifierHash,
        dependencies: CommentNotifierFamily._dependencies,
        allTransitiveDependencies:
            CommentNotifierFamily._allTransitiveDependencies,
        issueId: issueId,
      );

  CommentNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.issueId,
  }) : super.internal();

  final int issueId;

  @override
  CommentState runNotifierBuild(covariant CommentNotifier notifier) {
    return notifier.build(issueId);
  }

  @override
  Override overrideWith(CommentNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentNotifierProvider._internal(
        () => create()..issueId = issueId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        issueId: issueId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CommentNotifier, CommentState>
  createElement() {
    return _CommentNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentNotifierProvider && other.issueId == issueId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, issueId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommentNotifierRef on AutoDisposeNotifierProviderRef<CommentState> {
  /// The parameter `issueId` of this provider.
  int get issueId;
}

class _CommentNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<CommentNotifier, CommentState>
    with CommentNotifierRef {
  _CommentNotifierProviderElement(super.provider);

  @override
  int get issueId => (origin as CommentNotifierProvider).issueId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
