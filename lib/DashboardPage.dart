import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mudda_frontend/CreatePost.dart'; // Import to navigate to Create Issue

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Initial center (Gurugram coordinates example)
  final LatLng _initialCenter = const LatLng(28.4595, 77.0266);
  double _currentZoom = 13.0;
  final MapController _mapController = MapController();

  // Changed viewportFraction to 0.85 for a wider peek at the next card
  final PageController _pageController = PageController(viewportFraction: 0.85);

  // Mock Data for Analytics
  final int _totalIssues = 1240;
  final int _solvedIssues = 892;
  final int _pendingIssues = 348;

  // Mock Data for Categories
  final List<Map<String, dynamic>> _categoryStats = [
    {'label': 'Potholes', 'count': 450, 'color': Colors.orange},
    {'label': 'Garbage', 'count': 320, 'color': Colors.brown},
    {'label': 'Lighting', 'count': 210, 'color': Colors.yellow.shade700},
    {'label': 'Water', 'count': 150, 'color': Colors.blue},
  ];

  // Mock Data for Map Markers
  final List<MapIssueData> _areaIssues = [
    MapIssueData(
      position: const LatLng(28.4620, 77.0280),
      areaName: "Sector 29",
      totalIssues: 15,
      topIssue: "Broken Streetlights",
      severity: "High",
    ),
    MapIssueData(
      position: const LatLng(28.4550, 77.0200),
      areaName: "Cyber Hub",
      totalIssues: 8,
      topIssue: "Illegal Parking",
      severity: "Medium",
    ),
    MapIssueData(
      position: const LatLng(28.4650, 77.0350),
      areaName: "MG Road",
      totalIssues: 25,
      topIssue: "Potholes",
      severity: "High",
    ),
    MapIssueData(
      position: const LatLng(28.4500, 77.0300),
      areaName: "Golf Course Ext",
      totalIssues: 3,
      topIssue: "Garbage Dump",
      severity: "Low",
    ),
  ];

  void _zoomIn() {
    setState(() {
      _currentZoom++;
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom--;
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _recenter() {
    _mapController.move(_initialCenter, 13.0);
    setState(() => _currentZoom = 13.0);
  }

  void _navigateToCreateIssue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateIssuePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "City Dashboard",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filters
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 1. Swipable Flashcards Section
            SizedBox(
              height: 240,
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                // padEnds: false ALIGNS the first card to the left,
                // revealing the second card on the right.
                padEnds: false,
                children: [
                  // Card 1: Resolution Rate
                  // Added Padding to the builder so the first card isn't stuck to the edge
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                    child: _buildAnalyticsCard(
                      child: _buildResolutionRate(),
                    ),
                  ),

                  // Card 2: Top Issues
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildAnalyticsCard(
                      child: _buildTopCategories(),
                    ),
                  ),

                  // Card 3: Quick Stats
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                    child: _buildAnalyticsCard(
                      color: Colors.blue.shade600,
                      child: _buildQuickStat(
                        "Avg Response",
                        "24 hrs",
                        Icons.timer,
                        textColor: Colors.white,
                        subtextColor: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. "Raise Your Voice" Call to Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.redAccent.shade200, Colors.redAccent.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _navigateToCreateIssue,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Spot an issue?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Raise your voice now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  const Text(
                    "Live Issue Map",
                    style: TextStyle(
                      fontSize: 18, // Slightly larger
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _recenter,
                    child: Text(
                      "Recenter",
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Map Section (Fixed Height)
            Container(
              height: 450, // Fixed generous height
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialCenter,
                        initialZoom: _currentZoom,
                        // Prevent map from intercepting page scroll unless interacting
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.mudda_frontend',
                        ),
                        MarkerLayer(
                          markers: _areaIssues.map((issue) {
                            return Marker(
                              point: issue.position,
                              width: 60,
                              height: 60,
                              child: GestureDetector(
                                onTap: () => _showAreaDetails(context, issue),
                                child: _buildAnimatedMarker(issue.totalIssues, issue.severity),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // Zoom Controls
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Column(
                        children: [
                          _buildMapControlBtn(Icons.add, _zoomIn),
                          const SizedBox(height: 8),
                          _buildMapControlBtn(Icons.remove, _zoomOut),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildAnalyticsCard({
    required Widget child,
    Color color = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: color == Colors.white
            ? Border.all(color: Colors.grey.shade200)
            : null,
      ),
      child: child,
    );
  }

  Widget _buildResolutionRate() {
    double percentage = _solvedIssues / _totalIssues;
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Resolution Rate",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                "${(percentage * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 36, // Larger font
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$_solvedIssues Issues Solved",
                style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  color: Colors.grey.shade100,
                  strokeWidth: 10,
                ),
                CircularProgressIndicator(
                  value: percentage,
                  color: Colors.greenAccent.shade700,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Top Issues",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            Text(
              "Total: $_totalIssues",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _categoryStats.take(3).map((cat) {
              double percent = cat['count'] / 500; // Mock max base
              return Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (cat['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.circle, size: 12, color: cat['color']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Text(
                      cat['label'],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(cat['color']),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${cat['count']}",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                  ),
                ],
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon,
      {Color textColor = Colors.black, Color subtextColor = Colors.grey}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: textColor, size: 24),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: subtextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMapControlBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildAnimatedMarker(int count, String severity) {
    Color color;
    switch (severity) {
      case 'High':
        color = Colors.redAccent;
        break;
      case 'Medium':
        color = Colors.orangeAccent;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "$count",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- Bottom Sheet Logic ---

  void _showAreaDetails(BuildContext context, MapIssueData data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.areaName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Last updated: 2m ago",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(data.severity).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data.severity.toUpperCase(),
                      style: TextStyle(
                        color: _getSeverityColor(data.severity),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailBox(
                        "Top Issue", data.topIssue, Icons.warning_amber, Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailBox(
                        "Total", "${data.totalIssues}", Icons.assignment, Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Optionally navigate to filtered list here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text("View Detailed Report"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      default:
        return Colors.green;
    }
  }
}

class MapIssueData {
  final LatLng position;
  final String areaName;
  final int totalIssues;
  final String topIssue;
  final String severity;

  MapIssueData({
    required this.position,
    required this.areaName,
    required this.totalIssues,
    required this.topIssue,
    required this.severity,
  });
}