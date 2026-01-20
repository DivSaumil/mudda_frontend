import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudda_frontend/features/voting/application/vote_notifier.dart';

/// A reusable vote button widget that handles vote toggling with optimistic updates.
class VoteButton extends ConsumerWidget {
  final int issueId;
  final int initialCount;
  final bool initialHasVoted;

  const VoteButton({
    super.key,
    required this.issueId,
    required this.initialCount,
    required this.initialHasVoted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voteState = ref.watch(
      voteNotifierProvider(
        issueId,
        initialCount: initialCount,
        initialHasVoted: initialHasVoted,
      ),
    );

    return GestureDetector(
      onTap: voteState.isLoading
          ? null
          : () async {
              try {
                await ref
                    .read(
                      voteNotifierProvider(
                        issueId,
                        initialCount: initialCount,
                        initialHasVoted: initialHasVoted,
                      ).notifier,
                    )
                    .toggleVote();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Vote failed: $e')));
                }
              }
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            voteState.hasVoted ? Icons.pan_tool : Icons.pan_tool_outlined,
            size: 22,
            color: voteState.hasVoted
                ? Colors.deepPurple
                : Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            '${voteState.voteCount}',
            style: TextStyle(
              color: voteState.hasVoted
                  ? Colors.deepPurple
                  : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (voteState.isLoading) ...[
            const SizedBox(width: 4),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }
}
