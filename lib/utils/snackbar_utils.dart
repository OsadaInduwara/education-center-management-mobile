import 'package:flutter/material.dart';

enum SnackbarType { success, warning, error }

class SnackbarUtils {
  static void showAutoDismissBanner(
      BuildContext context,
      String message, {
        SnackbarType type = SnackbarType.error, // Default is error
        int duration = 3,
      }) {
    Color backgroundColor;
    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green;
        break;
      case SnackbarType.warning:
        backgroundColor = Colors.orange;
        break;
      case SnackbarType.error:
      default:
        backgroundColor = Colors.redAccent;
        break;
    }

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('DISMISS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // Auto-dismiss after the specified duration
    Future.delayed(Duration(seconds: duration), () {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }
}
