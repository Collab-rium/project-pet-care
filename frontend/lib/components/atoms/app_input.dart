import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';

/// Reusable input field component
/// Supports text, number, email, password, multiline
class AppInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? placeholder;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;

  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.placeholder,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.showCounter = false,
  });

  /// Text input
  factory AppInput.text({
    String? label,
    String? hint,
    String? initialValue,
    TextEditingController? controller,
    String? errorText,
    String? helperText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return AppInput(
      label: label,
      hint: hint,
      initialValue: initialValue,
      controller: controller,
      keyboardType: TextInputType.text,
      errorText: errorText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onSuffixIconPressed: onSuffixIconPressed,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
    );
  }

  /// Email input
  factory AppInput.email({
    String? label,
    String? hint,
    String? initialValue,
    TextEditingController? controller,
    String? errorText,
    String? helperText,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return AppInput(
      label: label ?? 'Email',
      hint: hint ?? 'Enter email address',
      initialValue: initialValue,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      errorText: errorText,
      helperText: helperText,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
    );
  }

  /// Password input (with show/hide toggle)
  factory AppInput.password({
    String? label,
    String? hint,
    String? initialValue,
    TextEditingController? controller,
    String? errorText,
    String? helperText,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return AppInput(
      label: label ?? 'Password',
      hint: hint ?? 'Enter password',
      initialValue: initialValue,
      controller: controller,
      obscureText: true,
      prefixIcon: Icons.lock_outlined,
      suffixIcon: Icons.visibility_outlined,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
    );
  }

  /// Number input
  factory AppInput.number({
    String? label,
    String? hint,
    String? initialValue,
    TextEditingController? controller,
    String? errorText,
    String? helperText,
    IconData? prefixIcon,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
    bool allowDecimal = true,
  }) {
    return AppInput(
      label: label,
      hint: hint,
      initialValue: initialValue,
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      prefixIcon: prefixIcon,
      errorText: errorText,
      helperText: helperText,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      inputFormatters: [
        if (!allowDecimal) FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  /// Multiline text input
  factory AppInput.multiline({
    String? label,
    String? hint,
    String? initialValue,
    TextEditingController? controller,
    String? errorText,
    String? helperText,
    int maxLines = 4,
    int? maxLength,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return AppInput(
      label: label,
      hint: hint,
      initialValue: initialValue,
      controller: controller,
      keyboardType: TextInputType.multiline,
      maxLines: maxLines,
      maxLength: maxLength,
      errorText: errorText,
      helperText: helperText,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      showCounter: maxLength != null,
    );
  }

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late TextEditingController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue);
    _hasError = widget.errorText != null;
  }

  @override
  void didUpdateWidget(AppInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _hasError = widget.errorText != null;
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.label.copyWith(
              color: _hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          AppSpacing.vSpaceXs,
        ],
        TextFormField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          style: AppTextStyles.bodyLarge.copyWith(
            color: widget.enabled ? AppColors.textPrimary : AppColors.textTertiary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _hasError ? AppColors.error : AppColors.textSecondary,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      widget.suffixIcon,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: widget.onSuffixIconPressed,
                  )
                : null,
            errorText: widget.errorText,
            helperText: widget.helperText,
            errorMaxLines: 2,
            counterText: widget.showCounter ? null : '',
            filled: true,
            fillColor: widget.enabled
                ? AppColors.surface
                : AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

/// Password input with show/hide toggle
class _PasswordInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? errorText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  const _PasswordInput({
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.errorText,
    this.helperText,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppInput(
      label: widget.label,
      hint: widget.hint,
      initialValue: widget.initialValue,
      controller: widget.controller,
      obscureText: _obscureText,
      prefixIcon: Icons.lock_outlined,
      suffixIcon: _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      onSuffixIconPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
      errorText: widget.errorText,
      helperText: widget.helperText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      enabled: widget.enabled,
    );
  }
}
