import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/theme/color_tokens_extension.dart';

/// Reusable icon component with consistent sizing
class AppIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final VoidCallback? onTap;

  const AppIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.onTap,
  });

  factory AppIcon.small({
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
  }) {
    return AppIcon(
      icon: icon,
      size: AppSpacing.iconSm,
      color: color,
      onTap: onTap,
    );
  }

  factory AppIcon.medium({
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
  }) {
    return AppIcon(
      icon: icon,
      size: AppSpacing.iconMd,
      color: color,
      onTap: onTap,
    );
  }

  factory AppIcon.large({
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
  }) {
    return AppIcon(
      icon: icon,
      size: AppSpacing.iconLg,
      color: color,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final iconWidget = Icon(
      icon,
      size: size ?? AppSpacing.iconMd,
      color: color ?? AppColors.textSecondary,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}

/// Icon button with circular background
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    
    return Material(
      color: backgroundColor ?? AppColors.primary,
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: size * 0.5,
            color: iconColor ?? AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}
