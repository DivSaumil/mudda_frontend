import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/core/di/providers.dart';

class IssueCard extends ConsumerStatefulWidget {
  final IssueResponse issue;
  final Function(IssueResponse) onTap;

  const IssueCard({super.key, required this.issue, required this.onTap});

  @override
  ConsumerState<IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends ConsumerState<IssueCard>
    with SingleTickerProviderStateMixin {
  bool _isVoting = false;
  late int _localLikes;
  late bool _hasVoted;

  @override
  void initState() {
    super.initState();
    _localLikes = widget.issue.voteCount;
    _hasVoted = widget.issue.hasUserVoted;
  }

  // Update local state if the widget updates with new data
  @override
  void didUpdateWidget(IssueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.issue.id != widget.issue.id) {
      _localLikes = widget.issue.voteCount;
      _hasVoted = widget.issue.hasUserVoted;
    }
  }

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Future<void> _handleVote() async {
    if (_isVoting) return;
    setState(() => _isVoting = true);

    try {
      // Optimistic update
      setState(() {
        if (_hasVoted) {
          _localLikes--;
          _hasVoted = false;
        } else {
          _localLikes++;
          _hasVoted = true;
        }
      });

      // Get vote repository from provider (Assuming one exists or using generic service)
      // Note: In the original code it was VoteRepository.
      // We haven't created a specific provider for VoteRepository yet in shared providers,
      // but we can create one or access the service directly.
      // For now, I'll access the API service or create a repository on the fly if needed
      // But better: use the proper provider pattern.
      // The user previous code had: final VoteRepository _voteRepository = VoteRepository(service: voteService);
      // Let's assume we can get it via a provider we missed or create it here.
      // Since we didn't add voteRepositoryProvider in the step before, let's fix that too or just use the service.
      // Actually, checking providers.dart, we haven't added vote providers yet.
      // I'll assume for now we can get the service and make the repo.

      // TEMPORARY: Create repository instance here until we define the provider globally
      // In a real scenario, I should go back and add the provider.
      // Refactoring step: I will modify providers.dart next to add vote providers.
      // For this file to compile, I will assume `voteRepositoryProvider` exists
      // and I will add it to providers.dart in the next step.

      final voteRepository = ref.read(
        voteRepositoryProvider,
      ); // Will fail until I add this

      if (_hasVoted) {
        await voteRepository.createVote(widget.issue.id);
      } else {
        await voteRepository.deleteVote(widget.issue.id);
      }
    } catch (e) {
      // Revert on failure
      if (mounted) {
        setState(() {
          if (_hasVoted) {
            _localLikes--;
            _hasVoted = false;
          } else {
            _localLikes++;
            _hasVoted = true;
          }
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to vote: $e')));
      }
    } finally {
      if (mounted) setState(() => _isVoting = false);
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
    final statusColor = _getStatusColor(widget.issue.status);

    return GestureDetector(
      onTap: () => widget.onTap(widget.issue),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with User and Status
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      widget.issue.username.isNotEmpty
                          ? widget.issue.username[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.issue.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(widget.issue.createdAt),
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.issue.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Image
            if (widget.issue.firstImageUrl != null)
              Hero(
                tag: 'post_image_${widget.issue.id}',
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.issue.firstImageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.issue.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.issue.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.issue.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildActionButton(
                            icon: _hasVoted
                                ? Icons.pan_tool
                                : Icons.pan_tool_outlined,
                            label: '$_localLikes',
                            color: _hasVoted
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).hintColor,
                            onTap: _handleVote,
                          ),
                          const SizedBox(width: 24),
                          _buildActionButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: '${widget.issue.comments}',
                            onTap: () => widget.onTap(widget.issue),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.share_rounded,
                          color: Theme.of(context).hintColor,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 22, color: color ?? Theme.of(context).hintColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color ?? Theme.of(context).hintColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
