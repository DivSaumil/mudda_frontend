import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/hoa_models.dart';

class MockHoaRepository {
  static final MockHoaRepository _instance = MockHoaRepository._internal();
  factory MockHoaRepository() => _instance;
  MockHoaRepository._internal();

  // Mutable in-memory lists for demo interactivity
  final List<Grievance> _grievances = _initialGrievances();
  final List<WorkOrder> _workOrders = _initialWorkOrders();

  // ─── Society ────────────────────────────────────────────────────────────────

  Future<Society> getSociety() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Society(
      id: 1,
      name: 'Hillview Estates RWA',
      registrationNo: 'RWA/DL/2018/04521',
      address: 'Block A-12, Hillview Estates, Sector 62, Noida – 201309',
      maintenanceFeePerUnit: 3500,
      bankName: 'HDFC Bank',
      bankAccountNo: '5020012345678',
      bankIfsc: 'HDFC0001234',
      managingCommittee: [
        CommitteeMember(name: 'Rajesh Sharma', role: 'President', phone: '+91 98100 00001'),
        CommitteeMember(name: 'Priya Mehta', role: 'Secretary', phone: '+91 98100 00002'),
        CommitteeMember(name: 'Amit Verma', role: 'Treasurer', phone: '+91 98100 00003'),
      ],
    );
  }

  // ─── Grievances ─────────────────────────────────────────────────────────────

  Future<List<Grievance>> getGrievances() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_grievances);
  }

  Future<bool> submitGrievance(Grievance g) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _grievances.insert(0, g);
    return true;
  }

  Future<bool> updateGrievanceStatus(String id, GrievanceStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _grievances.indexWhere((g) => g.id == id);
    if (idx == -1) return false;
    final old = _grievances[idx];
    _grievances[idx] = Grievance(
      id: old.id, title: old.title, description: old.description,
      category: old.category, priority: old.priority, status: status,
      submittedBy: old.submittedBy, unitNo: old.unitNo,
      submittedAt: old.submittedAt,
      resolvedAt: status == GrievanceStatus.resolved ? DateTime.now() : old.resolvedAt,
      photoUrls: old.photoUrls, resolutionNote: old.resolutionNote,
      assignedTo: old.assignedTo, linkedWorkOrderId: old.linkedWorkOrderId,
    );
    return true;
  }

  // ─── Work Orders ────────────────────────────────────────────────────────────

  Future<List<WorkOrder>> getWorkOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_workOrders);
  }

  Future<bool> updateWorkOrderStatus(String id, WorkOrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _workOrders.indexWhere((w) => w.id == id);
    if (idx == -1) return false;
    _workOrders[idx] = _workOrders[idx].copyWith(
      status: status,
      completedAt: status == WorkOrderStatus.done ? DateTime.now() : null,
    );
    return true;
  }

  Future<bool> addWorkOrder(WorkOrder wo) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _workOrders.insert(0, wo);
    return true;
  }

  // ─── Work History (completed work orders) ──────────────────────────────────

  Future<List<WorkOrder>> getWorkHistory() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [..._workOrders.where((w) => w.status == WorkOrderStatus.done), ..._historyItems];
  }

  // ─── Budget ─────────────────────────────────────────────────────────────────

  Future<List<BudgetPeriod>> getBudgetPeriods() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _budgetPeriods;
  }

  // ─── Ledger ─────────────────────────────────────────────────────────────────

  Future<List<LedgerEntry>> getLedgerEntries() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _ledgerEntries;
  }
}

// ─── Static Mock Data ────────────────────────────────────────────────────────

List<Grievance> _initialGrievances() => [
  Grievance(
    id: 'grv-001', title: 'Water leakage in B-Wing corridor',
    description: 'There is a persistent water leak near flat B-204 corridor, causing slippery floors and wall damage.',
    category: GrievanceCategory.plumbing, priority: GrievancePriority.urgent,
    status: GrievanceStatus.inProgress, submittedBy: 'Suresh Nair',
    unitNo: 'B-204', submittedAt: DateTime.now().subtract(const Duration(days: 2)),
    assignedTo: 'Ramesh Plumber',
  ),
  Grievance(
    id: 'grv-002', title: 'Street light out near Gate 2',
    description: 'The street light near Gate 2 has been non-functional for 5 days. Creates a safety hazard at night.',
    category: GrievanceCategory.electrical, priority: GrievancePriority.high,
    status: GrievanceStatus.open, submittedBy: 'Anita Joshi',
    unitNo: 'A-101', submittedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Grievance(
    id: 'grv-003', title: 'CCTV camera not working – Parking Level 2',
    description: 'The CCTV camera on Parking Level 2 has been offline. Residents are concerned about security.',
    category: GrievanceCategory.security, priority: GrievancePriority.high,
    status: GrievanceStatus.open, submittedBy: 'Vikram Singh',
    unitNo: 'C-301', submittedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Grievance(
    id: 'grv-004', title: 'Broken bench in Children\'s Park',
    description: 'One of the wooden benches in the children\'s play area has a broken leg and is unsafe.',
    category: GrievanceCategory.commonArea, priority: GrievancePriority.medium,
    status: GrievanceStatus.resolved, submittedBy: 'Meera Kapoor',
    unitNo: 'D-105', submittedAt: DateTime.now().subtract(const Duration(days: 10)),
    resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
    resolutionNote: 'Bench replaced with new one. Vendor: Furniture World, ₹4,500.',
  ),
  Grievance(
    id: 'grv-005', title: 'Garbage not collected for 3 days',
    description: 'The dry waste collection has been skipped for 3 consecutive days in the D-Wing area.',
    category: GrievanceCategory.sanitation, priority: GrievancePriority.medium,
    status: GrievanceStatus.inProgress, submittedBy: 'Ravi Kumar',
    unitNo: 'D-201', submittedAt: DateTime.now().subtract(const Duration(days: 1)),
    assignedTo: 'Housekeeping Team',
  ),
];

List<WorkOrder> _initialWorkOrders() => [
  WorkOrder(
    id: 'wo-001', title: 'Fix plumbing leak – B Wing corridor',
    description: 'Locate and fix the water pipe leak near B-204. Check for wall seepage.',
    category: WorkOrderCategory.repair, status: WorkOrderStatus.inProgress,
    assignedTo: 'Ramesh Plumber',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    dueDate: DateTime.now().add(const Duration(days: 1)),
    estimatedCostInr: 3500, linkedGrievanceId: 'grv-001',
  ),
  WorkOrder(
    id: 'wo-002', title: 'Replace street light bulb – Gate 2',
    description: 'Replace the LED street light unit near Gate 2. Check wiring.',
    category: WorkOrderCategory.maintenance, status: WorkOrderStatus.todo,
    assignedTo: 'Electrician – Mohan',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    dueDate: DateTime.now().add(const Duration(days: 2)),
    estimatedCostInr: 1800, linkedGrievanceId: 'grv-002',
  ),
  WorkOrder(
    id: 'wo-003', title: 'CCTV repair – Parking Level 2',
    description: 'Inspect and repair CCTV camera and DVR connection on P2.',
    category: WorkOrderCategory.security, status: WorkOrderStatus.todo,
    assignedTo: 'SecureVision Technician',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    dueDate: DateTime.now().add(const Duration(days: 3)),
    estimatedCostInr: 5000, linkedGrievanceId: 'grv-003',
  ),
  WorkOrder(
    id: 'wo-004', title: 'Monthly garden trimming',
    description: 'Trim hedges, mow lawns and clean garden paths in all common areas.',
    category: WorkOrderCategory.landscaping, status: WorkOrderStatus.todo,
    assignedTo: 'Green Thumb Services',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    dueDate: DateTime.now().add(const Duration(days: 5)),
    estimatedCostInr: 8000,
  ),
  WorkOrder(
    id: 'wo-005', title: 'Repaint lobby walls – A Wing',
    description: 'Full repaint of A-Wing lobby. Two coats of off-white emulsion.',
    category: WorkOrderCategory.painting, status: WorkOrderStatus.done,
    assignedTo: 'Ravi Painters',
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    dueDate: DateTime.now().subtract(const Duration(days: 7)),
    completedAt: DateTime.now().subtract(const Duration(days: 8)),
    estimatedCostInr: 12000, actualCostInr: 11500,
  ),
];

final List<WorkOrder> _historyItems = [
  WorkOrder(
    id: 'wo-h01', title: 'Annual pump maintenance',
    description: 'Full servicing of overhead and sump pumps.',
    category: WorkOrderCategory.maintenance, status: WorkOrderStatus.done,
    assignedTo: 'Aqua Services',
    createdAt: DateTime.now().subtract(const Duration(days: 40)),
    dueDate: DateTime.now().subtract(const Duration(days: 32)),
    completedAt: DateTime.now().subtract(const Duration(days: 32)),
    estimatedCostInr: 15000, actualCostInr: 14500,
  ),
  WorkOrder(
    id: 'wo-h02', title: 'Clean overhead water tanks',
    description: 'Chemical cleaning and disinfection of all overhead tanks.',
    category: WorkOrderCategory.cleaning, status: WorkOrderStatus.done,
    assignedTo: 'CleanTank Co.',
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    dueDate: DateTime.now().subtract(const Duration(days: 52)),
    completedAt: DateTime.now().subtract(const Duration(days: 53)),
    estimatedCostInr: 8000, actualCostInr: 8000,
  ),
  WorkOrder(
    id: 'wo-h03', title: 'Festival lighting installation',
    description: 'Diwali decorative lights in common areas.',
    category: WorkOrderCategory.maintenance, status: WorkOrderStatus.done,
    assignedTo: 'Bright Lights Decor',
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    dueDate: DateTime.now().subtract(const Duration(days: 85)),
    completedAt: DateTime.now().subtract(const Duration(days: 85)),
    estimatedCostInr: 6000, actualCostInr: 5800,
  ),
];

final List<BudgetPeriod> _budgetPeriods = [
  BudgetPeriod(
    label: 'May 2026', periodKey: '2026-05', totalBudgetInr: 120000,
    categories: [
      BudgetCategory(name: 'Maintenance & Repair', allocatedAmountInr: 40000, spentAmountInr: 28500,
          color: const Color(0xFF6366F1), icon: Icons.build),
      BudgetCategory(name: 'Housekeeping', allocatedAmountInr: 25000, spentAmountInr: 22000,
          color: const Color(0xFF22C55E), icon: Icons.cleaning_services),
      BudgetCategory(name: 'Security', allocatedAmountInr: 20000, spentAmountInr: 20000,
          color: const Color(0xFFEF4444), icon: Icons.security),
      BudgetCategory(name: 'Landscaping', allocatedAmountInr: 15000, spentAmountInr: 6000,
          color: const Color(0xFF84CC16), icon: Icons.grass),
      BudgetCategory(name: 'Administrative', allocatedAmountInr: 10000, spentAmountInr: 4500,
          color: const Color(0xFFF59E0B), icon: Icons.folder),
      BudgetCategory(name: 'Utilities', allocatedAmountInr: 10000, spentAmountInr: 9200,
          color: const Color(0xFF06B6D4), icon: Icons.bolt),
    ],
  ),
  BudgetPeriod(
    label: 'April 2026', periodKey: '2026-04', totalBudgetInr: 120000,
    categories: [
      BudgetCategory(name: 'Maintenance & Repair', allocatedAmountInr: 40000, spentAmountInr: 38000,
          color: const Color(0xFF6366F1), icon: Icons.build),
      BudgetCategory(name: 'Housekeeping', allocatedAmountInr: 25000, spentAmountInr: 25000,
          color: const Color(0xFF22C55E), icon: Icons.cleaning_services),
      BudgetCategory(name: 'Security', allocatedAmountInr: 20000, spentAmountInr: 20000,
          color: const Color(0xFFEF4444), icon: Icons.security),
      BudgetCategory(name: 'Landscaping', allocatedAmountInr: 15000, spentAmountInr: 14000,
          color: const Color(0xFF84CC16), icon: Icons.grass),
      BudgetCategory(name: 'Administrative', allocatedAmountInr: 10000, spentAmountInr: 9800,
          color: const Color(0xFFF59E0B), icon: Icons.folder),
      BudgetCategory(name: 'Utilities', allocatedAmountInr: 10000, spentAmountInr: 10500,
          color: const Color(0xFF06B6D4), icon: Icons.bolt),
    ],
  ),
  BudgetPeriod(
    label: 'March 2026', periodKey: '2026-03', totalBudgetInr: 120000,
    categories: [
      BudgetCategory(name: 'Maintenance & Repair', allocatedAmountInr: 40000, spentAmountInr: 32000,
          color: const Color(0xFF6366F1), icon: Icons.build),
      BudgetCategory(name: 'Housekeeping', allocatedAmountInr: 25000, spentAmountInr: 24000,
          color: const Color(0xFF22C55E), icon: Icons.cleaning_services),
      BudgetCategory(name: 'Security', allocatedAmountInr: 20000, spentAmountInr: 20000,
          color: const Color(0xFFEF4444), icon: Icons.security),
      BudgetCategory(name: 'Landscaping', allocatedAmountInr: 15000, spentAmountInr: 8000,
          color: const Color(0xFF84CC16), icon: Icons.grass),
      BudgetCategory(name: 'Administrative', allocatedAmountInr: 10000, spentAmountInr: 7200,
          color: const Color(0xFFF59E0B), icon: Icons.folder),
      BudgetCategory(name: 'Utilities', allocatedAmountInr: 10000, spentAmountInr: 9800,
          color: const Color(0xFF06B6D4), icon: Icons.bolt),
    ],
  ),
];

final List<LedgerEntry> _ledgerEntries = [
  LedgerEntry(
    id: 'led-001', date: DateTime(2026, 5, 1), title: 'Maintenance Collection – May',
    description: '35 units × ₹3,500 monthly maintenance fee collected.',
    amountInr: 122500, type: LedgerEntryType.credit, category: 'Maintenance Fee',
    recordedBy: 'Priya Mehta (Secretary)',
  ),
  LedgerEntry(
    id: 'led-002', date: DateTime(2026, 5, 3), title: 'Security Agency – May Salary',
    description: 'Monthly payment to SecureGuard Pvt. Ltd. for 4 guards.',
    amountInr: 20000, type: LedgerEntryType.debit, category: 'Security',
    recordedBy: 'Amit Verma (Treasurer)', workOrderId: null,
  ),
  LedgerEntry(
    id: 'led-003', date: DateTime(2026, 5, 5), title: 'Housekeeping Team – May Wages',
    description: 'Salaries for 3 housekeeping staff for May.',
    amountInr: 22000, type: LedgerEntryType.debit, category: 'Housekeeping',
    recordedBy: 'Amit Verma (Treasurer)',
  ),
  LedgerEntry(
    id: 'led-004', date: DateTime(2026, 5, 7), title: 'Plumbing Repair – B Wing',
    description: 'Water pipe leak fix near B-204. Parts + Labour.',
    amountInr: 3500, type: LedgerEntryType.debit, category: 'Maintenance & Repair',
    receiptImageUrl: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&q=80',
    recordedBy: 'Rajesh Sharma (President)', workOrderId: 'wo-001',
  ),
  LedgerEntry(
    id: 'led-005', date: DateTime(2026, 5, 8), title: 'Electricity Bill – Common Areas',
    description: 'NPCL bill for lifts, corridor lights and pumps.',
    amountInr: 9200, type: LedgerEntryType.debit, category: 'Utilities',
    recordedBy: 'Amit Verma (Treasurer)',
  ),
  LedgerEntry(
    id: 'led-006', date: DateTime(2026, 4, 30), title: 'Penalty – Noise Violation (Flat A-302)',
    description: 'Penalty collected from flat A-302 for noise regulation violation.',
    amountInr: 2000, type: LedgerEntryType.credit, category: 'Penalties & Fines',
    recordedBy: 'Priya Mehta (Secretary)',
  ),
  LedgerEntry(
    id: 'led-007', date: DateTime(2026, 4, 28), title: 'A-Wing Lobby Repaint',
    description: 'Two-coat emulsion repaint by Ravi Painters.',
    amountInr: 11500, type: LedgerEntryType.debit, category: 'Maintenance & Repair',
    receiptImageUrl: 'https://images.unsplash.com/photo-1562259929-b4e1fd3aef09?w=400&q=80',
    recordedBy: 'Amit Verma (Treasurer)', workOrderId: 'wo-005',
  ),
  LedgerEntry(
    id: 'led-008', date: DateTime(2026, 4, 25), title: 'Maintenance Collection – April',
    description: '35 units × ₹3,500 monthly maintenance fee collected.',
    amountInr: 122500, type: LedgerEntryType.credit, category: 'Maintenance Fee',
    recordedBy: 'Priya Mehta (Secretary)',
  ),
  LedgerEntry(
    id: 'led-009', date: DateTime(2026, 4, 15), title: 'Annual Pump Servicing',
    description: 'Full servicing of overhead and sump pumps by Aqua Services.',
    amountInr: 14500, type: LedgerEntryType.debit, category: 'Maintenance & Repair',
    receiptImageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=400&q=80',
    recordedBy: 'Amit Verma (Treasurer)', workOrderId: 'wo-h01',
  ),
  LedgerEntry(
    id: 'led-010', date: DateTime(2026, 4, 10), title: 'Water Tank Cleaning',
    description: 'Chemical cleaning and disinfection of all tanks by CleanTank Co.',
    amountInr: 8000, type: LedgerEntryType.debit, category: 'Housekeeping',
    recordedBy: 'Amit Verma (Treasurer)', workOrderId: 'wo-h02',
  ),
];
