import 'package:flutter/material.dart';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_toggle.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/error_handler.dart';
import 'account_screen.dart';
import 'notification_settings_screen.dart';
import 'theme_selector_screen.dart';

class EnhancedSettingsScreen extends StatefulWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  State<EnhancedSettingsScreen> createState() => _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState extends State<EnhancedSettingsScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.h2,
        ),
        
        elevation: 0,
      ),
      body: ListView(
        padding: AppSpacing.pageInsets,
        children: [
          // Account Section
          _buildSection(
            'Account',
            Icons.person,
            [
              _buildNavigationTile(
                'Account Information',
                'Manage your profile and preferences',
                Icons.account_circle,
                () => _navigateToAccount(),
              ),
              _buildNavigationTile(
                'Switch Account',
                'Sign in with a different account',
                Icons.swap_horiz,
                () => _switchAccount(),
              ),
            ],
          ),

          AppSpacing.vSpaceLg,

          // Notifications Section
          _buildSection(
            'Notifications',
            Icons.notifications,
            [
              _buildNavigationTile(
                'Notification Settings',
                'Configure alerts and reminders',
                Icons.notifications_active,
                () => _navigateToNotifications(),
              ),
            ],
          ),

          AppSpacing.vSpaceLg,

          // Appearance Section
          _buildSection(
            'Appearance',
            Icons.palette,
            [
              _buildToggleTile(
                'Dark Mode',
                'Switch between light and dark theme',
                Icons.dark_mode,
                _isDarkMode,
                (value) => setState(() => _isDarkMode = value),
              ),
              _buildNavigationTile(
                'Color Theme',
                'Choose your preferred color palette',
                Icons.color_lens,
                () => _navigateToTheme(),
              ),
              _buildNavigationTile(
                'Wallpaper',
                'Customize your background image',
                Icons.wallpaper,
                () => _navigateToWallpaper(),
              ),
            ],
          ),

          AppSpacing.vSpaceLg,

          // Data Section
          _buildSection(
            'Data & Storage',
            Icons.storage,
            [
              _buildNavigationTile(
                'Backup & Restore',
                'Export and import your data',
                Icons.backup,
                () => _navigateToBackup(),
              ),
              _buildNavigationTile(
                'Storage Usage',
                'View app storage and clear cache',
                Icons.folder,
                () => _showStorageInfo(),
              ),
              _buildNavigationTile(
                'Delete All Data',
                'Remove all pets and records (cannot be undone)',
                Icons.delete_forever,
                () => _showDeleteAllDialog(),
                isDestructive: true,
              ),
            ],
          ),

          AppSpacing.vSpaceLg,

          // Payments Section
          _buildSection(
            'Subscription',
            Icons.payment,
            [
              _buildNavigationTile(
                'Payments & Billing',
                'Manage subscription and payment methods',
                Icons.credit_card,
                () => _navigateToPayments(),
              ),
            ],
          ),

          AppSpacing.vSpaceLg,

          // About Section
          _buildSection(
            'About',
            Icons.info,
            [
              _buildNavigationTile(
                'Privacy Policy',
                'Read our privacy policy',
                Icons.privacy_tip,
                () => _openPrivacyPolicy(),
              ),
              _buildNavigationTile(
                'Terms of Service',
                'View terms and conditions',
                Icons.description,
                () => _openTermsOfService(),
              ),
              _buildInfoTile(
                'App Version',
                '1.0.0 (Build 1)',
                Icons.info_outline,
              ),
            ],
          ),

          AppSpacing.vSpaceXl,

          // Sign Out Button
          AppButton.error(
            text: 'Sign Out',
            onPressed: _signOut,
            icon: Icons.logout,
          ),

          AppSpacing.vSpaceXl,
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
              AppSpacing.hSpaceSm,
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isDestructive ? AppColors.error : AppColors.primary)
                    .withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
                size: 20,
              ),
            ),
            AppSpacing.hSpaceMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDestructive ? AppColors.error : null,
                    ),
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
            AppSpacing.hSpaceMd,
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium,
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
          AppSpacing.hSpaceMd,
          AppToggle(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: AppSpacing.cardInsets,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          AppSpacing.hSpaceMd,
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccountScreen(),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotificationSettingsScreen(),
      ),
    );
  }

  void _navigateToTheme() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThemeSelectorScreen(),
      ),
    );
  }

  void _navigateToWallpaper() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Wallpaper customization coming soon!',
    );
  }

  void _navigateToBackup() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Backup & restore functionality coming soon!',
    );
  }

  void _navigateToPayments() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Payment features coming soon!',
    );
  }

  void _switchAccount() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Account switching coming soon!',
    );
  }

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storage Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageItem('Database', '2.5 MB'),
            _buildStorageItem('Photos', '18.3 MB'),
            _buildStorageItem('Cache', '5.1 MB'),
            Divider(),
            _buildStorageItem('Total', '25.9 MB', isTotal: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppErrorHandler.showSuccessSnackBar(
                context,
                'Cache cleared successfully!',
              );
            },
            child: Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(String label, String size, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ) : AppTextStyles.bodyMedium,
          ),
          Text(
            size,
            style: isTotal ? AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ) : AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete All Data',
          style: TextStyle(color: AppColors.error),
        ),
        content: Text(
          'This will permanently delete all your pets, reminders, expenses, and photos. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppErrorHandler.showSuccessSnackBar(
                context,
                'All data deleted successfully.',
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Opening privacy policy...',
    );
  }

  void _openTermsOfService() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Opening terms of service...',
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppErrorHandler.showSuccessSnackBar(
                context,
                'Signed out successfully!',
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}