import 'package:flutter/material.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_toggle.dart';
import '../../components/molecules/app_card.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';

/// Password warning dialog for registration
class PasswordWarningDialog extends StatefulWidget {
  final VoidCallback onAccepted;

  const PasswordWarningDialog({
    super.key,
    required this.onAccepted,
  });

  static Future<bool?> show({
    required BuildContext context,
  }) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PasswordWarningDialog(
        onAccepted: () => Navigator.pop(context, true),
      ),
    );
    return result;
  }

  @override
  State<PasswordWarningDialog> createState() => _PasswordWarningDialogState();
}

class _PasswordWarningDialogState extends State<PasswordWarningDialog> {
  bool _acknowledged = false;

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
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 32,
                ),
                AppSpacing.hSpaceSm,
                Expanded(
                  child: Text(
                    '⚠️ Important Warning',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vSpaceMd,
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warningLight.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password Recovery Not Available',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                  AppSpacing.vSpaceXs,
                  Text(
                    'This is a local-only application. If you forget your password, you CANNOT recover your account.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Please ensure you:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.vSpaceSm,
            _buildBulletPoint('Write down your password in a safe place'),
            _buildBulletPoint('Use a password you will remember'),
            _buildBulletPoint('Consider using a password manager'),
            _buildBulletPoint('Back up your data regularly'),
            AppSpacing.vSpaceMd,
            Divider(color: AppColors.divider),
            AppSpacing.vSpaceSm,
            AppToggle.checkbox(
              value: _acknowledged,
              onChanged: (value) {
                setState(() {
                  _acknowledged = value;
                });
              },
              label: 'I understand and accept the risk. I will not be able to recover my password if I forget it.',
            ),
            AppSpacing.vSpaceLg,
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                AppSpacing.hSpaceMd,
                Expanded(
                  flex: 2,
                  child: AppButton.primary(
                    text: 'I Understand',
                    onPressed: _acknowledged ? widget.onAccepted : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTextStyles.bodyMedium),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline password warning banner
class PasswordWarningBanner extends StatelessWidget {
  const PasswordWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.warningLight.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.warning,
          ),
          AppSpacing.hSpaceSm,
          Expanded(
            child: Text(
              'No password recovery available. Save your password securely.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
