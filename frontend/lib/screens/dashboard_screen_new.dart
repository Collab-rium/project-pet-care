import 'package:flutter/material.dart';

import '../components/atoms/app_button.dart';
import '../components/molecules/stat_card.dart';
import '../components/organisms/loading_widgets.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';
import 'reminders_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _reminderRepository = ReminderRepository();
  
  Map<String, int> _stats = {
    'completed': 0,
    'pending': 0,
    'overdue': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      setState(() => _isLoading = true);
      
      final stats = await _reminderRepository.getDashboardStats('user-1'); // TODO: Get from auth
      
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to load dashboard stats: ${e.toString()}',
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToReminders({String? filter}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RemindersScreen(initialFilter: filter),
      ),
    );
    
    // Refresh stats when returning from reminders
    if (result != null) {
      _loadDashboardStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: AppTextStyles.h1,
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardStats,
        child: _isLoading
            ? const DashboardLoadingSkeleton()
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: AppSpacing.pageInsets,
      children: [
        // Welcome section
        Container(
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Icon(
                  Icons.pets,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.hSpaceMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: AppTextStyles.h2,
                    ),
                    AppSpacing.vSpaceXs,
                    Text(
                      'Keep track of your pets\' health and activities',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        AppSpacing.vSpaceLg,
        
        // Stats cards
        Text(
          'Reminders Overview',
          style: AppTextStyles.h2,
        ),
        AppSpacing.vSpaceMd,
        
        _buildStatsCards(),
        
        AppSpacing.vSpaceLg,
        
        // Quick actions
        Text(
          'Quick Actions',
          style: AppTextStyles.h2,
        ),
        AppSpacing.vSpaceMd,
        
        _buildQuickActions(),
        
        AppSpacing.vSpaceLg,
        
        // Recent activity placeholder
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
                'Recent Activity',
                style: AppTextStyles.h3,
              ),
              AppSpacing.vSpaceMd,
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.timeline,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                    AppSpacing.vSpaceSm,
                    Text(
                      'Activity feed coming soon',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        // Completed card
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToReminders(filter: 'completed'),
            child: StatCard(
              title: 'Completed',
              value: _stats['completed'].toString(),
              icon: Icons.check_circle,
              color: AppColors.success,
              backgroundColor: AppColors.success.withOpacity(0.1),
            ),
          ),
        ),
        
        AppSpacing.hSpaceSm,
        
        // Pending card
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToReminders(filter: 'pending'),
            child: StatCard(
              title: 'Pending',
              value: _stats['pending'].toString(),
              icon: Icons.pending,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ),
        
        AppSpacing.hSpaceSm,
        
        // Overdue card
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToReminders(filter: 'overdue'),
            child: StatCard(
              title: 'Overdue',
              value: _stats['overdue'].toString(),
              icon: Icons.warning,
              color: _stats['overdue']! > 0 ? AppColors.error : AppColors.textTertiary,
              backgroundColor: _stats['overdue']! > 0 
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.textTertiary.withOpacity(0.1),
              isHighlighted: _stats['overdue']! > 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: 'Add Pet',
                subtitle: 'Register a new pet',
                icon: Icons.pets,
                color: AppColors.primary,
                onTap: () {
                  Navigator.pushNamed(context, '/add-pet').then((_) {
                    _loadDashboardStats();
                  });
                },
              ),
            ),
            
            AppSpacing.hSpaceSm,
            
            Expanded(
              child: _buildQuickActionCard(
                title: 'Add Reminder',
                subtitle: 'Set up care reminders',
                icon: Icons.alarm_add,
                color: AppColors.secondary,
                onTap: () {
                  Navigator.pushNamed(context, '/add-reminder').then((_) {
                    _loadDashboardStats();
                  });
                },
              ),
            ),
          ],
        ),
        
        AppSpacing.vSpaceMd,
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: 'Track Weight',
                subtitle: 'Log pet weight',
                icon: Icons.monitor_weight,
                color: AppColors.info,
                onTap: () {
                  // TODO: Navigate to pet selection for weight tracking
                  AppErrorHandler.showInfoSnackBar(
                    context, 
                    'Select a pet from the pets list to track weight'
                  );
                },
              ),
            ),
            
            AppSpacing.hSpaceSm,
            
            Expanded(
              child: _buildQuickActionCard(
                title: 'Add Expense',
                subtitle: 'Record pet expenses',
                icon: Icons.receipt,
                color: AppColors.warning,
                onTap: () {
                  // TODO: Navigate to expense form
                  AppErrorHandler.showInfoSnackBar(
                    context, 
                    'Expense tracking coming soon'
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                
                AppSpacing.vSpaceMd,
                
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
        ),
      ),
    );
  }
}