// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$issueDetailNotifierHash() =>
    r'4d99b0d5871c047abbb060fe7f7d9877c3687e7c';

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

abstract class _$IssueDetailNotifier
    extends BuildlessAutoDisposeNotifier<IssueDetailState> {
  late final int issueId;
  late final IssueResponse? initialIssue;

  IssueDetailState build(int issueId, {IssueResponse? initialIssue});
}

/// Notifier for managing single issue detail state.
///
/// Copied from [IssueDetailNotifier].
@ProviderFor(IssueDetailNotifier)
const issueDetailNotifierProvider = IssueDetailNotifierFamily();

/// Notifier for managing single issue detail state.
///
/// Copied from [IssueDetailNotifier].
class IssueDetailNotifierFamily extends Family<IssueDetailState> {
  /// Notifier for managing single issue detail state.
  ///
  /// Copied from [IssueDetailNotifier].
  const IssueDetailNotifierFamily();

  /// Notifier for managing single issue detail state.
  ///
  /// Copied from [IssueDetailNotifier].
  IssueDetailNotifierProvider call(int issueId, {IssueResponse? initialIssue}) {
    return IssueDetailNotifierProvider(issueId, initialIssue: initialIssue);
  }

  @override
  IssueDetailNotifierProvider getProviderOverride(
    covariant IssueDetailNotifierProvider provider,
  ) {
    return call(provider.issueId, initialIssue: provider.initialIssue);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'issueDetailNotifierProvider';
}

/// Notifier for managing single issue detail state.
///
/// Copied from [IssueDetailNotifier].
class IssueDetailNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<IssueDetailNotifier, IssueDetailState> {
  /// Notifier for managing single issue detail state.
  ///
  /// Copied from [IssueDetailNotifier].
  IssueDetailNotifierProvider(int issueId, {IssueResponse? initialIssue})
    : this._internal(
        () => IssueDetailNotifier()
          ..issueId = issueId
          ..initialIssue = initialIssue,
        from: issueDetailNotifierProvider,
        name: r'issueDetailNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$issueDetailNotifierHash,
        dependencies: IssueDetailNotifierFamily._dependencies,
        allTransitiveDependencies:
            IssueDetailNotifierFamily._allTransitiveDependencies,
        issueId: issueId,
        initialIssue: initialIssue,
      );

  IssueDetailNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.issueId,
    required this.initialIssue,
  }) : super.internal();

  final int issueId;
  final IssueResponse? initialIssue;

  @override
  IssueDetailState runNotifierBuild(covariant IssueDetailNotifier notifier) {
    return notifier.build(issueId, initialIssue: initialIssue);
  }

  @override
  Override overrideWith(IssueDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: IssueDetailNotifierProvider._internal(
        () => create()
          ..issueId = issueId
          ..initialIssue = initialIssue,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        issueId: issueId,
        initialIssue: initialIssue,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<IssueDetailNotifier, IssueDetailState>
  createElement() {
    return _IssueDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IssueDetailNotifierProvider &&
        other.issueId == issueId &&
        other.initialIssue == initialIssue;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, issueId.hashCode);
    hash = _SystemHash.combine(hash, initialIssue.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IssueDetailNotifierRef
    on AutoDisposeNotifierProviderRef<IssueDetailState> {
  /// The parameter `issueId` of this provider.
  int get issueId;

  /// The parameter `initialIssue` of this provider.
  IssueResponse? get initialIssue;
}

class _IssueDetailNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          IssueDetailNotifier,
          IssueDetailState
        >
    with IssueDetailNotifierRef {
  _IssueDetailNotifierProviderElement(super.provider);

  @override
  int get issueId => (origin as IssueDetailNotifierProvider).issueId;
  @override
  IssueResponse? get initialIssue =>
      (origin as IssueDetailNotifierProvider).initialIssue;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
