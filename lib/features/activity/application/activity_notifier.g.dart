// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activityNotifierHash() => r'a3f867b6fadfb4e23f458dfd851514c51d481d9d';

/// Notifier for managing user activity state.
/// Currently uses mock data - will be connected to activity API when available.
///
/// Copied from [ActivityNotifier].
@ProviderFor(ActivityNotifier)
final activityNotifierProvider =
    AutoDisposeNotifierProvider<ActivityNotifier, ActivityState>.internal(
      ActivityNotifier.new,
      name: r'activityNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activityNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActivityNotifier = AutoDisposeNotifier<ActivityState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
