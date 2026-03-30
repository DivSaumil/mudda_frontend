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
    final isEvent = initiative.type == 'event';
    final civicIndigo = const Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Hero Image AppBar
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
                      color: civicIndigo.withValues(alpha: 0.1),
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
            backgroundColor: civicIndigo,
            foregroundColor: Colors.white,
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges (Type & Status)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isEvent ? Colors.orange.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isEvent ? "Community Event" : "Fundraiser",
                          style: TextStyle(
                            color: isEvent ? Colors.orange.shade900 : Colors.green.shade900,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (initiative.hasUserRsvp || initiative.hasUserPledged)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: civicIndigo.withValues(alpha: 0.1),
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

                  // Date & Location Info Row
                  Row(
                    children: [
                      // Date Box
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF), // surface_container_low
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
                                color: theme.colorScheme.onSurfaceVariant,
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
                                Icon(Icons.access_time, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('EEEE, h:mm a').format(initiative.date),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (initiative.locationStr != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      initiative.locationStr!,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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

                  // Target/Goal Progress Section
                  if (!isEvent && initiative.goalAmount != null && initiative.raisedAmount != null) ...[
                    const Text(
                      "Funding Progress",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: const [
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
                                  color: Colors.green.shade700,
                                ),
                              ),
                              Text(
                                "raised of \$${initiative.goalAmount!.toStringAsFixed(0)}",
                                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: initiative.raisedAmount! / initiative.goalAmount!,
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade200,
                              color: Colors.green.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${((initiative.raisedAmount! / initiative.goalAmount!) * 100).toStringAsFixed(0)}% funded",
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    // RSVP Stats for Events
                    const Text(
                      "Community Interest",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
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
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Description
                  const Text(
                    "About This Initiative",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    initiative.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 100), // padding for bottom action bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32), // Add bottom safe area manually or rely on SafeArea
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: const [
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
}
