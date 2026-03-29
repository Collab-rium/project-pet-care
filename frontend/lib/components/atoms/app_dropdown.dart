import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';

/// Reusable dropdown component
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final IconData? prefixIcon;
  final bool enabled;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.errorText,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.label.copyWith(
              color: hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          AppSpacing.vSpaceXs,
        ],
        Container(
          decoration: BoxDecoration(
            color: enabled ? AppColors.surface : AppColors.surfaceVariant,
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.border,
              width: hasError ? 1.5 : 1,
            ),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<T>(
                value: value,
                hint: hint != null
                    ? Text(
                        hint!,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      )
                    : null,
                items: items,
                onChanged: enabled ? onChanged : null,
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
                ),
                dropdownColor: AppColors.surface,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          AppSpacing.vSpaceXs,
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
