import 'package:flutter/material.dart';
import '../components/molecules/app_form_field.dart';
import '../components/atoms/app_input.dart';
import '../components/atoms/app_dropdown.dart';
import '../components/atoms/app_button.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/validators.dart';
import 'dart:math';

class RemindersScreen extends StatefulWidget {
  final String? initialFilter;

  const RemindersScreen({super.key, this.initialFilter});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _reminderRepository = ReminderRepository();
  final _petRepository = PetRepository();
  
  List<Reminder> _reminders = [];
  List<Pet> _pets = [];
  bool _isLoading = true;
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter ?? 'all';
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      final reminders = await _reminderRepository.getUserReminders('user-1');
      final pets = await _petRepository.getUserPets('user-1');
      
      setState(() {
        _reminders = reminders;
        _pets = pets;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to load reminders: ${e.toString()}',
      );
      setState(() => _isLoading = false);
    }
  }

  List<Reminder> get _filteredReminders {
    switch (_currentFilter) {
      case 'completed':
        return _reminders.where((r) => r.isCompleted).toList();
      case 'pending':
        return _reminders.where((r) => !r.isCompleted && !r.isOverdue).toList();
      case 'overdue':
        return _reminders.where((r) => r.isOverdue).toList();
      case 'today':
        return _reminders.where((r) => r.isToday && !r.isCompleted).toList();
      default:
        return _reminders;
    }
  }

  Future<void> _toggleReminderCompleted(Reminder reminder) async {
    try {
      final updatedReminder = Reminder(
        id: reminder.id,
        userId: reminder.userId,
        petId: reminder.petId,
        title: reminder.title,
        description: reminder.description,
        reminderType: reminder.reminderType,
        reminderDate: reminder.reminderDate,
        isCompleted: !reminder.isCompleted,
        notes: reminder.notes,
        createdAt: reminder.createdAt,
        updatedAt: DateTime.now(),
      );

      await _reminderRepository.updateReminder(updatedReminder);
      await _loadData();
      
      AppErrorHandler.showSuccessSnackBar(
        context,
        reminder.isCompleted ? 'Reminder marked as pending' : 'Reminder completed!',
      );
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to update reminder: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Reminders',
          style: AppTextStyles.h2,
        ),
        
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddReminderDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  _buildFilterChip('today', 'Today'),
                  _buildFilterChip('pending', 'Pending'),
                  _buildFilterChip('overdue', 'Overdue'),
                  _buildFilterChip('completed', 'Completed'),
                ],
              ),
            ),
          ),
          
          // Reminders list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildRemindersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _currentFilter == value;
    
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _currentFilter = value;
          });
        },
        
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildRemindersList() {
    final filteredReminders = _filteredReminders;
    
    if (filteredReminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceMd,
            Text(
              _getEmptyMessage(),
              style: AppTextStyles.h3,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Create a reminder to get started',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vSpaceMd,
            AppButton.primary(
              text: 'Add Reminder',
              onPressed: _showAddReminderDialog,
              icon: Icons.add,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: AppSpacing.pageInsets,
      itemCount: filteredReminders.length,
      itemBuilder: (context, index) {
        final reminder = filteredReminders[index];
        return _buildReminderCard(reminder);
      },
    );
  }

  String _getEmptyMessage() {
    switch (_currentFilter) {
      case 'today':
        return 'No reminders for today';
      case 'pending':
        return 'No pending reminders';
      case 'overdue':
        return 'No overdue reminders';
      case 'completed':
        return 'No completed reminders';
      default:
        return 'No reminders yet';
    }
  }

  Widget _buildReminderCard(Reminder reminder) {
    final pet = _pets.firstWhere(
      (p) => p.id == reminder.petId,
      orElse: () => Pet(
        id: '',
        userId: '',
        name: 'Unknown Pet',
        species: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    Color cardColor = Theme.of(context).colorScheme.surface;
    Color accentColor = AppColors.primary;
    
    if (reminder.isCompleted) {
      accentColor = AppColors.success;
    } else if (reminder.isOverdue) {
      accentColor = AppColors.error;
      cardColor = AppColors.error.withOpacity(0.05);
    } else if (reminder.isToday) {
      accentColor = AppColors.warning;
      cardColor = AppColors.warning.withOpacity(0.05);
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: reminder.isOverdue ? AppColors.error.withOpacity(0.3) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleReminderCompleted(reminder),
          borderRadius: AppSpacing.borderRadiusMd,
          child: Padding(
            padding: AppSpacing.cardInsets,
            child: Row(
              children: [
                // Checkbox/status icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Icon(
                    reminder.isCompleted
                        ? Icons.check_circle
                        : reminder.isOverdue
                            ? Icons.warning
                            : Icons.schedule,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                
                AppSpacing.hSpaceMd,
                
                // Reminder details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: AppTextStyles.h4.copyWith(
                          decoration: reminder.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: reminder.isCompleted 
                              ? AppColors.textTertiary 
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      AppSpacing.vSpaceXs,
                      
                      Row(
                        children: [
                          Text(
                            pet.name,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' • ${reminder.reminderType}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      
                      AppSpacing.vSpaceXs,
                      
                      Text(
                        _formatReminderDate(reminder),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: reminder.isOverdue 
                              ? AppColors.error 
                              : AppColors.textTertiary,
                        ),
                      ),
                      
                      if (reminder.description != null) ...[
                        AppSpacing.vSpaceXs,
                        Text(
                          reminder.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Action button
                IconButton(
                  icon: Icon(
                    reminder.isCompleted ? Icons.undo : Icons.check,
                    color: accentColor,
                    size: 20,
                  ),
                  onPressed: () => _toggleReminderCompleted(reminder),
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatReminderDate(Reminder reminder) {
    final now = DateTime.now();
    final reminderDate = reminder.reminderDate;
    final difference = reminderDate.difference(now);
    
    if (reminder.isToday) {
      return 'Today at ${reminderDate.hour.toString().padLeft(2, '0')}:${reminderDate.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 0) {
      final daysPast = -difference.inDays;
      return '$daysPast day${daysPast > 1 ? 's' : ''} overdue';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days';
    } else {
      return '${reminderDate.day}/${reminderDate.month}/${reminderDate.year}';
    }
  }

  void _showAddReminderDialog() {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Add reminder functionality coming soon',
    );
  }
}