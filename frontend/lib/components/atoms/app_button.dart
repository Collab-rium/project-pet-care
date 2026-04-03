import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';

/// Reusable button component with multiple variants
/// Supports primary, secondary, outlined, text, and icon styles
class AppButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Color? customColor;

  const AppButton({
    super.key,
    this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customColor,
  });

  /// Primary button (filled with primary color)
  factory AppButton.primary({
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  /// Secondary button
  factory AppButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.secondary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  /// Outlined button
  factory AppButton.outlined({
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    Color? customColor,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.outlined,
      size: size,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      customColor: customColor,
    );
  }

  /// Text button
  factory AppButton.text({
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    Color? customColor,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.text,
      size: size,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      customColor: customColor,
    );
  }

  /// Icon button
  factory AppButton.icon({
    required IconData icon,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    Color? customColor,
  }) {
    return AppButton(
      onPressed: onPressed,
      variant: ButtonVariant.icon,
      size: size,
      icon: icon,
      isLoading: isLoading,
      customColor: customColor,
    );
  }

  double _getHeight() => switch (size) {
    ButtonSize.small => 32,
    ButtonSize.medium => 44,
    ButtonSize.large => 56,
  };

  EdgeInsets _getPadding() => switch (size) {
    ButtonSize.small => const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ButtonSize.medium => const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ButtonSize.large => const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  };

  TextStyle? _getTextStyle() => switch (size) {
    ButtonSize.small => AppTextStyles.caption,
    ButtonSize.medium => AppTextStyles.button,
    ButtonSize.large => AppTextStyles.button,
  };

  Color _getLoadingColor() => switch (variant) {
    ButtonVariant.primary => AppColors.textOnPrimary,
    ButtonVariant.secondary => AppColors.textPrimary,
    ButtonVariant.outlined => AppColors.primary,
    _ => AppColors.primary,
  };

  Widget _buildContent(TextStyle? textStyle) {
    if (icon != null && text != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text!, style: textStyle),
        ],
      );
    }

    if (icon != null) {
      return Icon(icon);
    }

    return Text(text ?? '', style: textStyle);
  }

  @override
  Widget build(BuildContext context) {
    final height = _getHeight();
    final padding = _getPadding();
    final textStyle = _getTextStyle();
    final isDisabled = onPressed == null;

    // Use theme colors instead of hardcoded AppColors
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final onSecondaryColor = Theme.of(context).colorScheme.onSecondary;
    final onSurfaceVariantColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final borderColor = Theme.of(context).colorScheme.outline;

    Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingColor(),
              ),
            ),
          )
        : _buildContent(textStyle);

    Widget button;

    switch (variant) {
      case ButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: customColor ?? primaryColor,
            foregroundColor: onPrimaryColor,
            disabledBackgroundColor: borderColor,
            disabledForegroundColor: onSurfaceVariantColor,
            elevation: AppSpacing.elevationSm,
            padding: padding,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
          ),
          child: content,
        );
        break;

      case ButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: onSecondaryColor,
            disabledBackgroundColor: borderColor,
            disabledForegroundColor: onSurfaceVariantColor,
            elevation: 0,
            padding: padding,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
          ),
          child: content,
        );
        break;

      case ButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: customColor ?? primaryColor,
            disabledForegroundColor: onSurfaceVariantColor,
            side: BorderSide(
              color: isDisabled
                  ? borderColor
                  : (customColor ?? primaryColor),
              width: 1.5,
            ),
            padding: padding,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
          ),
          child: content,
        );
        break;

      case ButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: customColor ?? primaryColor,
            disabledForegroundColor: onSurfaceVariantColor,
            padding: padding,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
          ),
          child: content,
        );
        break;

      case ButtonVariant.icon:
        button = IconButton(
          icon: Icon(icon),
          onPressed: isLoading ? null : onPressed,
          color: customColor ?? primaryColor,
          disabledColor: onSurfaceVariantColor,
          iconSize: switch (size) {
            ButtonSize.small => 20,
            ButtonSize.medium => 24,
            ButtonSize.large => 28,
          },
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  icon,
}

enum ButtonSize {
  small,
  medium,
  large,
}
