import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../components/atoms/app_button.dart';
import '../components/organisms/loading_widgets.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/image_compression.dart';
import '../core/theme/theme_manager.dart';
import '../services/auth_service.dart';
import 'theme_selector_screen_new.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _username = 'demo';
  String? _profilePhotoPath;
  bool _notificationsEnabled = false;
  bool _isPickingPhoto = false;

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
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).colorScheme.onPrimary,
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
              if (value) {
                // Show test notification when enabled
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Notifications Enabled',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Test: You\'ll receive reminders!',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                AppErrorHandler.showInfoSnackBar(
                  context,
                  'Notifications disabled',
                );
              }
            },
            activeColor: Theme.of(context).colorScheme.primary,
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
        Consumer<ThemeManager>(
          builder: (context, themeManager, child) {
            return _buildSettingsTile(
              icon: Icons.palette,
              title: 'Theme & Appearance',
              subtitle: '${themeManager.currentTheme.name} • ${themeManager.isDarkMode ? 'Dark Mode' : 'Light Mode'}',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textTertiary),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeSelectorScreen(),
                  ),
                );
              },
            );
          },
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
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
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
        ElevatedButton.icon(
          onPressed: _logOut,
          icon: const Icon(Icons.logout),
          label: const Text('Log Out'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            minimumSize: const Size(double.infinity, 50),
          ),
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
      // Check if already picking to avoid "already_active" error
      if (_isPickingPhoto) return;

      setState(() => _isPickingPhoto = true);

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      setState(() => _isPickingPhoto = false);

      if (image != null) {
        setState(() {
          _profilePhotoPath = image.path;
        });

        AppErrorHandler.showSuccessSnackBar(
          context,
          'Profile photo updated!',
        );
      }
    } catch (e) {
      setState(() => _isPickingPhoto = false);
      // Handle error gracefully - this is a local-only app
      AppErrorHandler.showInfoSnackBar(
        context,
        'Photo selection: ${e.toString().split(':').first}',
      );
    }
  }

  void _editProfile() {
    final TextEditingController nameController =
        TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _username = nameController.text;
              });
              Navigator.pop(context);
              AppErrorHandler.showSuccessSnackBar(
                context,
                'Profile updated!',
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    Navigator.pushNamed(context, '/settings/notifications');
  }

  void _showPaymentSettings() {
    Navigator.pushNamed(context, '/payment');
  }

  void _showThemeSettings() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Theme customization coming soon',
    );
  }

  void _showWallpaperSettings() {
    Navigator.pushNamed(context, '/settings/wallpaper');
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
    Navigator.pushNamed(context, '/settings/backup');
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

    if (confirmed == true) {
      try {
        final authService = context.read<AuthService>();
        await authService.logout();

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          AppErrorHandler.showErrorSnackBar(
            context,
            'Logout failed: ${e.toString()}',
          );
        }
      }
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
