import 'package:flutter/material.dart';

import '../components/atoms/app_badge.dart';
import '../components/atoms/app_button.dart';
import '../components/molecules/app_search_bar.dart';
import '../../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';
import 'reminder_form_screen.dart';

class RemindersListScreen extends StatefulWidget {
  final String? petId;

  const RemindersListScreen({
    super.key,
    this.petId,
  });

  @override
  State<RemindersListScreen> createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> with SingleTickerProviderStateMixin {
  final _reminderRepository = ReminderRepository();
  final _petRepository = PetRepository();
  
  late TabController _tabController;
  List<Reminder> _allReminders = [];
  List<Pet> _pets = [];
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _isLoading = true;

  final List<String> _categories = [
    'all',
    'medication',
    'vet',
    'grooming',
    'feeding',
    'exercise',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final reminders = widget.petId != null
          ? await _reminderRepository.getPetReminders(widget.petId!)
          : await _reminderRepository.getUserReminders('user-1');
      
      final pets = await _petRepository.getUserPets('user-1');
      
      setState(() {
        _allReminders = reminders;
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Upcoming'),
                  AppSpacing.hSpaceXs,
                  _buildTabBadge(_getUpcomingCount()),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Overdue'),
                  AppSpacing.hSpaceXs,
                  _buildTabBadge(_getOverdueCount()),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Completed'),
                  AppSpacing.hSpaceXs,
                  _buildTabBadge(_getCompletedCount()),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: AppSpacing.pageInsets,
            child: Column(
              children: [
                AppSearchBar(
                  placeholder: 'Search reminders...',
                  onChanged: (query) => setState(() => _searchQuery = query),
                ),
                AppSpacing.vSpaceMd,
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(_capitalizeFirst(category)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                          },
                          
                          selectedColor: AppColors.primary.withOpacity(0.1),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRemindersList(_getUpcomingReminders()),
                      _buildRemindersList(_getOverdueReminders()),
                      _buildRemindersList(_getCompletedReminders()),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildTabBadge(int count) {
    if (count == 0) return SizedBox.shrink();
    
    return AppBadge(
      text: count.toString(),
      type: BadgeType.primary,
    );
  }

  Widget _buildRemindersList(List<Reminder> reminders) {
    final filteredReminders = _filterReminders(reminders);

    if (filteredReminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceMd,
            Text(
              'No reminders found',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Create a new reminder to get started',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.pageInsets,
      itemCount: filteredReminders.length,
      itemBuilder: (context, index) {
        return _buildReminderCard(filteredReminders[index]);
      },
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final pet = _pets.firstWhere(
      (p) => p.id == reminder.petId,
      orElse: () => Pet(
        id: '',
        name: 'Unknown Pet',
        species: '',
        breed: '',
        birthDate: DateTime.now(),
        userId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final isOverdue = reminder.dateTime.isBefore(DateTime.now()) && !reminder.isCompleted;

    return Dismissible(
      key: Key(reminder.id),
      direction: reminder.isCompleted ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        color: AppColors.success,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.lg),
        child: Icon(
          Icons.check,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          size: 32,
        ),
      ),
      onDismissed: (direction) => _markComplete(reminder),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isOverdue ? AppColors.error.withOpacity(0.3) : AppColors.border,
            width: isOverdue ? 2 : 1,
          ),
          boxShadow: isOverdue
              ? [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: () => _editReminder(reminder),
          borderRadius: AppSpacing.borderRadiusMd,
          child: Padding(
            padding: AppSpacing.cardInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reminder.title,
                        style: AppTextStyles.h4.copyWith(
                          decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                          color: reminder.isCompleted ? AppColors.textSecondary : null,
                        ),
                      ),
                    ),
                    AppSpacing.hSpaceSm,
                    AppBadge(
                      text: _capitalizeFirst(reminder.priority),
                      type: _getPriorityBadgeType(reminder.priority),
                    ),
                  ],
                ),

                if (reminder.description != null) ...[
                  AppSpacing.vSpaceSm,
                  Text(
                    reminder.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],

                AppSpacing.vSpaceMd,

                Row(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    AppSpacing.hSpaceXs,
                    Text(
                      pet.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.hSpaceMd,
                    Icon(
                      Icons.category,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    AppSpacing.hSpaceXs,
                    Text(
                      _capitalizeFirst(reminder.category),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                AppSpacing.vSpaceSm,

                Row(
                  children: [
                    Icon(
                      isOverdue ? Icons.schedule : Icons.access_time,
                      size: 16,
                      color: isOverdue ? AppColors.error : AppColors.textSecondary,
                    ),
                    AppSpacing.hSpaceXs,
                    Text(
                      _formatDateTime(reminder.dateTime),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isOverdue ? AppColors.error : AppColors.textSecondary,
                        fontWeight: isOverdue ? FontWeight.w600 : null,
                      ),
                    ),
                    AppSpacing.hSpaceMd,
                    Icon(
                      Icons.repeat,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    AppSpacing.hSpaceXs,
                    Text(
                      _capitalizeFirst(reminder.frequency),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (!reminder.isCompleted) ...[
                      Spacer(),
                      GestureDetector(
                        onTap: () => _markComplete(reminder),
                        child: Container(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Reminder> _filterReminders(List<Reminder> reminders) {
    return reminders.where((reminder) {
      final matchesSearch = _searchQuery.isEmpty ||
          reminder.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (reminder.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesCategory = _selectedCategory == 'all' || reminder.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<Reminder> _getUpcomingReminders() {
    return _allReminders.where((reminder) =>
        !reminder.isCompleted && 
        reminder.dateTime.isAfter(DateTime.now())
    ).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Reminder> _getOverdueReminders() {
    return _allReminders.where((reminder) =>
        !reminder.isCompleted && 
        reminder.dateTime.isBefore(DateTime.now())
    ).toList()..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  List<Reminder> _getCompletedReminders() {
    return _allReminders.where((reminder) => reminder.isCompleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  int _getUpcomingCount() => _getUpcomingReminders().length;
  int _getOverdueCount() => _getOverdueReminders().length;
  int _getCompletedCount() => _getCompletedReminders().length;

  BadgeType _getPriorityBadgeType(String priority) {
    switch (priority) {
      case 'high':
        return BadgeType.error;
      case 'medium':
        return BadgeType.warning;
      case 'low':
        return BadgeType.success;
      default:
        return BadgeType.primary;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (reminderDate == today) {
      dateStr = 'Today';
    } else if (reminderDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr = TimeOfDay.fromDateTime(dateTime).format(context);
    return '$dateStr at $timeStr';
  }

  String _capitalizeFirst(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _addReminder() async {
    if (widget.petId == null && _pets.isEmpty) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Please add a pet first before creating reminders',
      );
      return;
    }

    final petId = widget.petId ?? _pets.first.id;
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReminderFormScreen(petId: petId),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _editReminder(Reminder reminder) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReminderFormScreen(
          reminder: reminder,
          petId: reminder.petId,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _markComplete(Reminder reminder) async {
    try {
      final updatedReminder = reminder.copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
      );
      
      await _reminderRepository.updateReminder(updatedReminder);
      _loadData();
      
      AppErrorHandler.showSuccessSnackBar(
        context,
        'Reminder marked as complete!',
      );
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to update reminder: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}