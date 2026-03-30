import 'package:flutter/material.dart';
import 'error_handler.dart';

class AppErrorHandler {
  static void showErrorSnackBar(BuildContext context, String message) {
    ErrorHandler.showError(context, message);
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ErrorHandler.showSuccess(context, message);
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ErrorHandler.showInfo(context, message);
  }

  static Future<bool?> showConfirmDialog(BuildContext context, {required String title, required String message}) {
    return ErrorHandler.showErrorDialog(context, title: title, message: message, showRetry: false);
  }
}
