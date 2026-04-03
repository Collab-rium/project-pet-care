import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';
import '../../core/theme/color_tokens_extension.dart';

/// Toggle components: Switch, Checkbox, Radio
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final ToggleType type;
  final bool enabled;

  const AppToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.type = ToggleType.switchToggle,
    this.enabled = true,
  });

  factory AppToggle.switchToggle({
    required bool value,
    ValueChanged<bool>? onChanged,
    String? label,
    bool enabled = true,
  }) {
    return AppToggle(
      value: value,
      onChanged: onChanged,
      label: label,
      type: ToggleType.switchToggle,
      enabled: enabled,
    );
  }

  factory AppToggle.checkbox({
    required bool value,
    ValueChanged<bool>? onChanged,
    String? label,
    bool enabled = true,
  }) {
    return AppToggle(
      value: value,
      onChanged: onChanged,
      label: label,
      type: ToggleType.checkbox,
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    Widget toggle;

    switch (type) {
      case ToggleType.switchToggle:
        toggle = Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primaryLight,
        );
        break;

      case ToggleType.checkbox:
        toggle = Checkbox(
          value: value,
          onChanged: enabled ? (val) => onChanged?.call(val ?? false) : null,
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        );
        break;
    }

    if (label == null) {
      return toggle;
    }

    return Row(
      children: [
        toggle,
        AppSpacing.hSpaceSm,
        Expanded(
          child: GestureDetector(
            onTap: enabled ? () => onChanged?.call(!value) : null,
            child: Text(
              label!,
              style: AppTextStyles.bodyLarge.copyWith(
                color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum ToggleType {
  switchToggle,
  checkbox,
}

/// Radio button group
class AppRadioGroup<T> extends StatelessWidget {
  final T? value;
  final List<RadioOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final bool enabled;

  const AppRadioGroup({
    super.key,
    this.value,
    required this.options,
    this.onChanged,
    this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.vSpaceSm,
        ],
        ...options.map((option) {
          return RadioListTile<T>(
            value: option.value,
            groupValue: value,
            onChanged: enabled ? onChanged : null,
            title: Text(
              option.label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      ],
    );
  }
}

class RadioOption<T> {
  final T value;
  final String label;

  const RadioOption({
    required this.value,
    required this.label,
  });
}
