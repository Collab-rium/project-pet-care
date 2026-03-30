import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_dropdown.dart';
import '../components/organisms/loading_widgets.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _petRepository = PetRepository();
  final _budgetRepository = BudgetRepository();
  final _expenseRepository = ExpenseRepository();
  
  List<Pet> _pets = [];
  List<Budget> _budgets = [];
  Map<String, double> _monthlyExpenses = {};
  Map<String, Map<String, double>> _categoryBreakdown = {};
  
  Pet? _selectedPet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      final pets = await _petRepository.getUserPets('user-1');
      
      setState(() {
        _pets = pets;
        if (pets.isNotEmpty && _selectedPet == null) {
          _selectedPet = pets.first;
        }
      });
      
      if (_selectedPet != null) {
        await _loadPetBudgetData();
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to load data: ${e.toString()}',
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPetBudgetData() async {
    if (_selectedPet == null) return;

    try {
      final budgets = await _budgetRepository.getPetBudgets(_selectedPet!.id);
      final currentBudget = await _budgetRepository.getCurrentBudget(_selectedPet!.id);
      
      // Load monthly expenses for the last 6 months
      final now = DateTime.now();
      final monthlyExpenses = <String, double>{};
      final categoryBreakdown = <String, Map<String, double>>{};
      
      for (int i = 0; i < 6; i++) {
        final monthDate = DateTime(now.year, now.month - i);
        final monthKey = '${monthDate.month.toString().padLeft(2, '0')}/${monthDate.year}';
        
        final monthlyTotal = await _expenseRepository.getPetMonthlyExpenses(
          _selectedPet!.id,
          monthDate.year,
          monthDate.month,
        );
        
        final categoryTotals = await _expenseRepository.getCategoryTotals(
          _selectedPet!.id,
          monthDate.year,
          monthDate.month,
        );
        
        monthlyExpenses[monthKey] = monthlyTotal;
        categoryBreakdown[monthKey] = categoryTotals;
      }
      
      setState(() {
        _budgets = budgets;
        _monthlyExpenses = monthlyExpenses;
        _categoryBreakdown = categoryBreakdown;
      });
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to load budget data: ${e.toString()}',
      );
    }
  }

  Budget? get _currentBudget {
    final now = DateTime.now();
    final currentMonth = now.month.toString().padLeft(2, '0');
    
    return _budgets.where((b) => 
      b.month == currentMonth && b.year == now.year
    ).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Budget Management',
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading 
          ? const ChartLoadingSkeleton()
          : _pets.isEmpty
              ? _buildEmptyPetsState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyPetsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 64,
            color: AppColors.textTertiary,
          ),
          AppSpacing.vSpaceMd,
          Text(
            'No Pets Found',
            style: AppTextStyles.h2,
          ),
          AppSpacing.vSpaceSm,
          Text(
            'Add a pet first to manage budgets',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Pet selector
        Container(
          color: AppColors.surface,
          padding: AppSpacing.pageInsets,
          child: Row(
            children: [
              Text(
                'Pet: ',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: AppDropdown(
                  value: _selectedPet?.name ?? '',
                  items: _pets.map((p) => p.name).toList(),
                  onChanged: (petName) {
                    final pet = _pets.firstWhere((p) => p.name == petName);
                    setState(() => _selectedPet = pet);
                    _loadPetBudgetData();
                  },
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: ListView(
            padding: AppSpacing.pageInsets,
            children: [
              // Current budget overview
              _buildCurrentBudgetCard(),
              
              AppSpacing.vSpaceLg,
              
              // Monthly spending chart
              _buildSpendingChart(),
              
              AppSpacing.vSpaceLg,
              
              // Category breakdown
              _buildCategoryBreakdown(),
              
              AppSpacing.vSpaceLg,
              
              // Budget history
              _buildBudgetHistory(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentBudgetCard() {
    final budget = _currentBudget;
    final now = DateTime.now();
    final currentMonthKey = '${now.month.toString().padLeft(2, '0')}/${now.year}';
    final currentSpent = _monthlyExpenses[currentMonthKey] ?? 0.0;
    
    if (budget == null) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 48,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceMd,
            Text(
              'No Budget Set',
              style: AppTextStyles.h3,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Set a monthly budget to track spending',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceMd,
            AppButton.primary(
              text: 'Set Budget',
              onPressed: () {
                AppErrorHandler.showInfoSnackBar(
                  context,
                  'Budget creation coming soon',
                );
              },
            ),
          ],
        ),
      );
    }

    final percentageUsed = (currentSpent / budget.monthlyLimit * 100).clamp(0, 100);
    final remaining = (budget.monthlyLimit - currentSpent).clamp(0, double.infinity);
    final isOverBudget = currentSpent > budget.monthlyLimit;

    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget 
              ? [AppColors.error, AppColors.error.withOpacity(0.8)]
              : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Month\'s Budget',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
              if (isOverBudget)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.2),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Text(
                    'OVER BUDGET',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          
          AppSpacing.vSpaceLg,
          
          // Budget amounts
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        color: AppColors.textOnPrimary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '\$${currentSpent.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOverBudget ? 'Over by' : 'Remaining',
                      style: TextStyle(
                        color: AppColors.textOnPrimary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '\$${isOverBudget ? (currentSpent - budget.monthlyLimit).toStringAsFixed(1) : remaining.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        color: AppColors.textOnPrimary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '\$${budget.monthlyLimit.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          AppSpacing.vSpaceLg,
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${percentageUsed.toStringAsFixed(1)}% used',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnPrimary.withOpacity(0.8),
                    ),
                  ),
                  if (isOverBudget)
                    Text(
                      '${(percentageUsed - 100).toStringAsFixed(1)}% over',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
              AppSpacing.vSpaceXs,
              ClipRRect(
                borderRadius: AppSpacing.borderRadiusSm,
                child: LinearProgressIndicator(
                  value: (percentageUsed / 100).clamp(0, 1),
                  backgroundColor: AppColors.surface.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.surface.withOpacity(0.9),
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingChart() {
    if (_monthlyExpenses.isEmpty) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              'Monthly Spending Trend',
              style: AppTextStyles.h3,
            ),
            AppSpacing.vSpaceLg,
            Icon(
              Icons.timeline,
              size: 48,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No spending data available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final sortedEntries = _monthlyExpenses.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Spending Trend',
            style: AppTextStyles.h3,
          ),
          AppSpacing.vSpaceMd,
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < sortedEntries.length) {
                          final entry = sortedEntries[value.toInt()];
                          return Text(
                            entry.key.split('/')[0],
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final now = DateTime.now();
    final currentMonthKey = '${now.month.toString().padLeft(2, '0')}/${now.year}';
    final currentCategories = _categoryBreakdown[currentMonthKey] ?? {};
    
    if (currentCategories.isEmpty) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Month\'s Category Breakdown',
              style: AppTextStyles.h3,
            ),
            AppSpacing.vSpaceMd,
            Center(
              child: Text(
                'No expenses recorded this month',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final sortedCategories = currentCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month\'s Category Breakdown',
            style: AppTextStyles.h3,
          ),
          AppSpacing.vSpaceMd,
          
          ...sortedCategories.map((entry) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                Text(
                  '\$${entry.value.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildBudgetHistory() {
    if (_budgets.isEmpty) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget History',
              style: AppTextStyles.h3,
            ),
            AppSpacing.vSpaceMd,
            Center(
              child: Text(
                'No budget history available',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget History',
            style: AppTextStyles.h3,
          ),
          AppSpacing.vSpaceMd,
          
          ..._budgets.take(5).map((budget) {
            final monthKey = '${budget.month}/${budget.year}';
            final spent = _monthlyExpenses[monthKey] ?? 0.0;
            final percentage = (spent / budget.monthlyLimit * 100).clamp(0, 100);
            
            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.sm),
              padding: AppSpacing.cardInsets,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        monthKey,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${spent.toStringAsFixed(2)} / \$${budget.monthlyLimit.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  AppSpacing.vSpaceXs,
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      spent > budget.monthlyLimit ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}