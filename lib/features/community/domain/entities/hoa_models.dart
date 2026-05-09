import 'package:flutter/material.dart';

// ─── Society ──────────────────────────────────────────────────────────────────

class Society {
  final int id;
  final String name;
  final String registrationNo;
  final String address;
  final double maintenanceFeePerUnit;
  final String bankName;
  final String bankAccountNo;
  final String bankIfsc;
  final List<CommitteeMember> managingCommittee;

  const Society({
    required this.id,
    required this.name,
    required this.registrationNo,
    required this.address,
    required this.maintenanceFeePerUnit,
    required this.bankName,
    required this.bankAccountNo,
    required this.bankIfsc,
    required this.managingCommittee,
  });
}

class CommitteeMember {
  final String name;
  final String role;
  final String? phone;
  const CommitteeMember({required this.name, required this.role, this.phone});
}

// ─── Grievance ────────────────────────────────────────────────────────────────

enum GrievanceStatus { open, inProgress, resolved }

enum GrievancePriority { low, medium, high, urgent }

enum GrievanceCategory {
  plumbing, electrical, security, commonArea, parking, sanitation, other
}

extension GrievanceCategoryX on GrievanceCategory {
  String get label {
    switch (this) {
      case GrievanceCategory.plumbing: return 'Plumbing';
      case GrievanceCategory.electrical: return 'Electrical';
      case GrievanceCategory.security: return 'Security';
      case GrievanceCategory.commonArea: return 'Common Area';
      case GrievanceCategory.parking: return 'Parking';
      case GrievanceCategory.sanitation: return 'Sanitation';
      case GrievanceCategory.other: return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case GrievanceCategory.plumbing: return Icons.plumbing;
      case GrievanceCategory.electrical: return Icons.electrical_services;
      case GrievanceCategory.security: return Icons.security;
      case GrievanceCategory.commonArea: return Icons.park;
      case GrievanceCategory.parking: return Icons.local_parking;
      case GrievanceCategory.sanitation: return Icons.cleaning_services;
      case GrievanceCategory.other: return Icons.help_outline;
    }
  }
}

extension GrievancePriorityX on GrievancePriority {
  String get label {
    switch (this) {
      case GrievancePriority.low: return 'Low';
      case GrievancePriority.medium: return 'Medium';
      case GrievancePriority.high: return 'High';
      case GrievancePriority.urgent: return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case GrievancePriority.low: return const Color(0xFF22C55E);
      case GrievancePriority.medium: return const Color(0xFFF59E0B);
      case GrievancePriority.high: return const Color(0xFFF97316);
      case GrievancePriority.urgent: return const Color(0xFFEF4444);
    }
  }
}

class Grievance {
  final String id;
  final String title;
  final String description;
  final GrievanceCategory category;
  final GrievancePriority priority;
  final GrievanceStatus status;
  final String submittedBy;
  final String? unitNo;
  final DateTime submittedAt;
  final DateTime? resolvedAt;
  final List<String> photoUrls;
  final String? resolutionNote;
  final String? assignedTo;
  final String? linkedWorkOrderId;

  const Grievance({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.submittedBy,
    this.unitNo,
    required this.submittedAt,
    this.resolvedAt,
    this.photoUrls = const [],
    this.resolutionNote,
    this.assignedTo,
    this.linkedWorkOrderId,
  });
}

// ─── Work Order ───────────────────────────────────────────────────────────────

enum WorkOrderStatus { todo, inProgress, done }

enum WorkOrderCategory {
  maintenance, repair, cleaning, security, landscaping, painting, other
}

extension WorkOrderCategoryX on WorkOrderCategory {
  String get label {
    switch (this) {
      case WorkOrderCategory.maintenance: return 'Maintenance';
      case WorkOrderCategory.repair: return 'Repair';
      case WorkOrderCategory.cleaning: return 'Cleaning';
      case WorkOrderCategory.security: return 'Security';
      case WorkOrderCategory.landscaping: return 'Landscaping';
      case WorkOrderCategory.painting: return 'Painting';
      case WorkOrderCategory.other: return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case WorkOrderCategory.maintenance: return Icons.build;
      case WorkOrderCategory.repair: return Icons.handyman;
      case WorkOrderCategory.cleaning: return Icons.cleaning_services;
      case WorkOrderCategory.security: return Icons.security;
      case WorkOrderCategory.landscaping: return Icons.grass;
      case WorkOrderCategory.painting: return Icons.format_paint;
      case WorkOrderCategory.other: return Icons.miscellaneous_services;
    }
  }
}

class WorkOrder {
  final String id;
  final String title;
  final String description;
  final WorkOrderCategory category;
  final WorkOrderStatus status;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime dueDate;
  final DateTime? completedAt;
  final double estimatedCostInr;
  final double? actualCostInr;
  final String? linkedGrievanceId;
  final String? notes;

  const WorkOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.assignedTo,
    required this.createdAt,
    required this.dueDate,
    this.completedAt,
    required this.estimatedCostInr,
    this.actualCostInr,
    this.linkedGrievanceId,
    this.notes,
  });

  WorkOrder copyWith({WorkOrderStatus? status, DateTime? completedAt, double? actualCostInr}) {
    return WorkOrder(
      id: id, title: title, description: description, category: category,
      status: status ?? this.status, assignedTo: assignedTo,
      createdAt: createdAt, dueDate: dueDate,
      completedAt: completedAt ?? this.completedAt,
      estimatedCostInr: estimatedCostInr,
      actualCostInr: actualCostInr ?? this.actualCostInr,
      linkedGrievanceId: linkedGrievanceId, notes: notes,
    );
  }
}

// ─── Budget ───────────────────────────────────────────────────────────────────

class BudgetCategory {
  final String name;
  final double allocatedAmountInr;
  final double spentAmountInr;
  final Color color;
  final IconData icon;

  const BudgetCategory({
    required this.name,
    required this.allocatedAmountInr,
    required this.spentAmountInr,
    required this.color,
    required this.icon,
  });

  double get utilizationPercent =>
      allocatedAmountInr > 0 ? spentAmountInr / allocatedAmountInr : 0;
  double get remainingAmountInr => allocatedAmountInr - spentAmountInr;
}

class BudgetPeriod {
  final String label;
  final String periodKey;
  final double totalBudgetInr;
  final List<BudgetCategory> categories;

  const BudgetPeriod({
    required this.label,
    required this.periodKey,
    required this.totalBudgetInr,
    required this.categories,
  });

  double get totalSpentInr =>
      categories.fold(0, (sum, c) => sum + c.spentAmountInr);
  double get totalRemainingInr => totalBudgetInr - totalSpentInr;
  double get overallUtilization =>
      totalBudgetInr > 0 ? totalSpentInr / totalBudgetInr : 0;
}

// ─── Ledger ───────────────────────────────────────────────────────────────────

enum LedgerEntryType { credit, debit }

class LedgerEntry {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final double amountInr;
  final LedgerEntryType type;
  final String category;
  final String? receiptImageUrl;
  final String? workOrderId;
  final String recordedBy;

  const LedgerEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.amountInr,
    required this.type,
    required this.category,
    this.receiptImageUrl,
    this.workOrderId,
    required this.recordedBy,
  });
}
