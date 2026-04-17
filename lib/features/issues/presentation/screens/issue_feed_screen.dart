import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mudda_frontend/features/issues/application/category_notifier.dart';
import 'package:mudda_frontend/features/issues/application/issue_list_notifier.dart';
import 'package:mudda_frontend/features/issues/presentation/widgets/issue_card.dart';
import 'package:mudda_frontend/features/community/presentation/screens/community_hub_screen.dart';
import 'package:mudda_frontend/shared/theme/app_colors.dart';

class IssueFeedScreen extends ConsumerStatefulWidget {
  const IssueFeedScreen({super.key});

  @override
  ConsumerState<IssueFeedScreen> createState() => _IssueFeedScreenState();
}

class _IssueFeedScreenState extends ConsumerState<IssueFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial data
    Future.microtask(() {
      ref.read(issueListNotifierProvider.notifier).loadInitialIssues();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(issueListNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final issueState = ref.watch(issueListNotifierProvider);
    final categoriesAsync = ref.watch(categoryNotifierProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: isDark ? AppColors.scaffoldBackgroundDark : AppColors.surface,
          bottom: TabBar(
            labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: "Global"),
              Tab(text: "Neighbourhood"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Global Context Tab
            Column(
              children: [
          // Category Filter
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: isDark ? AppColors.scaffoldBackgroundDark : AppColors.surface,
            child: categoriesAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, _) => Center(
                child: TextButton.icon(
                  onPressed: () =>
                      ref.read(categoryNotifierProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ),
              data: (categories) {
                final chipItems = <_CategoryChipItem>[
                  const _CategoryChipItem(name: 'All', id: null),
                  ...categories.map(
                    (c) => _CategoryChipItem(name: c.name, id: c.id),
                  ),
                ];

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: chipItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final chip = chipItems[index];
                    final isSelected = issueState.maybeMap(
                      loaded: (loaded) => loaded.category == chip.name,
                      orElse: () => chip.name == 'All',
                    );

                    return GestureDetector(
                      onTap: () => ref
                          .read(issueListNotifierProvider.notifier)
                          .filterByCategory(chip.name, categoryId: chip.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          color: isSelected
                              ? null
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : AppColors.scaffoldBackground),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? AppColors.borderDark : AppColors.border),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          chip.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Offline Banner
          issueState.maybeMap(
            loaded: (loaded) {
              if (!loaded.isOffline) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "You're offline — showing cached issues",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),

          // Issue List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(issueListNotifierProvider.notifier).refresh(),
              color: Theme.of(context).colorScheme.primary,
              child: issueState.when(
                initial: () => const SizedBox(),
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                error: (message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text('Error: $message'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(issueListNotifierProvider.notifier)
                            .refresh(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
                loaded: (issues, hasMore, currentCategory, isOffline) {
                  if (issues.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 64,
                            color: Theme.of(context).disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No issues found in "$currentCategory"',
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: issues.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == issues.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      final issue = issues[index];
                      return IssueCard(
                        issue: issue,
                        onTap: (selectedIssue) {
                          context.push(
                            '/issue/${selectedIssue.id}',
                            extra: selectedIssue,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // Neighborhood Context Tab
      const CommunityHubScreen(),
    ],
  ),
),
);
  }
}

/// Helper class to pair category name with its backend id.
class _CategoryChipItem {
  final String name;
  final int? id;

  const _CategoryChipItem({required this.name, this.id});
}
