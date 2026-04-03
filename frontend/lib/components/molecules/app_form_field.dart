import 'package:flutter/material.dart';
import '../../components/atoms/app_input.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/color_tokens_extension.dart';

class AppFormField extends StatelessWidget {
  final String? label;
  final bool isRequired;
  final Widget? child;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  const AppFormField({
    super.key,
    this.label,
    this.isRequired = false,
    this.child,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(label!, style: AppTextStyles.label),
              if (isRequired) ...[
                SizedBox(width: 6),
                Text('*', style: AppTextStyles.label.copyWith(color: AppColors.error)),
              ],
            ],
          ),
          AppSpacing.vSpaceXs,
        ],
        if (child != null)
          child!
        else
          AppInput(
            label: label,
            hint: placeholder,
            placeholder: placeholder,
            controller: controller,
            onChanged: onChanged,
            validator: validator,
            enabled: enabled,
          ),
      ],
    );
  }
}
