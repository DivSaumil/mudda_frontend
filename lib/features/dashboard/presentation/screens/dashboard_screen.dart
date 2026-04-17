import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:mudda_frontend/features/issues/presentation/screens/create_issue_screen.dart';
import 'package:mudda_frontend/shared/theme/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  // Initial center (Gurugram coordinates)
  final LatLng _initialCenter = const LatLng(28.4595, 77.0266);
  double _currentZoom = 13.0;
  final MapController _mapController = MapController();

  // Mock analytics data
  final int _totalIssues = 1240;
  final int _solvedIssues = 892;

  final List<Map<String, dynamic>> _categoryStats = [
    {'label': 'Potholes', 'count': 450, 'color': const Color(0xFFF59E0B)},
    {'label': 'Garbage', 'count': 320, 'color': const Color(0xFF8B5CF6)},
    {'label': 'Lighting', 'count': 210, 'color': const Color(0xFF3B82F6)},
    {'label': 'Water', 'count': 150, 'color': const Color(0xFF10B981)},
  ];

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 40;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldBackgroundDark
          : AppColors.scaffoldBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildGradientHeader(isDark),
          ),

          // ── Analytics Flashcards ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 4),
              child: SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const PageScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(right: 12),
                      child: _buildResolutionCard(isDark),
                    ),
                    Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(right: 12),
                      child: _buildTopCategoriesCard(isDark),
                    ),
                    Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(right: 4),
                      child: _buildResponseTimeCard(isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Slide dots indicator ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Center(
              child: _buildSlideIndicator(isDark),
            ),
          ),

          // ── CTA Banner ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _buildCtaBanner(isDark),
            ),
          ),

          // ── Live Map section header ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: _buildSectionHeader('Live Issue Map', isDark),
            ),
          ),

          // ── Map ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildMap(isDark),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────

  Widget _buildGradientHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.headerGradientDark
            : AppColors.primaryGradient,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'City Dashboard',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.tune_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Gurugram, Haryana',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'City Health Overview',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          // Quick stat row
          Row(
            children: [
              _headerStat('$_totalIssues', 'Total Issues'),
              const SizedBox(width: 20),
              _headerStat('$_solvedIssues', 'Resolved'),
              const SizedBox(width: 20),
              _headerStat(
                  '${((_solvedIssues / _totalIssues) * 100).toInt()}%',
                  'Rate'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Analytics Cards ─────────────────────────────────────────────────────

  Widget _buildResolutionCard(bool isDark) {
    final pct = _solvedIssues / _totalIssues;
    return _analyticsCard(
      isDark: isDark,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Resolution Rate',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.successGradient.createShader(b),
                  child: Text(
                    '${(pct * 100).toInt()}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_solvedIssues issues resolved',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: SizedBox(
                height: 88,
                width: 88,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFE2E8F0),
                      strokeWidth: 10,
                    ),
                    CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(pct * 100).toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                          Text(
                            '%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesCard(bool isDark) {
    return _analyticsCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Issues',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'Total: $_totalIssues',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _categoryStats.take(3).map((cat) {
                final pct = (cat['count'] as int) / 500.0;
                final color = cat['color'] as Color;
                return Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        cat['label'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${cat['count']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTimeCard(bool isDark) {
    return _analyticsCard(
      isDark: isDark,
      gradient: AppColors.infoGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.timer_rounded, color: Colors.white, size: 22),
          ),
          const Spacer(),
          Text(
            '24 hrs',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          Text(
            'Avg Response Time',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.trending_down_rounded,
                  color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                '8% faster this month',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _analyticsCard({
    required bool isDark,
    required Widget child,
    Gradient? gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? (isDark ? AppColors.surfaceDark : AppColors.surface)
            : null,
        borderRadius: BorderRadius.circular(20),
        border: gradient == null
            ? Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 0.8)
            : null,
        boxShadow: [
          BoxShadow(
            color: gradient != null
                ? AppColors.info.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSlideIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == 0 ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: i == 0
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                      : AppColors.textSecondary.withValues(alpha: 0.2)),
            ),
          ),
        ),
      ),
    );
  }

  // ─── CTA Banner ──────────────────────────────────────────────────────────

  Widget _buildCtaBanner(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.ctaGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToCreateIssue,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spot an issue?',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Raise your voice — make it count',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: _recenter,
          icon: Icon(Icons.my_location_rounded,
              size: 14, color: AppColors.primary),
          label: Text(
            'Recenter',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  // ─── Map ─────────────────────────────────────────────────────────────────

  Widget _buildMap(bool isDark) {
    return Container(
      height: 440,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                        child: _buildMarker(issue),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            // Zoom Controls
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                children: [
                  _buildMapControlBtn(Icons.add_rounded, _zoomIn),
                  const SizedBox(height: 6),
                  _buildMapControlBtn(Icons.remove_rounded, _zoomOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControlBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }

  Widget _buildMarker(MapIssueData issue) {
    Color color;
    LinearGradient grad;
    switch (issue.severity) {
      case 'High':
        color = AppColors.error;
        grad = const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)]);
        break;
      case 'Medium':
        color = AppColors.warning;
        grad = const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
        break;
      default:
        color = AppColors.success;
        grad = const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)]);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: grad,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${issue.totalIssues}',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ─── Area Details Sheet ──────────────────────────────────────────────────

  void _showAreaDetails(BuildContext context, MapIssueData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 0.8,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
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
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Last updated: 2m ago',
                        style: GoogleFonts.plusJakartaSans(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color:
                          _getSeverityColor(data.severity).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _getSeverityColor(data.severity)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      data.severity.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        color: _getSeverityColor(data.severity),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailBox(
                        isDark, 'Top Issue', data.topIssue,
                        Icons.warning_amber_rounded, AppColors.warning),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailBox(
                        isDark, 'Total', '${data.totalIssues}',
                        Icons.assignment_rounded, AppColors.info),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'View Detailed Report',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailBox(bool isDark, String label, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.08)
            : color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }
}

class MapIssueData {
  final LatLng position;
  final String areaName;
  final int totalIssues;
  final String topIssue;
  final String severity;

  const MapIssueData({
    required this.position,
    required this.areaName,
    required this.totalIssues,
    required this.topIssue,
    required this.severity,
  });
}
