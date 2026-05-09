import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/hoa_models.dart';
import '../../data/repositories/mock_hoa_repository.dart';

class GrievanceBoardScreen extends StatefulWidget {
  const GrievanceBoardScreen({super.key});

  @override
  State<GrievanceBoardScreen> createState() => _GrievanceBoardScreenState();
}

class _GrievanceBoardScreenState extends State<GrievanceBoardScreen> {
  final _repo = MockHoaRepository();
  List<Grievance> _all = [];
  bool _loading = true;
  GrievanceCategory? _filterCategory;

  static const _civicIndigo = Color(0xFF6366F1);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.getGrievances();
    if (mounted) setState(() { _all = data; _loading = false; });
  }

  List<Grievance> get _filtered => _filterCategory == null
      ? _all
      : _all.where((g) => g.category == _filterCategory).toList();

  List<Grievance> _byStatus(GrievanceStatus s) =>
      _filtered.where((g) => g.status == s).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _load,
        color: _civicIndigo,
        child: CustomScrollView(
          slivers: [
            // ── Stats Strip ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    _statChip('${_byStatus(GrievanceStatus.open).length}', 'Open',
                        const Color(0xFFEF4444), isDark),
                    const SizedBox(width: 8),
                    _statChip('${_byStatus(GrievanceStatus.inProgress).length}',
                        'In Progress', const Color(0xFFF59E0B), isDark),
                    const SizedBox(width: 8),
                    _statChip('${_byStatus(GrievanceStatus.resolved).length}',
                        'Resolved', const Color(0xFF22C55E), isDark),
                  ],
                ),
              ),
            ),

            // ── Category Filter ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip(null, 'All', isDark, cs),
                    ...GrievanceCategory.values.map(
                      (c) => _filterChip(c, c.label, isDark, cs),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ── Kanban columns (vertical stacked) ────────────────────────────
            _sectionHeader('🔴  Open', const Color(0xFFEF4444), isDark),
            ..._kanbanCards(_byStatus(GrievanceStatus.open), isDark, cs),

            _sectionHeader('🟡  In Progress', const Color(0xFFF59E0B), isDark),
            ..._kanbanCards(_byStatus(GrievanceStatus.inProgress), isDark, cs),

            _sectionHeader('🟢  Resolved', const Color(0xFF22C55E), isDark),
            ..._kanbanCards(_byStatus(GrievanceStatus.resolved), isDark, cs),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _civicIndigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Report Issue', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        onPressed: () => _showSubmitSheet(context, isDark, cs),
      ),
    );
  }

  // ── Kanban cards ───────────────────────────────────────────────────────────

  SliverToBoxAdapter _sectionHeader(String title, Color color, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: Row(
          children: [
            Text(title, style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800, fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            )),
            const SizedBox(width: 8),
            Container(width: 40, height: 2, color: color.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  List<SliverToBoxAdapter> _kanbanCards(
      List<Grievance> items, bool isDark, ColorScheme cs) {
    if (items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('None',
                style: GoogleFonts.plusJakartaSans(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    fontSize: 13)),
          ),
        )
      ];
    }
    return items
        .map((g) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _GrievanceCard(
                  grievance: g,
                  isDark: isDark,
                  cs: cs,
                  onTap: () => _showDetailSheet(context, g, isDark, cs),
                ),
              ),
            ))
        .toList();
  }

  // ── Filter chip ────────────────────────────────────────────────────────────

  Widget _filterChip(GrievanceCategory? cat, String label, bool isDark, ColorScheme cs) {
    final selected = _filterCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _filterCategory = cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
              : null,
          color: selected ? null : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          cat != null ? '${String.fromCharCode(cat.icon.codePoint)} $label' : label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  // ── Stat chip ──────────────────────────────────────────────────────────────

  Widget _statChip(String count, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(count, style: GoogleFonts.plusJakartaSans(
              fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: GoogleFonts.plusJakartaSans(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }

  // ── Submit grievance sheet ─────────────────────────────────────────────────

  void _showSubmitSheet(BuildContext ctx, bool isDark, ColorScheme cs) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    GrievanceCategory selectedCat = GrievanceCategory.other;
    GrievancePriority selectedPriority = GrievancePriority.medium;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bCtx) => StatefulBuilder(
        builder: (bCtx, setSS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(bCtx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Report a Grievance', style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
              const SizedBox(height: 16),
              _sheetField(titleCtrl, 'Title', 'e.g. Water leak in corridor', isDark),
              const SizedBox(height: 10),
              _sheetField(descCtrl, 'Description', 'Describe the issue...', isDark, maxLines: 3),
              const SizedBox(height: 10),
              // Category dropdown
              DropdownButtonFormField<GrievanceCategory>(
                initialValue: selectedCat,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                decoration: _inputDecoration('Category', isDark),
                items: GrievanceCategory.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (v) => setSS(() => selectedCat = v!),
                style: GoogleFonts.plusJakartaSans(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<GrievancePriority>(
                initialValue: selectedPriority,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                decoration: _inputDecoration('Priority', isDark),
                items: GrievancePriority.values
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                    .toList(),
                onChanged: (v) => setSS(() => selectedPriority = v!),
                style: GoogleFonts.plusJakartaSans(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _civicIndigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final g = Grievance(
                      id: 'grv-${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      category: selectedCat,
                      priority: selectedPriority,
                      status: GrievanceStatus.open,
                      submittedBy: 'You',
                      submittedAt: DateTime.now(),
                    );
                    await _repo.submitGrievance(g);
                    if (!bCtx.mounted) return;
                    Navigator.pop(bCtx);
                    _load();
                    ScaffoldMessenger.of(bCtx).showSnackBar(
                      const SnackBar(
                        content: Text('Grievance submitted successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text('Submit Grievance', style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Detail bottom sheet ────────────────────────────────────────────────────

  void _showDetailSheet(BuildContext ctx, Grievance g, bool isDark, ColorScheme cs) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scroll) => SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _civicIndigo.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(g.category.icon, color: _civicIndigo, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(g.title, style: GoogleFonts.plusJakartaSans(
                    fontSize: 17, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ))),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _badge(g.priority.label, g.priority.color, isDark),
                  _badge(g.category.label, _civicIndigo, isDark),
                  if (g.unitNo != null) _badge('Unit ${g.unitNo}', const Color(0xFF64748B), isDark),
                ],
              ),
              const SizedBox(height: 16),
              Text('Submitted by ${g.submittedBy} · ${DateFormat('d MMM yyyy').format(g.submittedAt)}',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
              const SizedBox(height: 12),
              Text(g.description, style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155))),
              if (g.assignedTo != null) ...[
                const SizedBox(height: 16),
                Row(children: [
                  Icon(Icons.person_outline, size: 16, color: _civicIndigo),
                  const SizedBox(width: 6),
                  Text('Assigned to: ${g.assignedTo}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600,
                          color: _civicIndigo)),
                ]),
              ],
              if (g.resolutionNote != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Resolution Note', style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF22C55E))),
                    const SizedBox(height: 4),
                    Text(g.resolutionNote!, style: GoogleFonts.plusJakartaSans(fontSize: 13,
                        color: isDark ? const Color(0xFFBBF7D0) : const Color(0xFF166534))),
                  ]),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color, bool isDark) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: isDark ? 0.2 : 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.35)),
    ),
    child: Text(label, style: GoogleFonts.plusJakartaSans(
        fontSize: 11, fontWeight: FontWeight.w700, color: color)),
  );

  Widget _sheetField(TextEditingController ctrl, String label, String hint, bool isDark,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(
          color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
      decoration: _inputDecoration(label, isDark).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark) => InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.plusJakartaSans(
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13),
    filled: true,
    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

// ─── Grievance Card ──────────────────────────────────────────────────────────

class _GrievanceCard extends StatelessWidget {
  final Grievance grievance;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _GrievanceCard({
    required this.grievance, required this.isDark,
    required this.cs, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final g = grievance;
    final age = DateTime.now().difference(g.submittedAt);
    final ageStr = age.inDays > 0 ? '${age.inDays}d ago' : '${age.inHours}h ago';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          boxShadow: isDark
              ? null
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(g.category.icon, color: const Color(0xFF6366F1), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.title, style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text(g.category.label, style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                    const SizedBox(width: 6),
                    Text('·', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8))),
                    const SizedBox(width: 6),
                    Text(ageStr, style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: g.priority.color.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(g.priority.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: g.priority.color,
                )),
            ),
          ],
        ),
      ),
    );
  }
}
