import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/hoa_models.dart';
import '../../data/repositories/mock_hoa_repository.dart';

class WorkHistoryScreen extends StatefulWidget {
  const WorkHistoryScreen({super.key});

  @override
  State<WorkHistoryScreen> createState() => _WorkHistoryScreenState();
}

class _WorkHistoryScreenState extends State<WorkHistoryScreen> {
  final _repo = MockHoaRepository();
  List<WorkOrder> _history = [];
  bool _loading = true;
  String _search = '';

  final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.getWorkHistory();
    if (mounted) setState(() { _history = data; _loading = false; });
  }

  List<WorkOrder> get _filtered {
    if (_search.isEmpty) return _history;
    final q = _search.toLowerCase();
    return _history.where((w) =>
        w.title.toLowerCase().contains(q) ||
        w.category.label.toLowerCase().contains(q) ||
        (w.assignedTo?.toLowerCase().contains(q) ?? false)).toList();
  }

  Map<String, List<WorkOrder>> get _grouped {
    final result = <String, List<WorkOrder>>{};
    for (final w in _filtered) {
      final key = w.completedAt != null
          ? DateFormat('MMMM yyyy').format(w.completedAt!)
          : 'Unknown';
      result.putIfAbsent(key, () => []).add(w);
    }
    return result;
  }

  double get _totalSpend =>
      _history.fold(0, (s, w) => s + (w.actualCostInr ?? w.estimatedCostInr));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) return const Center(child: CircularProgressIndicator());

    final grouped = _grouped;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _load,
        color: const Color(0xFF6366F1),
        child: CustomScrollView(
          slivers: [
            // ── Summary stats ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(children: [
                  _stat('${_history.length}', 'Jobs\nCompleted', const Color(0xFF6366F1), isDark),
                  const SizedBox(width: 12),
                  _stat(_inr.format(_totalSpend), 'Total\nSpent', const Color(0xFFEF4444), isDark),
                  const SizedBox(width: 12),
                  _stat(_inr.format(_totalSpend / (_history.isEmpty ? 1 : _history.length)),
                      'Avg. Cost\nper Job', const Color(0xFFF59E0B), isDark),
                ]),
              ),
            ),

            // ── Search bar ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: GoogleFonts.plusJakartaSans(
                      color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search history...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), size: 20),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ),

            if (grouped.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No results found')),
              )
            else
              ...grouped.entries.expand((entry) => [
                // Month header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(children: [
                      Text(entry.key, style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                      const SizedBox(width: 8),
                      Expanded(child: Divider(color: isDark
                          ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                    ]),
                  ),
                ),
                // Items for this month
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _HistoryTile(order: entry.value[i], isDark: isDark, inrFormat: _inr),
                    ),
                    childCount: entry.value.length,
                  ),
                ),
              ]),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(children: [
          Text(value, style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w800, color: color),
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.plusJakartaSans(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.75)),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final WorkOrder order;
  final bool isDark;
  final NumberFormat inrFormat;

  const _HistoryTile({required this.order, required this.isDark, required this.inrFormat});

  @override
  Widget build(BuildContext context) {
    final w = order;
    final completedStr = w.completedAt != null
        ? DateFormat('d MMM yyyy').format(w.completedAt!)
        : '—';
    final cost = w.actualCostInr ?? w.estimatedCostInr;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: isDark
            ? null
            : [const BoxShadow(color: Colors.black08, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(w.category.icon, color: const Color(0xFF22C55E), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.title, style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.check_circle_outline, size: 12, color: const Color(0xFF22C55E)),
                  const SizedBox(width: 4),
                  Text(completedStr, style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                  if (w.assignedTo != null) ...[
                    const SizedBox(width: 8),
                    Text('· ${w.assignedTo}', style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                  ],
                ]),
              ],
            ),
          ),
          Text(inrFormat.format(cost), style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800, fontSize: 14,
              color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))),
        ],
      ),
    );
  }
}
