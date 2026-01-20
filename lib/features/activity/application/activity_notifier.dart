import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_notifier.g.dart';

/// Represents a single activity item
class ActivityItem {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? imageUrl;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.imageUrl,
  });
}

/// State for activity feed
class ActivityState {
  final List<ActivityItem> activities;
  final bool isLoading;
  final String? error;

  const ActivityState({
    this.activities = const [],
    this.isLoading = false,
    this.error,
  });

  ActivityState copyWith({
    List<ActivityItem>? activities,
    bool? isLoading,
    String? error,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing user activity state.
/// Currently uses mock data - will be connected to activity API when available.
@riverpod
class ActivityNotifier extends _$ActivityNotifier {
  @override
  ActivityState build() {
    Future.microtask(() => fetchActivities());
    return const ActivityState(isLoading: true);
  }

  Future<void> fetchActivities() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with actual API call when activity endpoint is available
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data for now
      final mockActivities = [
        ActivityItem(
          id: '1',
          type: 'issue_created',
          title: 'Created Issue',
          description: 'You created a new issue about road safety',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ActivityItem(
          id: '2',
          type: 'comment_posted',
          title: 'Commented',
          description: 'You commented on "Pothole on Main Street"',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ActivityItem(
          id: '3',
          type: 'vote_cast',
          title: 'Voted',
          description: 'You supported "Street Light Repair"',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      state = state.copyWith(isLoading: false, activities: mockActivities);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchActivities();
  }
}
