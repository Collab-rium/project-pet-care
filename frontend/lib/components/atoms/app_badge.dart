import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';

/// Badge component for status indicators, counts, etc.
class AppBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final BadgeSize size;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.size = BadgeSize.medium,
    this.icon,
  });

  /// Success badge (green)
  factory AppBadge.success({
    required String text,
    BadgeSize size = BadgeSize.medium,
    IconData? icon,
  }) {
    return AppBadge(
      text: text,
      backgroundColor: AppColors.success,
      textColor: AppColors.textOnPrimary,
      size: size,
      icon: icon,
    );
  }

  /// Warning badge (yellow/orange)
  factory AppBadge.warning({
    required String text,
    BadgeSize size = BadgeSize.medium,
    IconData? icon,
  }) {
    return AppBadge(
      text: text,
      backgroundColor: AppColors.warning,
      textColor: AppColors.textPrimary,
      size: size,
      icon: icon,
    );
  }

  /// Error badge (red)
  factory AppBadge.error({
    required String text,
    BadgeSize size = BadgeSize.medium,
    IconData? icon,
  }) {
    return AppBadge(
      text: text,
      backgroundColor: AppColors.error,
      textColor: AppColors.textOnPrimary,
      size: size,
      icon: icon,
    );
  }

  /// Info badge (blue)
  factory AppBadge.info({
    required String text,
    BadgeSize size = BadgeSize.medium,
    IconData? icon,
  }) {
    return AppBadge(
      text: text,
      backgroundColor: AppColors.info,
      textColor: AppColors.textOnPrimary,
      size: size,
      icon: icon,
    );
  }

  /// Count badge (for notification counts)
  factory AppBadge.count({
    required int count,
    BadgeSize size = BadgeSize.small,
  }) {
    return AppBadge(
      text: count > 99 ? '99+' : count.toString(),
      backgroundColor: AppColors.error,
      textColor: AppColors.textOnPrimary,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = _getPadding();
    final textStyle = _getTextStyle();
    final iconSize = _getIconSize();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: textColor ?? AppColors.textOnPrimary,
            ),
            SizedBox(width: AppSpacing.xs),
          ],
          Text(
            text,
            style: textStyle.copyWith(
              color: textColor ?? AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case BadgeSize.small:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        );
      case BadgeSize.medium:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case BadgeSize.large:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case BadgeSize.small:
        return AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600);
      case BadgeSize.medium:
        return AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600);
      case BadgeSize.large:
        return AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600);
    }
  }

  double _getIconSize() {
    switch (size) {
      case BadgeSize.small:
        return AppSpacing.iconXs;
      case BadgeSize.medium:
        return AppSpacing.iconSm;
      case BadgeSize.large:
        return AppSpacing.iconMd;
    }
  }
}

enum BadgeSize {
  small,
  medium,
  large,
}
