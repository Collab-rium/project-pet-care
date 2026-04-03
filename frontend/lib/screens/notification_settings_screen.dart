import 'package:flutter/material.dart';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_toggle.dart';
import '../components/molecules/app_form_field.dart';
import '../../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/error_handler.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _remindersEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _medicationReminders = true;
  bool _vetAppointments = true;
  bool _feedingReminders = true;
  bool _groomingReminders = true;
  bool _exerciseReminders = false;
  bool _weightReminders = false;

  TimeOfDay _quietStart = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = TimeOfDay(hour: 8, minute: 0);
  bool _quietHoursEnabled = true;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: AppTextStyles.h2,
        ),
        
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.pageInsets,
        children: [
          // General settings
          _buildSection(
            'General Settings',
            [
              _buildToggleItem(
                'Enable Notifications',
                'Allow the app to send notifications',
                _remindersEnabled,
                (value) => setState(() => _remindersEnabled = value),
              ),
              _buildToggleItem(
                'Sound',
                'Play notification sounds',
                _soundEnabled,
                (value) => setState(() => _soundEnabled = value),
                enabled: _remindersEnabled,
              ),
              _buildToggleItem(
                'Vibration',
                'Vibrate on notifications',
                _vibrationEnabled,
                (value) => setState(() => _vibrationEnabled = value),
                enabled: _remindersEnabled,
              ),
            ],
          ),

          AppSpacing.vSpaceLg,

          // Reminder types
          _buildSection(
            'Reminder Types',
            [
              _buildToggleItem(
                'Medication Reminders',
                'Get notified for medication times',
                _medicationReminders,
                (value) => setState(() => _medicationReminders = value),
                enabled: _remindersEnabled,
              ),
              _buildToggleItem(
                'Vet Appointments',
                'Reminders for vet visits',
                _vetAppointments,
                (value) => setState(() => _vetAppointments = value),
                enabled: _remindersEnabled,
              ),
              _buildToggleItem(
                'Feeding Times',
                'Regular feeding reminders',
                _feedingReminders,
                (value) => setState(() => _feedingReminders = value),
                enabled: _remindersEnabled,
              ),
              _buildToggleItem(
                'Grooming',
                'Grooming appointment reminders',
                _groomingReminders,
                (value) => setState(() => _groomingReminders = value),
                enabled: _remindersEnabled,
              ),
              _buildToggleItem(
                'Exercise',
                'Daily exercise reminders',
                _exerciseReminders,
                (value) => setState(() => _exerciseReminders = value),
                enabled: _remindersEnabled,
              ),
              _buildToggleItem(
                'Weight Tracking',
                'Reminder to record pet weight',
                _weightReminders,
                (value) => setState(() => _weightReminders = value),
                enabled: _remindersEnabled,
              ),
            ],
          ),

          AppSpacing.vSpaceLg,

          // Quiet hours
          _buildSection(
            'Quiet Hours',
            [
              _buildToggleItem(
                'Enable Quiet Hours',
                'Silence notifications during specified hours',
                _quietHoursEnabled,
                (value) => setState(() => _quietHoursEnabled = value),
                enabled: _remindersEnabled,
              ),
              if (_quietHoursEnabled && _remindersEnabled) ...[
                _buildTimePickerItem(
                  'Start Time',
                  'When quiet hours begin',
                  _quietStart,
                  (time) => setState(() => _quietStart = time),
                ),
                _buildTimePickerItem(
                  'End Time',
                  'When quiet hours end',
                  _quietEnd,
                  (time) => setState(() => _quietEnd = time),
                ),
              ],
            ],
          ),

          AppSpacing.vSpaceLg,

          // Test notifications
          _buildSection(
            'Test',
            [
              Container(
                padding: AppSpacing.cardInsets,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Notifications',
                      style: AppTextStyles.h4,
                    ),
                    AppSpacing.vSpaceXs,
                    Text(
                      'Send a test notification to check your settings',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.vSpaceMd,
                    AppButton.outlined(
                      text: 'Send Test Notification',
                      onPressed:
                          _remindersEnabled ? _sendTestNotification : null,
                      icon: Icons.notifications_active,
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.vSpaceXl,

          // Warning about permissions
          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: AppColors.warning,
                  size: 20,
                ),
                AppSpacing.hSpaceSm,
                Expanded(
                  child: Text(
                    'Make sure notification permissions are enabled in your device settings for the best experience.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h3,
        ),
        AppSpacing.vSpaceMd,
        ...children,
      ],
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: enabled ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                AppSpacing.vSpaceXs,
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: enabled
                        ? AppColors.textSecondary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hSpaceMd,
          AppToggle(
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerItem(
    String title,
    String subtitle,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
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
          AppSpacing.hSpaceMd,
          GestureDetector(
            onTap: () => _selectTime(time, onChanged),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Text(
                time.format(context),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(
      TimeOfDay currentTime, ValueChanged<TimeOfDay> onChanged) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  void _sendTestNotification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Test Notification'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Care Reminder',
              style: AppTextStyles.h4,
            ),
            SizedBox(height: 8),
            Text(
              'This is a test notification from your Pet Care app. Your notifications are working!',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Time: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Dismiss'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              AppErrorHandler.showSuccessSnackBar(
                context,
                'Notification received!',
              );
            },
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() async {
    // Save settings to SharedPreferences
    // In a real app, you would save all the notification preferences
    AppErrorHandler.showSuccessSnackBar(
      context,
      'Notification settings saved successfully!',
    );
    Navigator.of(context).pop();
  }
}
