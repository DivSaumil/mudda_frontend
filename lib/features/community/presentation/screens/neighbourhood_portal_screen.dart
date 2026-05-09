import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/theme/app_colors.dart';
import 'community_hub_screen.dart';
import 'grievance_board_screen.dart';
import 'work_order_board_screen.dart';
import 'work_history_screen.dart';
import 'budget_dashboard_screen.dart';
import 'ledger_screen.dart';

class NeighbourhoodPortalScreen extends StatefulWidget {
  const NeighbourhoodPortalScreen({super.key});

  @override
  State<NeighbourhoodPortalScreen> createState() =>
      _NeighbourhoodPortalScreenState();
}

class _NeighbourhoodPortalScreenState extends State<NeighbourhoodPortalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    _PortalTab(icon: Icons.holiday_village_rounded, label: 'Hub'),
    _PortalTab(icon: Icons.report_problem_rounded, label: 'Grievances'),
    _PortalTab(icon: Icons.checklist_rounded, label: 'Work'),
    _PortalTab(icon: Icons.history_rounded, label: 'History'),
    _PortalTab(icon: Icons.pie_chart_rounded, label: 'Budget'),
    _PortalTab(icon: Icons.receipt_long_rounded, label: 'Ledger'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Custom scrollable pill tab bar ──────────────────────────────────
        Container(
          color: isDark ? AppColors.scaffoldBackgroundDark : AppColors.surface,
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  labelColor: AppColors.textOnPrimary,
                  unselectedLabelColor: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  tabs: _tabs.map((t) => _buildTab(t)).toList(),
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? AppColors.borderDark.withValues(alpha: 0.5)
                    : AppColors.border.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),

        // ── Tab content ─────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              CommunityHubScreen(),
              GrievanceBoardScreen(),
              WorkOrderBoardScreen(),
              WorkHistoryScreen(),
              BudgetDashboardScreen(),
              LedgerScreen(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(_PortalTab t) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(t.icon, size: 15),
            const SizedBox(width: 5),
            Text(t.label),
          ],
        ),
      ),
    );
  }
}

class _PortalTab {
  final IconData icon;
  final String label;
  const _PortalTab({required this.icon, required this.label});
}
