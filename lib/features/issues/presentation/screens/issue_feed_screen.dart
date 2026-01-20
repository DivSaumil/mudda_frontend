import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudda_frontend/features/issues/application/issue_list_notifier.dart';
import 'package:mudda_frontend/features/issues/presentation/widgets/issue_card.dart';

class IssueFeedScreen extends ConsumerStatefulWidget {
  const IssueFeedScreen({super.key});

  @override
  ConsumerState<IssueFeedScreen> createState() => _IssueFeedScreenState();
}

class _IssueFeedScreenState extends ConsumerState<IssueFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _categories = [
    'All',
    'Infrastructure',
    'Safety',
    'Environment',
    'Other',
  ];

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = issueState.maybeMap(
                  loaded: (loaded) => loaded.category == category,
                  orElse: () => category == 'All',
                );

                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(issueListNotifierProvider.notifier)
                          .filterByCategory(category);
                    }
                  },
                  selectedColor: Colors.deepPurple,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  side: isSelected
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade300),
                );
              },
            ),
          ),

          // Issue List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(issueListNotifierProvider.notifier).refresh(),
              color: Colors.deepPurple,
              child: issueState.when(
                initial: () => const SizedBox(),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.deepPurple),
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
                loaded: (issues, hasMore, currentCategory) {
                  if (issues.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No issues found in "$currentCategory"',
                            style: TextStyle(
                              color: Colors.grey.shade600,
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
                      // TODO: Implement navigation to detail screen
                      return IssueCard(
                        issue: issue,
                        onTap: (selectedIssue) {
                          // Placeholder for navigation
                          // Will implement routing in next steps
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Detail view coming soon!'),
                              duration: Duration(seconds: 1),
                            ),
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
