import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mudda_frontend/shared/theme/app_colors.dart';

/// A frosted-glass surface widget.
///
/// Applies a [BackdropFilter] blur behind a semi-transparent container,
/// creating a premium glassmorphism effect for headers, sheets, and cards.
///
/// Example:
/// ```dart
/// GlassContainer(
///   blur: 12,
///   child: Text('Hello'),
/// )
/// ```
class GlassContainer extends StatelessWidget {
  final Widget child;

  /// Blur radius — 8–16 is a good sweet spot.
  final double blur;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Corner radius.
  final double borderRadius;

  /// Override the glass fill colour. Defaults to theme-aware value.
  final Color? color;

  /// Border colour and width. Set [borderWidth] to 0 to hide.
  final Color? borderColor;
  final double borderWidth;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = color ??
        (isDark
            ? AppColors.glassDark
            : AppColors.glassLight);
    final resolvedBorder = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.7));

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderWidth > 0
                ? Border.all(
                    color: resolvedBorder,
                    width: borderWidth,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
