import 'package:flutter/material.dart';
import '../../domain/entities/community_models.dart';
import '../../data/repositories/mock_community_repository.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';

class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> {
  final MockCommunityRepository _repo = MockCommunityRepository();

  Community? _community;
  List<CommunityInitiative> _initiatives = [];
  List<CommunityAnnouncement> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final comm = await _repo.getHub();
    if (comm != null) {
      final inits = await _repo.getInitiatives(comm.id);
      final ann = await _repo.getAnnouncements(comm.id);
      setState(() {
        _community = comm;
        _initiatives = inits;
        _announcements = ann;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_community == null) {
      return const Center(child: Text("Join a community to see the Neighborhood Hub."));
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Adaptive civic indigo — brighter in dark mode for contrast
    final Color civicIndigo = isDark
        ? const Color(0xFF818CF8) // indigo-400
        : const Color(0xFF4F46E5); // indigo-600

    // Adaptive surface for cards/containers
    final Color cardSurface = isDark ? cs.surface : Colors.white;
    final Color containerSurface = cs.surfaceContainerHighest;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ────────────────────────────────────────────────
          // 1. Map View Hero Section
          // ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              color: containerSurface,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(_community!.lat, _community!.lng),
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: isDark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: isDark ? const ['a', 'b', 'c', 'd'] : const [],
                    userAgentPackageName: 'com.example.mudda_frontend',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: LatLng(_community!.lat, _community!.lng),
                        color: civicIndigo.withValues(alpha: 0.15),
                        borderColor: civicIndigo.withValues(alpha: 0.6),
                        borderStrokeWidth: 2,
                        useRadiusInMeter: true,
                        radius: _community!.radiusKm * 1000,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_community!.lat, _community!.lng),
                        width: 40,
                        height: 40,
                        child: Icon(Icons.location_on, color: civicIndigo, size: 40),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ────────────────────────────────────────────────
          // 2. Title & Pulse Stats
          // ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _community!.name,
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _community!.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Neighborhood Pulse Stats
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        "Active Members",
                        "${_community!.memberCount}",
                        containerSurface,
                        civicIndigo,
                        cs,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(
                        "Issues Resolved",
                        "128",
                        containerSurface,
                        civicIndigo,
                        cs,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(
                        "Trust Score",
                        "92%",
                        containerSurface,
                        civicIndigo,
                        cs,
                      )),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ────────────────────────────────────────────────
          // 3. Official Announcements
          // ────────────────────────────────────────────────
          if (_announcements.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "City Hall Updates",
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    ..._announcements.map((a) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: containerSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: isDark
                                ? Border.all(color: cs.outlineVariant.withValues(alpha: 0.3))
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.campaign, color: civicIndigo, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      a.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                a.content,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

          // ────────────────────────────────────────────────
          // 4. Community Initiatives & Events
          // ────────────────────────────────────────────────
          if (_initiatives.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Community Initiatives & Events",
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, idx) {
                          final i = _initiatives[idx];
                          return GestureDetector(
                            onTap: () {
                              context.push(
                                AppRoutes.initiativeDetail.replaceFirst(':id', i.id),
                                extra: i,
                              );
                            },
                            child: Container(
                              width: 280,
                              decoration: BoxDecoration(
                                color: cardSurface,
                                borderRadius: BorderRadius.circular(16),
                                border: isDark
                                    ? Border.all(color: cs.outlineVariant.withValues(alpha: 0.3))
                                    : null,
                                boxShadow: isDark
                                    ? null
                                    : const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        )
                                      ],
                              ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (i.imageUrl != null)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      i.imageUrl!, 
                                      height: 100, 
                                      width: double.infinity, 
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 100,
                                          color: containerSurface,
                                          child: Icon(Icons.broken_image, color: cs.onSurfaceVariant),
                                        );
                                      },
                                    ),
                                  )
                                else
                                  Container(height: 100, color: civicIndigo.withValues(alpha: 0.1)),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        i.title,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      if (i.locationStr != null)
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 14, color: cs.onSurfaceVariant),
                                            const SizedBox(width: 4),
                                            Text(
                                              i.locationStr!,
                                              style: theme.textTheme.labelMedium?.copyWith(
                                                color: cs.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: civicIndigo,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () {
                                            context.push(
                                              AppRoutes.initiativeDetail.replaceFirst(':id', i.id),
                                              extra: i,
                                            );
                                          },
                                          child: Text(i.type == 'event' ? "RSVP" : "Pledge Donation"),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                        },
                        separatorBuilder: (c, i) => const SizedBox(width: 16),
                        itemCount: _initiatives.length,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color bgColor,
    Color accentColor,
    ColorScheme cs,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          )
        ],
      ),
    );
  }
}
