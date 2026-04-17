import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/core/di/providers.dart';
import 'package:mudda_frontend/shared/theme/app_colors.dart';

class IssueCard extends ConsumerStatefulWidget {
  final IssueResponse issue;
  final Function(IssueResponse) onTap;

  const IssueCard({super.key, required this.issue, required this.onTap});

  @override
  ConsumerState<IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends ConsumerState<IssueCard>
    with TickerProviderStateMixin {
  bool _isVoting = false;
  late int _localLikes;
  late bool _hasVoted;

  // Micro-animation controllers
  late AnimationController _voteCtrl;
  late Animation<double> _voteScale;
  late AnimationController _entryCtrl;
  late Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _localLikes = widget.issue.voteCount;
    _hasVoted = widget.issue.hasUserVoted ?? false;

    // Vote bounce animation
    _voteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _voteScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _voteCtrl, curve: Curves.easeOut));

    // Entry slide-up animation
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(IssueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.issue.id != widget.issue.id) {
      _localLikes = widget.issue.voteCount;
      _hasVoted = widget.issue.hasUserVoted ?? false;
    }
  }

  @override
  void dispose() {
    _voteCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);
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

  Future<void> _handleVote() async {
    if (_isVoting) return;
    HapticFeedback.lightImpact();
    _voteCtrl.forward(from: 0);
    setState(() {
      _isVoting = true;
      if (_hasVoted) {
        _localLikes--;
        _hasVoted = false;
      } else {
        _localLikes++;
        _hasVoted = true;
      }
    });

    try {
      final voteRepository = ref.read(voteRepositoryProvider);
      if (_hasVoted) {
        await voteRepository.createVote(widget.issue.id);
      } else {
        await voteRepository.deleteVote(widget.issue.id);
      }
    } catch (e) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to vote: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  Color _getStatusColor(String status) {
    return AppColors.getStatusColor(status);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(widget.issue.status);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(_entryAnim),
      child: FadeTransition(
        opacity: _entryAnim,
        child: GestureDetector(
          onTap: () => widget.onTap(widget.issue),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark.withValues(alpha: 0.6)
                    : AppColors.border.withValues(alpha: 0.5),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildAvatar(isDark),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.issue.authorName,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _formatTimeAgo(widget.issue.createdAt),
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(statusColor),
                    ],
                  ),
                ),

                // ── Community badge ─────────────────────────────────────
                if (widget.issue.communityId != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_work_rounded,
                              size: 13, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text(
                            'Neighbourhood Local',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Issue Image ─────────────────────────────────────────
                if (widget.issue.firstImageUrl != null)
                  Hero(
                    tag: 'post_image_${widget.issue.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: Image.network(
                        widget.issue.firstImageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 140,
                          color: isDark
                              ? AppColors.surfaceElevatedDark
                              : AppColors.scaffoldBackground,
                          child: Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Content ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.issue.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.issue.content.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.issue.content,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // ── Official Response ──────────────────────────
                      if (widget.issue.officialResponse != null &&
                          widget.issue.officialResponse!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildOfficialResponse(isDark),
                      ],

                      const SizedBox(height: 14),

                      // ── Actions ────────────────────────────────────
                      Row(
                        children: [
                          _buildVoteButton(isDark),
                          const SizedBox(width: 20),
                          _buildActionButton(
                            isDark: isDark,
                            icon: Icons.chat_bubble_outline_rounded,
                            label: '${widget.issue.comments}',
                            onTap: () => widget.onTap(widget.issue),
                          ),
                          const Spacer(),
                          _buildShareButton(isDark),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: widget.issue.authorImageUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(widget.issue.authorImageUrl,
                  fit: BoxFit.cover))
          : Center(
              child: Text(
                widget.issue.authorName.isNotEmpty
                    ? widget.issue.authorName[0].toUpperCase()
                    : 'U',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
    );
  }

  Widget _buildStatusBadge(Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            widget.issue.status.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialResponse(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Official Response',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.issue.officialResponse!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(bool isDark) {
    return GestureDetector(
      onTap: _handleVote,
      child: AnimatedBuilder(
        animation: _voteScale,
        builder: (_, child) =>
            Transform.scale(scale: _voteScale.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: _hasVoted ? AppColors.primaryGradient : null,
            color: _hasVoted
                ? null
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.scaffoldBackground),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hasVoted
                  ? Colors.transparent
                  : (isDark ? AppColors.borderDark : AppColors.border),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _hasVoted ? Icons.pan_tool_rounded : Icons.pan_tool_outlined,
                size: 16,
                color: _hasVoted
                    ? Colors.white
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                '$_localLikes',
                style: GoogleFonts.plusJakartaSans(
                  color: _hasVoted
                      ? Colors.white
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(bool isDark) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 0.8,
          ),
        ),
        child: Icon(
          Icons.share_outlined,
          size: 16,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }
}
