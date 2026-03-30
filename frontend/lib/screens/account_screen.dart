import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../components/atoms/app_button.dart';
import '../components/organisms/loading_widgets.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/image_compression.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _username = 'demo';
  String? _profilePhotoPath;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Account',
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: AppSpacing.pageInsets,
        children: [
          // Profile section
          _buildProfileSection(),
          
          AppSpacing.vSpaceLg,
          
          // Settings sections
          _buildSettingsSection(),
          
          AppSpacing.vSpaceLg,
          
          // Account actions
          _buildAccountActions(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile photo
          GestureDetector(
            onTap: _pickProfilePhoto,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: _profilePhotoPath != null
                        ? Image.file(
                            File(_profilePhotoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildAvatarPlaceholder();
                            },
                          )
                        : _buildAvatarPlaceholder(),
                  ),
                ),
                
                // Edit overlay
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.textOnPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          AppSpacing.vSpaceMd,
          
          // Username
          Text(
            _username,
            style: AppTextStyles.h2,
          ),
          
          AppSpacing.vSpaceXs,
          
          Text(
            'Local User Account',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          AppSpacing.vSpaceMd,
          
          AppButton.outlined(
            text: 'Edit Profile',
            onPressed: _editProfile,
            icon: Icons.edit,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Icon(
        Icons.person,
        size: 48,
        color: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        // Notifications
        _buildSettingsTile(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Reminder alerts and updates',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              AppErrorHandler.showSuccessSnackBar(
                context,
                'Notification settings updated',
              );
            },
            activeColor: AppColors.primary,
          ),
          onTap: () => _showNotificationSettings(),
        ),
        
        // Payments & Subscription
        _buildSettingsTile(
          icon: Icons.payment,
          title: 'Payments & Subscription',
          subtitle: 'Manage billing and plans',
          trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
          onTap: () => _showPaymentSettings(),
        ),
        
        // Theme
        _buildSettingsTile(
          icon: Icons.palette,
          title: 'Appearance',
          subtitle: _isDarkMode ? 'Dark mode' : 'Light mode',
          trailing: Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() => _isDarkMode = value);
              AppErrorHandler.showInfoSnackBar(
                context,
                'Theme switching coming soon',
              );
            },
            activeColor: AppColors.primary,
          ),
          onTap: () => _showThemeSettings(),
        ),
        
        // Wallpaper
        _buildSettingsTile(
          icon: Icons.wallpaper,
          title: 'Wallpaper',
          subtitle: 'Set pet photo as wallpaper',
          trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
          onTap: () => _showWallpaperSettings(),
        ),
        
        // Privacy & Policy
        _buildSettingsTile(
          icon: Icons.privacy_tip,
          title: 'Privacy & Policy',
          subtitle: 'Terms and privacy information',
          trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
          onTap: () => _showPrivacyPolicy(),
        ),
        
        // Backup & Restore
        _buildSettingsTile(
          icon: Icons.backup,
          title: 'Backup & Restore',
          subtitle: 'Export or import your data',
          trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
          onTap: () => _showBackupRestore(),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusMd,
          child: Padding(
            padding: AppSpacing.cardInsets,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                
                AppSpacing.hSpaceMd,
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h4,
                      ),
                      AppSpacing.vSpaceXs,
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                AppSpacing.hSpaceSm,
                
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        // Switch Account
        AppButton.outlined(
          text: 'Switch Account',
          onPressed: _switchAccount,
          icon: Icons.switch_account,
        ),
        
        AppSpacing.vSpaceMd,
        
        // Log Out
        AppButton.outlined(
          text: 'Log Out',
          onPressed: _logOut,
          icon: Icons.logout,
          backgroundColor: AppColors.error.withOpacity(0.1),
          borderColor: AppColors.error,
          textColor: AppColors.error,
        ),
        
        AppSpacing.vSpaceXl,
        
        // App info
        Column(
          children: [
            Text(
              'Pet Care App',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            AppSpacing.vSpaceXs,
            Text(
              'Version 1.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        final compressedFile = await ImageCompressionUtil.compressImageFromPath(
          image.path
        );
        
        setState(() {
          _profilePhotoPath = compressedFile.path;
        });
        
        AppErrorHandler.showSuccessSnackBar(
          context,
          'Profile photo updated!',
        );
      }
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to update profile photo: ${e.toString()}',
      );
    }
  }

  void _editProfile() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Profile editing coming soon',
    );
  }

  void _showNotificationSettings() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Detailed notification settings coming soon',
    );
  }

  void _showPaymentSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payments & Subscription'),
        content: Text(
          'This is a local-only app. No payment or subscription features are currently available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showThemeSettings() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Theme customization coming soon',
    );
  }

  void _showWallpaperSettings() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Wallpaper settings coming soon',
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy & Policy'),
        content: SingleChildScrollView(
          child: Text(
            '''Pet Care App Privacy Policy

Data Storage:
• All data is stored locally on your device
• No data is transmitted to external servers
• Photos and personal information remain private

Permissions:
• Camera: For taking pet photos
• Storage: For saving photos and backups
• Notifications: For reminders (optional)

Contact:
For questions about this privacy policy, please contact support.

This policy was last updated: March 2026''',
            style: AppTextStyles.bodySmall,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBackupRestore() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Backup & restore functionality coming soon',
    );
  }

  void _switchAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Switch Account'),
        content: Text(
          'This is a local-only app with single-user support. Multiple accounts are not currently available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _logOut() async {
    final confirmed = await AppErrorHandler.showConfirmDialog(
      context,
      'Log Out',
      'Are you sure you want to log out? Make sure to backup your data first.',
    );
    
    if (confirmed) {
      // TODO: Clear local data and navigate to login
      AppErrorHandler.showInfoSnackBar(
        context,
        'Logout functionality coming soon',
      );
    }
  }
}

// Floating account button for other screens
class AccountFloatingButton extends StatelessWidget {
  const AccountFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppSpacing.lg,
      right: AppSpacing.lg,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AccountScreen(),
            ),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.account_circle,
            color: AppColors.textOnPrimary,
            size: 32,
          ),
        ),
      ),
    );
  }
}