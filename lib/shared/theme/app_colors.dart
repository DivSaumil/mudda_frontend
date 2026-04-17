/// Application color palette.
///
/// Defines all colors used throughout the app for consistency.
/// Use these instead of hardcoded color values.
library;

import 'package:flutter/material.dart';

/// Centralized color definitions for the app.
///
/// Group colors by their purpose (primary, status, neutral, etc.)
/// to make it easy to find and update colors consistently.
class AppColors {
  AppColors._(); // Private constructor

  // ============ Primary Colors ============

  /// Main brand color — Civic Indigo
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDarkTheme = Color(0xFF818CF8); // Soft indigo for dark mode

  /// Primary color shades
  static const Color primaryLight = Color(0xFFC7D2FE); // indigo-200
  static const Color primaryDark = Color(0xFF3730A3); // indigo-800

  // ============ Secondary/Accent Colors ============

  /// Eye-catching accent for primary actions/FABs — Emerald
  static const Color accent = Color(0xFF10B981); // emerald-500
  static const Color accentDark = Color(0xFF34D399); // emerald-400

  // ============ Gradient Definitions ============

  /// Primary action gradient — Indigo → Violet
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Danger/CTA gradient — Red-orange spectrum
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient — Teal to Emerald
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Info/Stats gradient — Blue spectrum
  static const LinearGradient infoGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Header gradient for dark surfaces — deep indigo
  static const LinearGradient headerGradientDark = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ Background Colors ============

  /// Main scaffold background — light neutral
  static const Color scaffoldBackground = Color(0xFFF5F7FA);

  /// Midnight Navy — premium dark mode base
  static const Color scaffoldBackgroundDark = Color(0xFF0F172A);

  /// Card and surface background
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B); // Slate-800 for depth

  /// Elevated surface — modals, bottom sheets (dark)
  static const Color surfaceElevatedDark = Color(0xFF334155); // Slate-700

  /// Glass effect overlay colors
  static const Color glassLight = Color(0xE8FFFFFF); // white 91% opacity
  static const Color glassDark = Color(0xCC1E293B);  // slate-800 80% opacity

  // ============ Text Colors ============

  /// Primary text color
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Slate-100

  /// Secondary text color
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate-400

  /// Hint and placeholder text
  static const Color textHint = Color(0xFFCBD5E1); // Slate-300
  static const Color textHintDark = Color(0xFF475569); // Slate-600

  /// Text on primary color background
  static const Color textOnPrimary = Colors.white;

  // ============ Status Colors ============

  /// Success/Resolved status — Emerald
  static const Color success = Color(0xFF10B981);

  /// Warning/Pending status — Amber
  static const Color warning = Color(0xFFF59E0B);

  /// Error/Urgent status — Rose
  static const Color error = Color(0xFFEF4444);

  /// Info/Open status — Sky
  static const Color info = Color(0xFF3B82F6);

  // ============ Issue Status Colors ============

  /// Returns the appropriate color for an issue status.
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return warning;
      case 'SOLVED':
      case 'CLOSED':
        return success;
      case 'PENDING':
        return info;
      case 'URGENT':
        return error;
      default:
        return textSecondary;
    }
  }

  // ============ Severity Colors ============

  /// Returns color based on severity score (1-5).
  static Color getSeverityColor(int score) {
    if (score <= 1) return success;
    if (score <= 2) return const Color(0xFF84CC16); // lime
    if (score <= 3) return warning;
    if (score <= 4) return const Color(0xFFF97316); // orange
    return error;
  }

  // ============ Neutral Colors ============

  /// Border and divider color
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  static const Color borderDark = Color(0xFF334155); // Slate-700

  /// Disabled state color
  static const Color disabled = Color(0xFFCBD5E1); // Slate-300

  /// Shimmer/skeleton loading colors
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
  static const Color shimmerBaseDark = Color(0xFF334155);
  static const Color shimmerHighlightDark = Color(0xFF475569);
}
