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
    // Design System Tokens
    final Color surfaceContainerLow = theme.colorScheme.surfaceContainerHighest; // Approximation
    final Color surface = theme.colorScheme.surface;
    final Color civicIndigo = const Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: surface,
      body: CustomScrollView(
        slivers: [
          // 1. Map View Hero Section
          SliverToBoxAdapter(
            child: Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.grey.shade200, // Fallback background
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(_community!.lat, _community!.lng),
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none, // Static display map
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.mudda_frontend',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: LatLng(_community!.lat, _community!.lng),
                        color: civicIndigo.withValues(alpha: 0.2),
                        borderColor: civicIndigo,
                        borderStrokeWidth: 2,
                        useRadiusInMeter: true,
                        radius: _community!.radiusKm * 1000, // convert km to meters
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

          // Title & Pulse Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _community!.name,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _community!.description,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Neighborhood Pulse Stats (Paper-on-stone style)
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("Active Members", "${_community!.memberCount}", surfaceContainerLow)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard("Issues Resolved", "128", surfaceContainerLow)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard("Trust Score", "92%", surfaceContainerLow)),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Official Announcements
          if (_announcements.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "City Hall Updates",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._announcements.map((a) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4FF), // surface_container_low
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.campaign, color: civicIndigo, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    a.title,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(a.content, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

          // Community Initiatives & Events
          if (_initiatives.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Community Initiatives & Events",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
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
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.broken_image, color: Colors.grey),
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
                                      Text(i.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16), maxLines: 1),
                                      const SizedBox(height: 4),
                                      if (i.locationStr != null)
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(i.locationStr!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

  Widget _buildStatCard(String title, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF), // surface_container_low
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4F46E5), // civicIndigo
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF464555), // on_surface_variant
            ),
          )
        ],
      ),
    );
  }
}
