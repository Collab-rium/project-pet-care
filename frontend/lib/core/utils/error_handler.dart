import 'package:flutter/material.dart';
import '../../components/atoms/app_button.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';

/// Error handling utilities
class ErrorHandler {
  /// Show error snackbar
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppColors.textOnPrimary,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: duration,
      ),
    );
  }

  /// Show info snackbar
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        duration: duration,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warning,
        duration: duration,
      ),
    );
  }

  /// Show error dialog with retry option
  static Future<bool?> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool showRetry = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            AppSpacing.hSpaceSm,
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          if (showRetry)
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Retry'),
            ),
        ],
      ),
    );
  }
}

/// Network error screen widget
class NetworkErrorScreen extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const NetworkErrorScreen({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceLg,
            Text(
              'Connection Error',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceSm,
            Text(
              message ?? 'Unable to connect. Please check your internet connection and try again.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.vSpaceLg,
              AppButton.primary(
                text: 'Retry',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Generic error screen widget
class ErrorScreen extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.title,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            AppSpacing.vSpaceLg,
            Text(
              title ?? 'Something Went Wrong',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceSm,
            Text(
              message ?? 'An unexpected error occurred. Please try again.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.vSpaceLg,
              AppButton.primary(
                text: 'Try Again',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Backwards-compatible adapter used by older screens
class AppErrorHandler {
  static void showErrorSnackBar(BuildContext context, String message) => ErrorHandler.showError(context, message);
  static void showSuccessSnackBar(BuildContext context, String message) => ErrorHandler.showSuccess(context, message);
  static void showInfoSnackBar(BuildContext context, String message) => ErrorHandler.showInfo(context, message);
  // Backwards-compatible positional API used across the codebase
  static Future<bool?> showConfirmDialog(BuildContext context, String title, String message) {
    return ErrorHandler.showErrorDialog(context, title: title, message: message, showRetry: false);
  }
}
