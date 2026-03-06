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

  /// Main brand color - Deep Purple
  static const Color primary = Colors.deepPurple;
  static const Color primaryDarkTheme = Color(
    0xFFB388FF,
  ); // Lighter purple for dark mode

  /// Primary color with various opacities
  static const Color primaryLight = Color(0xFFB388FF);
  static const Color primaryDark = Color(0xFF512DA8);

  // ============ Secondary/Accent Colors ============

  /// Eye-catching accent color for primary actions/FABs
  static const Color accent = Color(0xFF00BFA5); // Teal A700
  static const Color accentDark = Color(0xFF1DE9B6); // Teal A400

  // ============ Background Colors ============

  /// Main scaffold background
  static const Color scaffoldBackground = Color(0xFFF5F7FA);
  static const Color scaffoldBackgroundDark = Color(0xFF121212);

  /// Card and surface background
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(
    0xFF242424,
  ); // Elevated dark surface for depth

  /// Elevated surface (modals, bottom sheets)
  static const Color surfaceElevated = Colors.white;

  // ============ Text Colors ============

  /// Primary text color
  static const Color textPrimary = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFEEEEEE);

  /// Secondary text color
  static const Color textSecondary = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  /// Hint and placeholder text
  static const Color textHint = Color(0xFFBDBDBD);

  /// Text on primary color background
  static const Color textOnPrimary = Colors.white;

  // ============ Status Colors ============

  /// Success/Resolved status
  static const Color success = Color(0xFF4CAF50);

  /// Warning/Pending status
  static const Color warning = Color(0xFFFF9800);

  /// Error/Urgent status
  static const Color error = Color(0xFFF44336);

  /// Info/Open status
  static const Color info = Color(0xFF2196F3);

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
    if (score <= 2) return const Color(0xFF8BC34A);
    if (score <= 3) return warning;
    if (score <= 4) return const Color(0xFFFF5722);
    return error;
  }

  // ============ Neutral Colors ============

  /// Border and divider color
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF333333);

  /// Disabled state color
  static const Color disabled = Color(0xFFBDBDBD);

  /// Shimmer/skeleton loading colors
  static const Color shimmerBase = Color(0xFFEEEEEE);
  static const Color shimmerHighlight = Color(0xFFFAFAFA);
}
