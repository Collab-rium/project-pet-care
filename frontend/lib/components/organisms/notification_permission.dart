import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../components/atoms/app_button.dart';
import '../../components/molecules/app_card.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';
import '../../core/theme/color_tokens_extension.dart';

/// Notification permission request dialog
class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback onGranted;
  final VoidCallback? onDenied;

  const NotificationPermissionDialog({
    super.key,
    required this.onGranted,
    this.onDenied,
  });

  static Future<bool> request({
    required BuildContext context,
  }) async {
    // Check current permission status
    final status = await Permission.notification.status;
    
    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      // Show settings dialog
      return await _showSettingsDialog(context) ?? false;
    }

    // Show explanation dialog
    final shouldRequest = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NotificationPermissionDialog(
        onGranted: () => Navigator.pop(context, true),
        onDenied: () => Navigator.pop(context, false),
      ),
    );

    if (shouldRequest == true) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    return false;
  }

  static Future<bool?> _showSettingsDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notification Permission'),
        content: Text(
          'Notification permission is permanently denied. Please enable it in app settings to receive reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusLg,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
                AppSpacing.hSpaceSm,
                Expanded(
                  child: Text(
                    'Enable Notifications',
                    style: AppTextStyles.h3,
                  ),
                ),
              ],
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Why we need notifications:',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.vSpaceSm,
            _buildFeatureItem(
              Icons.alarm,
              'Reminders',
              'Get notified for pet care reminders like feeding, medications, and vet appointments',
            ),
            AppSpacing.vSpaceXs,
            _buildFeatureItem(
              Icons.event,
              'Upcoming Events',
              'Never miss important dates like vaccinations or check-ups',
            ),
            AppSpacing.vSpaceXs,
            _buildFeatureItem(
              Icons.pets,
              'Pet Updates',
              'Stay informed about your pet\'s health and activities',
            ),
            AppSpacing.vSpaceMd,
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.infoLight.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: AppColors.info,
                  ),
                  AppSpacing.hSpaceXs,
                  Expanded(
                    child: Text(
                      'You can change this anytime in settings',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.vSpaceLg,
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    text: 'Not Now',
                    onPressed: onDenied ?? () => Navigator.pop(context, false),
                  ),
                ),
                AppSpacing.hSpaceMd,
                Expanded(
                  flex: 2,
                  child: AppButton.primary(
                    text: 'Enable',
                    onPressed: onGranted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        AppSpacing.hSpaceSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Helper function to check and request notification permission
class NotificationPermissionHelper {
  static Future<bool> checkAndRequest(BuildContext context) async {
    return await NotificationPermissionDialog.request(context: context);
  }

  static Future<PermissionStatus> getStatus() async {
    return await Permission.notification.status;
  }

  static Future<bool> isGranted() async {
    final status = await getStatus();
    return status.isGranted;
  }
}
