// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voteNotifierHash() => r'457f028cc89660c711fb5229eaefb50a7b0ec303';

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

abstract class _$VoteNotifier extends BuildlessAutoDisposeNotifier<VoteState> {
  late final int issueId;
  late final int initialCount;
  late final bool initialHasVoted;

  VoteState build(
    int issueId, {
    required int initialCount,
    required bool initialHasVoted,
  });
}

/// Notifier for managing votes on a specific issue.
/// Uses optimistic updates for better UX.
///
/// Copied from [VoteNotifier].
@ProviderFor(VoteNotifier)
const voteNotifierProvider = VoteNotifierFamily();

/// Notifier for managing votes on a specific issue.
/// Uses optimistic updates for better UX.
///
/// Copied from [VoteNotifier].
class VoteNotifierFamily extends Family<VoteState> {
  /// Notifier for managing votes on a specific issue.
  /// Uses optimistic updates for better UX.
  ///
  /// Copied from [VoteNotifier].
  const VoteNotifierFamily();

  /// Notifier for managing votes on a specific issue.
  /// Uses optimistic updates for better UX.
  ///
  /// Copied from [VoteNotifier].
  VoteNotifierProvider call(
    int issueId, {
    required int initialCount,
    required bool initialHasVoted,
  }) {
    return VoteNotifierProvider(
      issueId,
      initialCount: initialCount,
      initialHasVoted: initialHasVoted,
    );
  }

  @override
  VoteNotifierProvider getProviderOverride(
    covariant VoteNotifierProvider provider,
  ) {
    return call(
      provider.issueId,
      initialCount: provider.initialCount,
      initialHasVoted: provider.initialHasVoted,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'voteNotifierProvider';
}

/// Notifier for managing votes on a specific issue.
/// Uses optimistic updates for better UX.
///
/// Copied from [VoteNotifier].
class VoteNotifierProvider
    extends AutoDisposeNotifierProviderImpl<VoteNotifier, VoteState> {
  /// Notifier for managing votes on a specific issue.
  /// Uses optimistic updates for better UX.
  ///
  /// Copied from [VoteNotifier].
  VoteNotifierProvider(
    int issueId, {
    required int initialCount,
    required bool initialHasVoted,
  }) : this._internal(
         () => VoteNotifier()
           ..issueId = issueId
           ..initialCount = initialCount
           ..initialHasVoted = initialHasVoted,
         from: voteNotifierProvider,
         name: r'voteNotifierProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$voteNotifierHash,
         dependencies: VoteNotifierFamily._dependencies,
         allTransitiveDependencies:
             VoteNotifierFamily._allTransitiveDependencies,
         issueId: issueId,
         initialCount: initialCount,
         initialHasVoted: initialHasVoted,
       );

  VoteNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.issueId,
    required this.initialCount,
    required this.initialHasVoted,
  }) : super.internal();

  final int issueId;
  final int initialCount;
  final bool initialHasVoted;

  @override
  VoteState runNotifierBuild(covariant VoteNotifier notifier) {
    return notifier.build(
      issueId,
      initialCount: initialCount,
      initialHasVoted: initialHasVoted,
    );
  }

  @override
  Override overrideWith(VoteNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: VoteNotifierProvider._internal(
        () => create()
          ..issueId = issueId
          ..initialCount = initialCount
          ..initialHasVoted = initialHasVoted,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        issueId: issueId,
        initialCount: initialCount,
        initialHasVoted: initialHasVoted,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<VoteNotifier, VoteState> createElement() {
    return _VoteNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VoteNotifierProvider &&
        other.issueId == issueId &&
        other.initialCount == initialCount &&
        other.initialHasVoted == initialHasVoted;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, issueId.hashCode);
    hash = _SystemHash.combine(hash, initialCount.hashCode);
    hash = _SystemHash.combine(hash, initialHasVoted.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VoteNotifierRef on AutoDisposeNotifierProviderRef<VoteState> {
  /// The parameter `issueId` of this provider.
  int get issueId;

  /// The parameter `initialCount` of this provider.
  int get initialCount;

  /// The parameter `initialHasVoted` of this provider.
  bool get initialHasVoted;
}

class _VoteNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<VoteNotifier, VoteState>
    with VoteNotifierRef {
  _VoteNotifierProviderElement(super.provider);

  @override
  int get issueId => (origin as VoteNotifierProvider).issueId;
  @override
  int get initialCount => (origin as VoteNotifierProvider).initialCount;
  @override
  bool get initialHasVoted => (origin as VoteNotifierProvider).initialHasVoted;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
