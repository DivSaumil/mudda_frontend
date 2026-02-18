import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/api/models/comment_models.dart';
import 'package:mudda_frontend/core/di/providers.dart';
import 'package:mudda_frontend/features/issues/application/detail/issue_detail_notifier.dart';

class IssueDetailScreen extends ConsumerStatefulWidget {
  final int issueId;
  final IssueResponse? initialIssue;

  const IssueDetailScreen({
    super.key,
    required this.issueId,
    this.initialIssue,
  });

  @override
  ConsumerState<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends ConsumerState<IssueDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocus = FocusNode();
  List<CommentResponse> _comments = [];
  bool _commentsLoading = true;
  bool _isSubmittingComment = false;
  int _currentImageIndex = 0;

  // Vote state
  late int _localVoteCount;
  late bool _hasVoted;
  bool _isVoting = false;
  bool _voteInitialized = false;

  // Animations
  late AnimationController _voteAnimCtrl;
  late Animation<double> _voteBounce;

  @override
  void initState() {
    super.initState();
    _localVoteCount = 0;
    _hasVoted = false;
    _loadComments();

    _voteAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _voteBounce = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _voteAnimCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocus.dispose();
    _voteAnimCtrl.dispose();
    super.dispose();
  }

  void _syncVoteState(IssueResponse issue) {
    if (!_voteInitialized) {
      _localVoteCount = issue.voteCount;
      _hasVoted = issue.hasUserVoted;
      _voteInitialized = true;
    }
  }

  Future<void> _loadComments() async {
    try {
      final repo = ref.read(commentRepositoryProvider);
      final response = await repo.getCommentsByIssue(widget.issueId);
      if (mounted) {
        setState(() {
          _comments = response.comments;
          _commentsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _commentsLoading = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmittingComment) return;

    setState(() => _isSubmittingComment = true);
    try {
      final repo = ref.read(commentRepositoryProvider);
      final newComment = await repo.createComment(
        widget.issueId,
        CreateCommentRequest(content: text),
      );
      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
          _isSubmittingComment = false;
        });
        _commentController.clear();
        _commentFocus.unfocus();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmittingComment = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
      }
    }
  }

  Future<void> _handleVote() async {
    if (_isVoting) return;
    setState(() => _isVoting = true);
    _voteAnimCtrl.forward().then((_) => _voteAnimCtrl.reverse());

    final wasVoted = _hasVoted;
    setState(() {
      _hasVoted = !_hasVoted;
      _localVoteCount += _hasVoted ? 1 : -1;
    });

    try {
      final voteRepo = ref.read(voteRepositoryProvider);
      if (!wasVoted) {
        await voteRepo.createVote(widget.issueId);
      } else {
        await voteRepo.deleteVote(widget.issueId);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasVoted = wasVoted;
          _localVoteCount += wasVoted ? 1 : -1;
        });
      }
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  void _showPlaceholder(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return 'Recently';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Colors.orange;
      case 'SOLVED':
      case 'CLOSED':
        return Colors.green;
      case 'PENDING':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(
      issueDetailNotifierProvider(
        widget.issueId,
        initialIssue: widget.initialIssue,
      ),
    );
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (detailState.issue == null && detailState.isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (detailState.issue == null && detailState.error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 64,
                  color: theme.disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${detailState.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.hintColor),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => ref
                      .read(
                        issueDetailNotifierProvider(
                          widget.issueId,
                          initialIssue: widget.initialIssue,
                        ).notifier,
                      )
                      .refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (detailState.issue == null) {
      Future.microtask(
        () => ref
            .read(
              issueDetailNotifierProvider(
                widget.issueId,
                initialIssue: widget.initialIssue,
              ).notifier,
            )
            .fetchFullDetails(),
      );
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final issue = detailState.issue!;
    _syncVoteState(issue);
    final statusColor = _getStatusColor(issue.status);
    final hasImages = issue.mediaUrls.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Immersive App Bar ──
              SliverAppBar(
                expandedHeight: hasImages ? 340 : 0,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? cs.surface : cs.primary,
                foregroundColor: hasImages || isDark
                    ? Colors.white
                    : Colors.white,
                flexibleSpace: hasImages
                    ? FlexibleSpaceBar(
                        stretchModes: const [StretchMode.zoomBackground],
                        background: _buildImageCarousel(issue, isDark),
                      )
                    : null,
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Author row ──
                    _buildAuthorRow(issue, theme, cs, statusColor),

                    // ── Title ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        issue.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Description ──
                    if (issue.fullContent.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          issue.fullContent,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                            color: theme.textTheme.bodyLarge?.color?.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // ── Engagement bar ──
                    _buildEngagementBar(theme, cs, isDark),

                    const SizedBox(height: 8),

                    // ── Meta chips ──
                    _buildMetaChips(theme, cs, isDark),

                    // ── Divider ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Divider(color: theme.dividerColor),
                    ),

                    // ── Comments header ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.forum_rounded,
                            size: 20,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Discussion',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_comments.length}',
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Comment input ──
                    _buildCommentInput(theme, cs),
                    const SizedBox(height: 8),

                    // ── Comments list ──
                    _buildCommentsList(theme, cs, isDark),

                    // Bottom padding for floating action bar
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // IMAGE CAROUSEL
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildImageCarousel(IssueResponse issue, bool isDark) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: issue.mediaUrls.length,
          onPageChanged: (i) => setState(() => _currentImageIndex = i),
          itemBuilder: (context, index) {
            return Hero(
              tag: index == 0
                  ? 'post_image_${issue.id}'
                  : 'img_${issue.id}_$index',
              child: Image.network(
                issue.mediaUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, size: 48),
                  ),
                ),
              ),
            );
          },
        ),

        // Gradient overlay at bottom for readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),

        // Image counter badge
        Positioned(
          top: MediaQuery.of(context).padding.top + 56,
          right: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentImageIndex + 1}/${issue.mediaUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Animated dot indicators
        if (issue.mediaUrls.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                issue.mediaUrls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: _currentImageIndex == i ? 28 : 6,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: _currentImageIndex == i
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // AUTHOR ROW
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildAuthorRow(
    IssueResponse issue,
    ThemeData theme,
    ColorScheme cs,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Row(
        children: [
          // Avatar with gradient border
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withValues(alpha: 0.4)],
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: theme.cardColor,
              child: Text(
                issue.username.isNotEmpty
                    ? issue.username[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      issue.username,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.verified, size: 16, color: cs.primary),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatTimeAgo(issue.createdAt),
                      style: TextStyle(color: theme.hintColor, fontSize: 12.5),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  issue.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ENGAGEMENT BAR
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildEngagementBar(ThemeData theme, ColorScheme cs, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Vote button (highlighted)
          Expanded(
            child: ScaleTransition(
              scale: _voteBounce,
              child: _EngagementButton(
                icon: _hasVoted ? Icons.pan_tool : Icons.pan_tool_outlined,
                label: '$_localVoteCount',
                isActive: _hasVoted,
                activeColor: cs.primary,
                theme: theme,
                onTap: _handleVote,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Comment button
          Expanded(
            child: _EngagementButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: '${_comments.length}',
              theme: theme,
              onTap: () {
                _commentFocus.requestFocus();
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // Save button
          Expanded(
            child: _EngagementButton(
              icon: Icons.bookmark_outline_rounded,
              label: 'Save',
              theme: theme,
              onTap: () => _showPlaceholder('Bookmark'),
            ),
          ),
          const SizedBox(width: 8),

          // Share button
          Expanded(
            child: _EngagementButton(
              icon: Icons.share_outlined,
              label: 'Share',
              theme: theme,
              onTap: () => _showPlaceholder('Share'),
            ),
          ),
          const SizedBox(width: 8),

          // Report button
          Expanded(
            child: _EngagementButton(
              icon: Icons.flag_outlined,
              label: 'Report',
              theme: theme,
              onTap: () => _showPlaceholder('Report'),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // META CHIPS
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildMetaChips(ThemeData theme, ColorScheme cs, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _MetaChip(
            icon: Icons.location_on_outlined,
            label: 'Location',
            theme: theme,
            isDark: isDark,
            onTap: () => _showPlaceholder('Location details'),
          ),
          _MetaChip(
            icon: Icons.category_outlined,
            label: 'Category',
            theme: theme,
            isDark: isDark,
            onTap: () => _showPlaceholder('Category details'),
          ),
          _MetaChip(
            icon: Icons.warning_amber_rounded,
            label: 'Severity',
            theme: theme,
            isDark: isDark,
            onTap: () => _showPlaceholder('Severity details'),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // COMMENT INPUT
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildCommentInput(ThemeData theme, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primary.withValues(alpha: 0.15),
              child: Icon(Icons.person, size: 18, color: cs.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocus,
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submitComment(),
                style: theme.textTheme.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Write a comment...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            _isSubmittingComment
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.send_rounded, color: cs.primary),
                    iconSize: 20,
                    onPressed: _submitComment,
                    style: IconButton.styleFrom(
                      backgroundColor: cs.primary.withValues(alpha: 0.1),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // COMMENTS LIST
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildCommentsList(ThemeData theme, ColorScheme cs, bool isDark) {
    if (_commentsLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 40,
                  color: cs.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No comments yet',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Be the first to share your thoughts!',
                style: TextStyle(color: theme.hintColor, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return _CommentTile(
          comment: comment,
          theme: theme,
          colorScheme: cs,
          isDark: isDark,
          formatTimeAgo: _formatTimeAgo,
          onLike: () => _handleCommentLike(index),
          onReply: () => _showPlaceholder('Reply'),
        );
      },
    );
  }

  Future<void> _handleCommentLike(int index) async {
    final comment = _comments[index];
    try {
      final repo = ref.read(commentRepositoryProvider);
      if (comment.hasUserLiked) {
        final res = await repo.removeLike(comment.id);
        if (mounted) {
          setState(() {
            _comments[index] = CommentResponse(
              id: comment.id,
              issueId: comment.issueId,
              content: comment.content,
              parentCommentId: comment.parentCommentId,
              likes: res.likes,
              repliesCount: comment.repliesCount,
              createdAt: comment.createdAt,
              authorId: comment.authorId,
              hasUserLiked: false,
            );
          });
        }
      } else {
        final res = await repo.likeComment(comment.id);
        if (mounted) {
          setState(() {
            _comments[index] = CommentResponse(
              id: comment.id,
              issueId: comment.issueId,
              content: comment.content,
              parentCommentId: comment.parentCommentId,
              likes: res.likes,
              repliesCount: comment.repliesCount,
              createdAt: comment.createdAt,
              authorId: comment.authorId,
              hasUserLiked: true,
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to like comment: $e')));
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final ThemeData theme;
  final VoidCallback onTap;

  const _EngagementButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isActive ? activeColor! : theme.hintColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? effectiveColor.withValues(alpha: 0.4)
                  : theme.dividerColor,
            ),
            color: isActive
                ? effectiveColor.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: effectiveColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: effectiveColor,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.theme,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: theme.hintColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentResponse comment;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isDark;
  final String Function(String) formatTimeAgo;
  final VoidCallback onLike;
  final VoidCallback onReply;

  const _CommentTile({
    required this.comment,
    required this.theme,
    required this.colorScheme,
    required this.isDark,
    required this.formatTimeAgo,
    required this.onLike,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.6),
                  colorScheme.primary.withValues(alpha: 0.15),
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.cardColor,
              child: Text(
                'U',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Comment body
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                    : colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'User ${comment.authorId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatTimeAgo(comment.createdAt),
                        style: TextStyle(color: theme.hintColor, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    comment.content,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  // Actions
                  Row(
                    children: [
                      _CommentAction(
                        icon: comment.hasUserLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        label: '${comment.likes}',
                        color: comment.hasUserLiked
                            ? Colors.redAccent
                            : theme.hintColor,
                        onTap: onLike,
                      ),
                      const SizedBox(width: 16),
                      _CommentAction(
                        icon: Icons.reply_rounded,
                        label: 'Reply',
                        color: theme.hintColor,
                        onTap: onReply,
                      ),
                      if (comment.repliesCount > 0) ...[
                        const Spacer(),
                        Text(
                          '${comment.repliesCount} replies',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CommentAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
