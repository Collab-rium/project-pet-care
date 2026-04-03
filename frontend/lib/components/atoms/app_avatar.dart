import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';
import '../../core/theme/color_tokens_extension.dart';
import '../../core/theme/color_tokens.dart';

/// Avatar component for user/pet profile pictures
class AppAvatar extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final String? initials;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool showBorder;

  const AppAvatar({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.initials,
    this.size = 48,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.showBorder = false,
  });

  factory AppAvatar.small({
    String? imagePath,
    String? imageUrl,
    String? initials,
    VoidCallback? onTap,
  }) {
    return AppAvatar(
      imagePath: imagePath,
      imageUrl: imageUrl,
      initials: initials,
      size: AppSpacing.avatarSm,
      onTap: onTap,
    );
  }

  factory AppAvatar.medium({
    String? imagePath,
    String? imageUrl,
    String? initials,
    VoidCallback? onTap,
    bool showBorder = false,
  }) {
    return AppAvatar(
      imagePath: imagePath,
      imageUrl: imageUrl,
      initials: initials,
      size: AppSpacing.avatarMd,
      onTap: onTap,
      showBorder: showBorder,
    );
  }

  factory AppAvatar.large({
    String? imagePath,
    String? imageUrl,
    String? initials,
    VoidCallback? onTap,
    bool showBorder = false,
  }) {
    return AppAvatar(
      imagePath: imagePath,
      imageUrl: imageUrl,
      initials: initials,
      size: AppSpacing.avatarLg,
      onTap: onTap,
      showBorder: showBorder,
    );
  }

  factory AppAvatar.xlarge({
    String? imagePath,
    String? imageUrl,
    String? initials,
    VoidCallback? onTap,
    bool showBorder = false,
  }) {
    return AppAvatar(
      imagePath: imagePath,
      imageUrl: imageUrl,
      initials: initials,
      size: AppSpacing.avatarXl,
      onTap: onTap,
      showBorder: showBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorTokens;
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.primaryLight,
        border: showBorder
            ? Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 3,
              )
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: AppSpacing.elevationMd,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: _buildContent(colors),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildContent(ColorTokens colors) {
    // Try to show image from file path
    if (imagePath != null && imagePath!.isNotEmpty) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitials(colors),
        );
      }
    }

    // Try to show image from URL
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitials(colors),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildInitials(colors);
        },
      );
    }

    // Show initials or default icon
    return _buildInitials(colors);
  }

  Widget _buildInitials(ColorTokens colors) {
    if (initials != null && initials!.isNotEmpty) {
      return Center(
        child: Text(
          initials!.toUpperCase(),
          style: _getTextStyle().copyWith(
            color: textColor ?? AppColors.textOnPrimary,
          ),
        ),
      );
    }

    // Default icon
    return Center(
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: textColor ?? AppColors.textOnPrimary,
      ),
    );
  }

  TextStyle _getTextStyle() {
    if (size <= AppSpacing.avatarSm) {
      return AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600);
    } else if (size <= AppSpacing.avatarMd) {
      return AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600);
    } else if (size <= AppSpacing.avatarLg) {
      return AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600);
    } else {
      return AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700);
    }
  }
}
