import 'package:flutter/material.dart';

class SnackbarUtil {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, isError: false);
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, isError: true);
  }

  static void _showSnackbar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    final color = isError ? Colors.redAccent : Colors.green;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          elevation: 6,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
