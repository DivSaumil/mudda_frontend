import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudda_frontend/features/issues/application/category_notifier.dart';
import 'package:mudda_frontend/features/issues/application/issue_list_notifier.dart';
import 'package:mudda_frontend/features/issues/presentation/widgets/issue_card.dart';

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Theme.of(context).cardColor,
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
                // Build chip list: "All" + backend categories
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

                    return ChoiceChip(
                      label: Text(chip.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(issueListNotifierProvider.notifier)
                              .filterByCategory(chip.name, categoryId: chip.id);
                        }
                      },
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).cardColor,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                      side: isSelected
                          ? BorderSide.none
                          : BorderSide(color: Theme.of(context).dividerColor),
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
                color: Colors.amber.shade800,
                child: const Row(
                  children: [
                    Icon(Icons.cloud_off, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "You're offline — showing cached issues",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
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
    );
  }
}

/// Helper class to pair category name with its backend id.
class _CategoryChipItem {
  final String name;
  final int? id;

  const _CategoryChipItem({required this.name, this.id});
}
