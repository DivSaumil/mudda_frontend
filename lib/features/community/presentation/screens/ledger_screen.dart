import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/hoa_models.dart';
import '../../data/repositories/mock_hoa_repository.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final _repo = MockHoaRepository();
  List<LedgerEntry> _entries = [];
  bool _loading = true;
  LedgerEntryType? _typeFilter;

  final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  final _dateFmt = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.getLedgerEntries();
    if (mounted) setState(() { _entries = data; _loading = false; });
  }

  List<LedgerEntry> get _filtered {
    if (_typeFilter == null) return _entries;
    return _entries.where((e) => e.type == _typeFilter).toList();
  }

  double get _totalCredits =>
      _entries.where((e) => e.type == LedgerEntryType.credit)
          .fold(0, (s, e) => s + e.amountInr);

  double get _totalDebits =>
      _entries.where((e) => e.type == LedgerEntryType.debit)
          .fold(0, (s, e) => s + e.amountInr);

  double get _balance => _totalCredits - _totalDebits;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _load,
        color: const Color(0xFF6366F1),
        child: CustomScrollView(
          slivers: [
            // ── Balance header ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _balance >= 0
                          ? [const Color(0xFF059669), const Color(0xFF10B981)]
                          : [const Color(0xFFDC2626), const Color(0xFFEF4444)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Society Balance', style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                      const SizedBox(height: 4),
                      Text(_inr.format(_balance), style: GoogleFonts.plusJakartaSans(
                          fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 14),
                      Row(children: [
                        _balanceStat('Credits', _totalCredits, Colors.white.withValues(alpha: 0.9)),
                        Container(
                          width: 1, height: 32,
                          color: Colors.white.withValues(alpha: 0.3),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        _balanceStat('Debits', _totalDebits, Colors.white.withValues(alpha: 0.9)),
                      ]),
                    ],
                  ),
                ),
              ),
            ),

            // ── Filter chips ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(children: [
                  _chip('All', null, isDark),
                  const SizedBox(width: 8),
                  _chip('Credits', LedgerEntryType.credit, isDark),
                  const SizedBox(width: 8),
                  _chip('Debits', LedgerEntryType.debit, isDark),
                ]),
              ),
            ),

            // ── Transaction list ───────────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final entry = _filtered[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: _LedgerTile(
                      entry: entry,
                      isDark: isDark,
                      dateFmt: _dateFmt,
                      inrFormat: _inr,
                      onTap: () => _showDetailSheet(ctx, entry, isDark),
                    ),
                  );
                },
                childCount: _filtered.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _balanceStat(String label, double amount, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: GoogleFonts.plusJakartaSans(
          fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
      Text(_inr.format(amount), style: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w700, color: color)),
    ],
  );

  Widget _chip(String label, LedgerEntryType? type, bool isDark) {
    final selected = _typeFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _typeFilter = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
              : null,
          color: selected ? null : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white :
                (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
      ),
    );
  }

  void _showDetailSheet(BuildContext ctx, LedgerEntry entry, bool isDark) {
    final isCredit = entry.type == LedgerEntryType.credit;
    final amountColor = isCredit ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        builder: (_, scroll) => SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),

              // Amount + type
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: amountColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: amountColor, size: 24),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(isCredit ? 'Credit' : 'Debit', style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                  Text(_inr.format(entry.amountInr), style: GoogleFonts.plusJakartaSans(
                      fontSize: 26, fontWeight: FontWeight.w800, color: amountColor)),
                ]),
              ]),
              const SizedBox(height: 16),

              Text(entry.title, style: GoogleFonts.plusJakartaSans(
                  fontSize: 17, fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text(entry.description, style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
              const SizedBox(height: 14),

              _detailRow(Icons.calendar_today_outlined, _dateFmt.format(entry.date), isDark),
              const SizedBox(height: 6),
              _detailRow(Icons.category_outlined, entry.category, isDark),
              const SizedBox(height: 6),
              _detailRow(Icons.person_outline, entry.recordedBy, isDark),

              if (entry.receiptImageUrl != null) ...[
                const SizedBox(height: 16),
                Text('Receipt', style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF0F172A))),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(entry.receiptImageUrl!, height: 180,
                      width: double.infinity, fit: BoxFit.cover),
                ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text('Download PDF Receipt', style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700, fontSize: 14)),
                  onPressed: () => _downloadReceipt(entry),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, bool isDark) => Row(children: [
    Icon(icon, size: 15, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
    const SizedBox(width: 8),
    Expanded(child: Text(text, style: GoogleFonts.plusJakartaSans(
        fontSize: 13, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)))),
  ]);

  Future<void> _downloadReceipt(LedgerEntry entry) async {
    final pdf = pw.Document();
    final inrStr = _inr.format(entry.amountInr);
    final dateStr = _dateFmt.format(entry.date);
    final typeStr = entry.type == LedgerEntryType.credit ? 'CREDIT' : 'DEBIT';

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (pw.Context ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            color: const PdfColor.fromInt(0xFF6366F1),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Hillview Estates RWA',
                    style: pw.TextStyle(
                        color: PdfColors.white, fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Society Receipt', style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(inrStr,
                style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold,
                    color: entry.type == LedgerEntryType.credit
                        ? const PdfColor.fromInt(0xFF22C55E)
                        : const PdfColor.fromInt(0xFFEF4444))),
          ),
          pw.Center(child: pw.Text(typeStr,
              style: const pw.TextStyle(color: PdfColors.grey, fontSize: 12))),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),
          _pdfRow('Title', entry.title),
          _pdfRow('Description', entry.description),
          _pdfRow('Date', dateStr),
          _pdfRow('Category', entry.category),
          _pdfRow('Recorded By', entry.recordedBy),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text('This is a computer-generated receipt.',
              style: const pw.TextStyle(color: PdfColors.grey, fontSize: 9))),
        ],
      ),
    ));

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: Uint8List.fromList(bytes),
      filename: 'receipt_${entry.id}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10,
                  color: PdfColors.grey700)),
        ),
        pw.Expanded(child: pw.Text(value,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.black))),
      ],
    ),
  );
}

// ─── Ledger Tile ─────────────────────────────────────────────────────────────

class _LedgerTile extends StatelessWidget {
  final LedgerEntry entry;
  final bool isDark;
  final DateFormat dateFmt;
  final NumberFormat inrFormat;
  final VoidCallback onTap;

  const _LedgerTile({
    required this.entry, required this.isDark,
    required this.dateFmt, required this.inrFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = entry.type == LedgerEntryType.credit;
    final amountColor = isCredit ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

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
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: amountColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700, fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(children: [
                    Text(dateFmt.format(entry.date), style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                    const SizedBox(width: 6),
                    Container(width: 3, height: 3,
                        decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Flexible(child: Text(entry.category, style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        overflow: TextOverflow.ellipsis)),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                '${isCredit ? '+' : '-'} ${inrFormat.format(entry.amountInr)}',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w800, color: amountColor)),
              if (entry.receiptImageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.receipt_outlined, size: 12,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}
