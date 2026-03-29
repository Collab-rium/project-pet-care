import 'package:flutter/material.dart';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_dropdown.dart';
import '../components/atoms/app_input.dart';
import '../components/atoms/app_toggle.dart';
import '../components/molecules/app_form_field.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/validators.dart';

class ReminderFormScreen extends StatefulWidget {
  final Reminder? reminder;
  final String petId;

  const ReminderFormScreen({
    super.key,
    this.reminder,
    required this.petId,
  });

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reminderRepository = ReminderRepository();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _frequency = 'once';
  String _category = 'medication';
  String _priority = 'medium';
  bool _notificationEnabled = true;
  bool _isLoading = false;

  final List<String> _frequencies = [
    'once',
    'daily',
    'weekly',
    'monthly',
    'yearly',
  ];

  final List<String> _categories = [
    'medication',
    'vet',
    'grooming',
    'feeding',
    'exercise',
    'other',
  ];

  final List<String> _priorities = [
    'low',
    'medium',
    'high',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _loadReminderData();
    }
  }

  void _loadReminderData() {
    final reminder = widget.reminder!;
    _titleController.text = reminder.title;
    _descriptionController.text = reminder.description ?? '';
    _selectedDate = reminder.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(reminder.dateTime);
    _frequency = reminder.frequency;
    _category = reminder.category;
    _priority = reminder.priority;
    _notificationEnabled = reminder.notificationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.reminder == null ? 'Add Reminder' : 'Edit Reminder',
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (widget.reminder != null)
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: _deleteReminder,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.pageInsets,
          children: [
            AppFormField(
              label: 'Title',
              child: AppInput(
                controller: _titleController,
                placeholder: 'e.g., Give medication to Max',
                validator: AppValidators.required,
              ),
            ),

            AppSpacing.vSpaceLg,

            AppFormField(
              label: 'Description (optional)',
              child: AppInput(
                controller: _descriptionController,
                placeholder: 'Additional details...',
                maxLines: 3,
              ),
            ),

            AppSpacing.vSpaceLg,

            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    label: 'Date',
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            AppSpacing.hSpaceSm,
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                AppSpacing.hSpaceMd,
                Expanded(
                  child: AppFormField(
                    label: 'Time',
                    child: GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            AppSpacing.hSpaceSm,
                            Text(
                              _selectedTime.format(context),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.vSpaceLg,

            AppFormField(
              label: 'Frequency',
              child: AppDropdown<String>(
                value: _frequency,
                items: _frequencies.map((freq) => DropdownMenuItem(
                  value: freq,
                  child: Text(_capitalizeFirst(freq)),
                )).toList(),
                onChanged: (value) => setState(() => _frequency = value!),
              ),
            ),

            AppSpacing.vSpaceLg,

            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    label: 'Category',
                    child: AppDropdown<String>(
                      value: _category,
                      items: _categories.map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(_capitalizeFirst(cat)),
                      )).toList(),
                      onChanged: (value) => setState(() => _category = value!),
                    ),
                  ),
                ),
                AppSpacing.hSpaceMd,
                Expanded(
                  child: AppFormField(
                    label: 'Priority',
                    child: AppDropdown<String>(
                      value: _priority,
                      items: _priorities.map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(_capitalizeFirst(priority)),
                      )).toList(),
                      onChanged: (value) => setState(() => _priority = value!),
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.vSpaceLg,

            Container(
              padding: AppSpacing.cardInsets,
              decoration: BoxDecoration(
                color: AppColors.surface,
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
                          'Enable Notifications',
                          style: AppTextStyles.h4,
                        ),
                        AppSpacing.vSpaceXs,
                        Text(
                          'Get notified at the scheduled time',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hSpaceMd,
                  AppToggle(
                    value: _notificationEnabled,
                    onChanged: (value) => setState(() => _notificationEnabled = value),
                  ),
                ],
              ),
            ),

            AppSpacing.vSpaceXl,

            AppButton.primary(
              text: widget.reminder == null ? 'Add Reminder' : 'Update Reminder',
              onPressed: _isLoading ? null : _saveReminder,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final reminder = Reminder(
        id: widget.reminder?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        dateTime: dateTime,
        frequency: _frequency,
        category: _category,
        priority: _priority,
        notificationEnabled: _notificationEnabled,
        petId: widget.petId,
        isCompleted: widget.reminder?.isCompleted ?? false,
        createdAt: widget.reminder?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.reminder == null) {
        await _reminderRepository.createReminder(reminder);
        AppErrorHandler.showSuccessSnackBar(
          context,
          'Reminder added successfully!',
        );
      } else {
        await _reminderRepository.updateReminder(reminder);
        AppErrorHandler.showSuccessSnackBar(
          context,
          'Reminder updated successfully!',
        );
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to save reminder: ${e.toString()}',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReminder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Reminder'),
        content: Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.reminder != null) {
      try {
        await _reminderRepository.deleteReminder(widget.reminder!.id);
        AppErrorHandler.showSuccessSnackBar(
          context,
          'Reminder deleted successfully!',
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        AppErrorHandler.showErrorSnackBar(
          context,
          'Failed to delete reminder: ${e.toString()}',
        );
      }
    }
  }

  String _capitalizeFirst(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}