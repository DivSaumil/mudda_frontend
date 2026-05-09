import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/hoa_models.dart';
import '../../data/repositories/mock_hoa_repository.dart';
import '../../../../../shared/theme/app_colors.dart';

class BudgetDashboardScreen extends StatefulWidget {
  const BudgetDashboardScreen({super.key});

  @override
  State<BudgetDashboardScreen> createState() => _BudgetDashboardScreenState();
}

class _BudgetDashboardScreenState extends State<BudgetDashboardScreen> {
  final _repo = MockHoaRepository();
  List<BudgetPeriod> _periods = [];
  int _selectedPeriodIdx = 0;
  bool _loading = true;
  int _touchedIndex = -1;

  final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.getBudgetPeriods();
    if (mounted) setState(() { _periods = data; _loading = false; });
  }

  BudgetPeriod get _current => _periods[_selectedPeriodIdx];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) return const Center(child: CircularProgressIndicator());

    final period = _current;
    final healthColor = period.overallUtilization > 1.0
        ? AppColors.error
        : period.overallUtilization > 0.85
            ? AppColors.warning
            : AppColors.success;
    final healthLabel = period.overallUtilization > 1.0
        ? 'Over Budget'
        : period.overallUtilization > 0.85
            ? 'Near Limit'
            : 'On Track';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Period selector ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(children: [
                  Text('Period:', style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600, fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  ..._periods.asMap().entries.map((e) => GestureDetector(
                    onTap: () => setState(() {
                      _selectedPeriodIdx = e.key;
                      _touchedIndex = -1;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: e.key == _selectedPeriodIdx
                            ? AppColors.primaryGradient : null,
                        color: e.key == _selectedPeriodIdx
                            ? null
                            : (isDark ? AppColors.surfaceDark : AppColors.surface),
                        borderRadius: BorderRadius.circular(24),
                        border: e.key == _selectedPeriodIdx
                            ? null
                            : Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.border),
                      ),
                      child: Text(e.value.label, style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: e.key == _selectedPeriodIdx
                              ? AppColors.textOnPrimary
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary))),
                    ),
                  )),
                ]),
              ),

              // ── Budget summary header ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppColors.headerGradientDark
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                        blurRadius: 20, offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(period.label, style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.8))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: healthColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: healthColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(healthLabel, style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_inr.format(period.totalSpentInr),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 32, fontWeight: FontWeight.w800,
                              color: AppColors.textOnPrimary)),
                      Text('spent of ${_inr.format(period.totalBudgetInr)}',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7))),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: period.overallUtilization.clamp(0, 1),
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        period.totalRemainingInr >= 0
                            ? '${_inr.format(period.totalRemainingInr)} remaining'
                            : '${_inr.format(-period.totalRemainingInr)} over budget',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              ),

              // ── Donut chart ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Text('Allocation Breakdown', style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800, fontSize: 15,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              ),
              SizedBox(
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                              } else {
                                _touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              }
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 3,
                        centerSpaceRadius: 55,
                        sections: _buildSections(period.categories),
                      ),
                    ),
                    if (_touchedIndex >= 0 &&
                        _touchedIndex < period.categories.length)
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(period.categories[_touchedIndex].name,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                            textAlign: TextAlign.center),
                        Text(_inr.format(period.categories[_touchedIndex].spentAmountInr),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 15, fontWeight: FontWeight.w800,
                                color: period.categories[_touchedIndex].color)),
                      ])
                    else
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('Total\nSpent',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                            textAlign: TextAlign.center),
                        Text(_inr.format(period.totalSpentInr),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      ]),
                  ],
                ),
              ),

              // ── Category list ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: period.categories.map((cat) =>
                      _CategoryRow(cat: cat, isDark: isDark, inrFormat: _inr)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<BudgetCategory> cats) {
    return cats.asMap().entries.map((e) {
      final cat = e.value;
      final isTouched = e.key == _touchedIndex;
      return PieChartSectionData(
        color: cat.color,
        value: cat.spentAmountInr,
        radius: isTouched ? 50 : 38,
        title: '',
        badgeWidget: isTouched
            ? Icon(cat.icon, color: Colors.white, size: 16)
            : null,
        badgePositionPercentageOffset: 0.95,
      );
    }).toList();
  }
}

class _CategoryRow extends StatelessWidget {
  final BudgetCategory cat;
  final bool isDark;
  final NumberFormat inrFormat;

  const _CategoryRow({required this.cat, required this.isDark, required this.inrFormat});

  @override
  Widget build(BuildContext context) {
    final over = cat.spentAmountInr > cat.allocatedAmountInr;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border),
          boxShadow: isDark
              ? null
              : [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(cat.icon, color: cat.color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(cat.name, style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700, fontSize: 13,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(inrFormat.format(cat.spentAmountInr),
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, fontSize: 13,
                        color: over ? AppColors.error : cat.color)),
                Text('of ${inrFormat.format(cat.allocatedAmountInr)}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              ]),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: cat.utilizationPercent.clamp(0, 1),
                minHeight: 6,
                backgroundColor:
                    isDark ? AppColors.borderDark : AppColors.shimmerBase,
                color: over ? AppColors.error : cat.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              over
                  ? '${_pct(cat.utilizationPercent)} used — ${inrFormat.format(-cat.remainingAmountInr)} over'
                  : '${_pct(cat.utilizationPercent)} used — ${inrFormat.format(cat.remainingAmountInr)} left',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: over
                      ? AppColors.error
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  String _pct(double v) => '${(v * 100).toStringAsFixed(0)}%';
}
