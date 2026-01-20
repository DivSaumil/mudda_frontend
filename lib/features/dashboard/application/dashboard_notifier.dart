import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/core/di/providers.dart';

part 'dashboard_notifier.g.dart';

/// Statistics for the dashboard
class DashboardStats {
  final int totalIssues;
  final int resolvedIssues;
  final int pendingIssues;
  final int userContributions;

  const DashboardStats({
    this.totalIssues = 0,
    this.resolvedIssues = 0,
    this.pendingIssues = 0,
    this.userContributions = 0,
  });

  double get resolutionRate =>
      totalIssues > 0 ? (resolvedIssues / totalIssues) * 100 : 0;
}

/// State for dashboard
class DashboardState {
  final DashboardStats stats;
  final IssueClusterResponse? clusters;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.stats = const DashboardStats(),
    this.clusters,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    DashboardStats? stats,
    IssueClusterResponse? clusters,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      clusters: clusters ?? this.clusters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing dashboard state.
@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  DashboardState build() {
    Future.microtask(() => fetchDashboardData());
    return const DashboardState(isLoading: true);
  }

  Future<void> fetchDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(issueRepositoryProvider);

      // Fetch clusters
      final clusters = await repository.getClusters(5);

      // Calculate stats from clusters
      final allIssues = clusters.clusteredIssues;
      final resolved = allIssues
          .where(
            (i) =>
                i.status.toUpperCase() == 'SOLVED' ||
                i.status.toUpperCase() == 'CLOSED',
          )
          .length;
      final pending = allIssues
          .where((i) => i.status.toUpperCase() == 'PENDING')
          .length;

      state = state.copyWith(
        isLoading: false,
        clusters: clusters,
        stats: DashboardStats(
          totalIssues: allIssues.length,
          resolvedIssues: resolved,
          pendingIssues: pending,
          userContributions: 0, // TODO: Get from user API
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchDashboardData();
  }
}
