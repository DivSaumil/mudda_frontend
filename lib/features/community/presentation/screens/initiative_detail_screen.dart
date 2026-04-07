import 'package:flutter/material.dart';
import '../../domain/entities/community_models.dart';
import 'package:intl/intl.dart';

class InitiativeDetailScreen extends StatelessWidget {
  final CommunityInitiative initiative;

  const InitiativeDetailScreen({
    super.key,
    required this.initiative,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isEvent = initiative.type == 'event';

    // Adaptive civic indigo — brighter in dark mode
    final civicIndigo = isDark
        ? const Color(0xFF818CF8) // indigo-400
        : const Color(0xFF4F46E5); // indigo-600

    // Adaptive surfaces
    final cardSurface = isDark ? cs.surface : Colors.white;
    final containerSurface = cs.surfaceContainerHighest;

    // Adaptive green for funding
    final fundingGreen = isDark
        ? const Color(0xFF4ADE80) // green-400
        : const Color(0xFF15803D); // green-700
    final progressBarColor = isDark
        ? const Color(0xFF22C55E) // green-500
        : const Color(0xFF16A34A); // green-600

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ────────────────────────────────────────────────
          // Hero Image AppBar
          // ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: initiative.imageUrl != null
                  ? Image.network(
                      initiative.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: civicIndigo.withValues(alpha: 0.2)),
                    )
                  : Container(
                      color: civicIndigo.withValues(alpha: isDark ? 0.15 : 0.1),
                      child: Icon(
                        isEvent ? Icons.event : Icons.volunteer_activism,
                        size: 80,
                        color: civicIndigo.withValues(alpha: 0.5),
                      ),
                    ),
              title: Text(
                initiative.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
            ),
            backgroundColor: isDark ? cs.surface : civicIndigo,
            foregroundColor: Colors.white,
          ),

          // ────────────────────────────────────────────────
          // Content
          // ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Badges (Type & Status) ──
                  Row(
                    children: [
                      _buildTypeBadge(isEvent, isDark),
                      const Spacer(),
                      if (initiative.hasUserRsvp || initiative.hasUserPledged)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: civicIndigo.withValues(alpha: isDark ? 0.25 : 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isEvent ? "RSVP'd" : "Pledged",
                            style: TextStyle(
                              color: civicIndigo,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Date & Location Info Row ──
                  Row(
                    children: [
                      // Date Box
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: containerSurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('MMM').format(initiative.date).toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              DateFormat('d').format(initiative.date),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: civicIndigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Time and Location
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: cs.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('EEEE, h:mm a').format(initiative.date),
                                  style: theme.textTheme.titleSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (initiative.locationStr != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on, size: 16, color: cs.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      initiative.locationStr!,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Fundraiser: Funding Progress ──
                  if (!isEvent && initiative.goalAmount != null && initiative.raisedAmount != null) ...[
                    Text(
                      "Funding Progress",
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark
                            ? cs.outlineVariant.withValues(alpha: 0.3)
                            : theme.dividerColor),
                        boxShadow: isDark
                            ? null
                            : const [
                                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "\$${initiative.raisedAmount!.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: fundingGreen,
                                ),
                              ),
                              Text(
                                "raised of \$${initiative.goalAmount!.toStringAsFixed(0)}",
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: initiative.raisedAmount! / initiative.goalAmount!,
                              minHeight: 12,
                              backgroundColor: isDark
                                  ? cs.surfaceContainerHighest
                                  : Colors.grey.shade200,
                              color: progressBarColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${((initiative.raisedAmount! / initiative.goalAmount!) * 100).toStringAsFixed(0)}% funded",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    // ── Event: Community Interest / RSVP Stats ──
                    Text(
                      "Community Interest",
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: containerSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: isDark
                            ? Border.all(color: cs.outlineVariant.withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardSurface,
                              shape: BoxShape.circle,
                              border: isDark
                                  ? Border.all(color: cs.outlineVariant.withValues(alpha: 0.2))
                                  : null,
                            ),
                            child: Icon(Icons.people, color: civicIndigo),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${initiative.rsvpCount} Neighbors Attending",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: civicIndigo,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Join them today!",
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // ── Description ──
                  Text(
                    "About This Initiative",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    initiative.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 100), // padding for bottom action bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: isDark
              ? Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)))
              : null,
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: civicIndigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEvent ? "RSVP Confirmed! See you there." : "Thank you for your pledge!"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                isEvent ? "RSVP Now" : "Pledge Donation",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(bool isEvent, bool isDark) {
    final Color badgeColor = isEvent
        ? const Color(0xFFF97316) // orange-500
        : const Color(0xFF22C55E); // green-500

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: badgeColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Text(
        isEvent ? "Community Event" : "Fundraiser",
        style: TextStyle(
          color: isDark ? badgeColor : (isEvent ? const Color(0xFF9A3412) : const Color(0xFF166534)),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
