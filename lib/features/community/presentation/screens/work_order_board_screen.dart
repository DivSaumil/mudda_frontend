import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/hoa_models.dart';
import '../../data/repositories/mock_hoa_repository.dart';

class WorkOrderBoardScreen extends StatefulWidget {
  const WorkOrderBoardScreen({super.key});

  @override
  State<WorkOrderBoardScreen> createState() => _WorkOrderBoardScreenState();
}

class _WorkOrderBoardScreenState extends State<WorkOrderBoardScreen> {
  final _repo = MockHoaRepository();
  List<WorkOrder> _orders = [];
  bool _loading = true;

  static const _civicIndigo = Color(0xFF6366F1);
  final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.getWorkOrders();
    if (mounted) setState(() { _orders = data; _loading = false; });
  }

  List<WorkOrder> _byStatus(WorkOrderStatus s) =>
      _orders.where((w) => w.status == s).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _load,
        color: _civicIndigo,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // ── Summary chips ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  _summaryChip('${_byStatus(WorkOrderStatus.todo).length}', 'To Do',
                      const Color(0xFF6366F1), isDark),
                  const SizedBox(width: 8),
                  _summaryChip('${_byStatus(WorkOrderStatus.inProgress).length}',
                      'In Progress', const Color(0xFFF59E0B), isDark),
                  const SizedBox(width: 8),
                  _summaryChip('${_byStatus(WorkOrderStatus.done).length}',
                      'Done', const Color(0xFF22C55E), isDark),
                ],
              ),
            ),
            _section('📋  To Do', _byStatus(WorkOrderStatus.todo),
                const Color(0xFF6366F1), isDark),
            _section('⚙️  In Progress', _byStatus(WorkOrderStatus.inProgress),
                const Color(0xFFF59E0B), isDark),
            _section('✅  Done', _byStatus(WorkOrderStatus.done),
                const Color(0xFF22C55E), isDark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _civicIndigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded),
        label: Text('Add Work Order',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        onPressed: () => _showAddSheet(context, isDark),
      ),
    );
  }

  Widget _section(String title, List<WorkOrder> items, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(children: [
            Text(title, style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF0F172A))),
            const SizedBox(width: 8),
            Container(width: 36, height: 2, color: color.withValues(alpha: 0.4)),
          ]),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text('None', style: GoogleFonts.plusJakartaSans(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontSize: 13)),
          )
        else
          ...items.map((w) => _WorkOrderTile(
                order: w,
                isDark: isDark,
                inrFormat: _inr,
                onComplete: w.status == WorkOrderStatus.todo
                    ? () => _markInProgress(w)
                    : w.status == WorkOrderStatus.inProgress
                        ? () => _markDone(w)
                        : null,
              )),
      ],
    );
  }

  Future<void> _markInProgress(WorkOrder w) async {
    await _repo.updateWorkOrderStatus(w.id, WorkOrderStatus.inProgress);
    _load();
  }

  Future<void> _markDone(WorkOrder w) async {
    await _repo.updateWorkOrderStatus(w.id, WorkOrderStatus.done);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Work order marked as done!'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Widget _summaryChip(String count, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Text(count, style: GoogleFonts.plusJakartaSans(
              fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.plusJakartaSans(
              fontSize: 11, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.8))),
        ]),
      ),
    );
  }

  void _showAddSheet(BuildContext ctx, bool isDark) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final assigneeCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    WorkOrderCategory selectedCat = WorkOrderCategory.maintenance;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (bCtx) => StatefulBuilder(
        builder: (bCtx, setSS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(bCtx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(height: 16),
                Text('New Work Order', style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A))),
                const SizedBox(height: 16),
                _field(titleCtrl, 'Title', isDark),
                const SizedBox(height: 10),
                _field(descCtrl, 'Description', isDark, maxLines: 2),
                const SizedBox(height: 10),
                _field(assigneeCtrl, 'Assignee (optional)', isDark),
                const SizedBox(height: 10),
                _field(costCtrl, 'Estimated Cost (₹)', isDark, keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                DropdownButtonFormField<WorkOrderCategory>(
                  initialValue: selectedCat,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  decoration: _dec('Category', isDark),
                  items: WorkOrderCategory.values.map((c) =>
                      DropdownMenuItem(value: c, child: Text(c.label))).toList(),
                  onChanged: (v) => setSS(() => selectedCat = v!),
                  style: GoogleFonts.plusJakartaSans(
                      color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _civicIndigo, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      final cost = double.tryParse(costCtrl.text.trim()) ?? 0;
                      final wo = WorkOrder(
                        id: 'wo-${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        category: selectedCat,
                        status: WorkOrderStatus.todo,
                        assignedTo: assigneeCtrl.text.trim().isEmpty ? null : assigneeCtrl.text.trim(),
                        createdAt: DateTime.now(),
                        dueDate: DateTime.now().add(const Duration(days: 7)),
                        estimatedCostInr: cost,
                      );
                      await _repo.addWorkOrder(wo);
                      if (!bCtx.mounted) return;
                      Navigator.pop(bCtx);
                      _load();
                    },
                    child: Text('Create Work Order', style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, bool isDark,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: c, maxLines: maxLines, keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(
          color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
      decoration: _dec(label, isDark),
    );
  }

  InputDecoration _dec(String label, bool isDark) => InputDecoration(
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

// ─── Work Order Tile ─────────────────────────────────────────────────────────

class _WorkOrderTile extends StatelessWidget {
  final WorkOrder order;
  final bool isDark;
  final NumberFormat inrFormat;
  final VoidCallback? onComplete;

  const _WorkOrderTile({
    required this.order, required this.isDark,
    required this.inrFormat, this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final w = order;
    final dueDiff = w.dueDate.difference(DateTime.now());
    final isOverdue = dueDiff.isNegative && w.status != WorkOrderStatus.done;
    final dueLabel = w.status == WorkOrderStatus.done
        ? 'Completed ${DateFormat('d MMM').format(w.completedAt!)}'
        : isOverdue
            ? 'Overdue by ${(-dueDiff.inDays)}d'
            : 'Due ${DateFormat('d MMM').format(w.dueDate)}';

    final statusColor = w.status == WorkOrderStatus.done
        ? const Color(0xFF22C55E)
        : w.status == WorkOrderStatus.inProgress
            ? const Color(0xFFF59E0B)
            : const Color(0xFF6366F1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          boxShadow: isDark
              ? null
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(w.category.icon, color: statusColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(w.title, style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700, fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ))),
                    if (onComplete != null)
                      GestureDetector(
                        onTap: onComplete,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              w.status == WorkOrderStatus.todo
                                  ? const Color(0xFF6366F1) : const Color(0xFF22C55E),
                              w.status == WorkOrderStatus.todo
                                  ? const Color(0xFF8B5CF6) : const Color(0xFF16A34A),
                            ]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            w.status == WorkOrderStatus.todo ? 'Start' : 'Done',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(w.description, style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(children: [
                  if (w.assignedTo != null) ...[
                    Icon(Icons.person_outline, size: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(w.assignedTo!, style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                    const SizedBox(width: 10),
                  ],
                  Icon(Icons.calendar_today_outlined, size: 13,
                      color: isOverdue ? const Color(0xFFEF4444) :
                          (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                  const SizedBox(width: 4),
                  Text(dueLabel, style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isOverdue ? const Color(0xFFEF4444) :
                          (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w400)),
                  const Spacer(),
                  Text(inrFormat.format(w.actualCostInr ?? w.estimatedCostInr),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w700, color: statusColor)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
