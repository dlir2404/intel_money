import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  static void _showToast(BuildContext context, String message, Color backgroundColor, IconData icon) {
    FToast fToast = FToast();
    fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12.0),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  static void showLoading(BuildContext context) {
    _showToast(context, "Loading...", Colors.blue, Icons.hourglass_empty);
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, Colors.blue, Icons.info_outline);
  }

  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, Colors.green, Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, Colors.red, Icons.error_outline);
  }

  static void showWarning(BuildContext context, String message) {
    _showToast(context, message, Colors.orange, Icons.warning_amber_outlined);
  }

  static void showCustom(BuildContext context, String message, Color backgroundColor, IconData icon) {
    _showToast(context, message, backgroundColor, icon);
  }

  static void showUnkownError(BuildContext context) {
    _showToast(context, "An unknown error occurred", Colors.red, Icons.error_outline);
  }
}