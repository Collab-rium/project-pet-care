import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_dropdown.dart';
import '../components/organisms/loading_widgets.dart';
import '../../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';
import '../core/theme/color_tokens_extension.dart';
import '../core/services/logger_service.dart';
import '../core/services/file_logger_service.dart';

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
    LoggerService.info('BudgetScreen: Screen opened');
    FileLoggerService.log('BudgetScreen: Screen initialized');
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      LoggerService.info('BudgetScreen: Loading data...');
      setState(() => _isLoading = true);

      final pets = await _petRepository.getUserPets('user-1');
      LoggerService.debug('BudgetScreen: Fetched ${pets.length} pets');

      setState(() {
        _pets = pets;
        if (pets.isNotEmpty && _selectedPet == null) {
          _selectedPet = pets.first;
        }
      });

      if (_selectedPet != null) {
        await _loadPetBudgetData();
      }

      LoggerService.info('BudgetScreen: Data loaded successfully');
      await FileLoggerService.log('BudgetScreen: Loaded ${pets.length} pets');
      setState(() => _isLoading = false);
    } catch (e, st) {
      LoggerService.error('BudgetScreen: Failed to load data - $e', exception: e);
      await FileLoggerService.logError('BudgetScreen load failed', exception: e, stackTrace: st);
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
      final currentBudget =
          await _budgetRepository.getCurrentBudget(_selectedPet!.id);

      // Load monthly expenses for the last 6 months
      final now = DateTime.now();
      final monthlyExpenses = <String, double>{};
      final categoryBreakdown = <String, Map<String, double>>{};

      for (int i = 0; i < 6; i++) {
        final monthDate = DateTime(now.year, now.month - i);
        final monthKey =
            '${monthDate.month.toString().padLeft(2, '0')}/${monthDate.year}';

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

  Future<void> _showBudgetDialog() async {
    final TextEditingController budgetController = TextEditingController();

    // Pre-fill with current budget if exists
    if (_currentBudget != null) {
      budgetController.text = _currentBudget!.monthlyLimit.toString();
    }

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_currentBudget != null ? 'Update Budget' : 'Set Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Monthly Budget Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                hintText: 'Enter amount',
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
              final amount = double.tryParse(budgetController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              } else {
                AppErrorHandler.showErrorSnackBar(
                  context,
                  'Please enter a valid amount',
                );
              }
            },
            child: Text(_currentBudget != null ? 'Update' : 'Set'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        LoggerService.info('BudgetScreen: Saving budget - amount: $result');
        
        if (_selectedPet != null) {
          final now = DateTime.now();
          final budget = Budget(
            id: _currentBudget?.id ?? 'budget-${_selectedPet!.id}-${DateTime.now().millisecondsSinceEpoch}',
            petId: _selectedPet!.id,
            userId: 'user-1',
            monthlyLimit: result,
            currentSpent: _currentBudget?.currentSpent ?? 0.0,
            month: now.month.toString().padLeft(2, '0'),
            year: now.year,
            createdAt: _currentBudget?.createdAt ?? now,
            updatedAt: now,
          );
          
          if (_currentBudget != null) {
            await _budgetRepository.updateBudget(budget);
            LoggerService.info('BudgetScreen: Budget updated successfully');
            await FileLoggerService.log('Budget updated: ${budget.monthlyLimit}');
          } else {
            await _budgetRepository.createBudget(budget);
            LoggerService.info('BudgetScreen: Budget created successfully');
            await FileLoggerService.log('Budget created: ${budget.monthlyLimit}');
          }
          
          AppErrorHandler.showSuccessSnackBar(
            context,
            _currentBudget != null
                ? 'Budget updated to \$${result.toStringAsFixed(2)}'
                : 'Budget set to \$${result.toStringAsFixed(2)}',
          );
          _loadData(); // Refresh data
        }
      } catch (e, st) {
        LoggerService.error('BudgetScreen: Failed to save budget - $e', exception: e);
        await FileLoggerService.logError('Budget save failed', exception: e, stackTrace: st);
        AppErrorHandler.showErrorSnackBar(
          context,
          'Failed to save budget: ${e.toString()}',
        );
      }
    }
  }

  Budget? get _currentBudget {
    final now = DateTime.now();
    final currentMonth = now.month.toString().padLeft(2, '0');

    return _budgets
        .where((b) => b.month == currentMonth && b.year == now.year)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BudgetScreen: isLoading=$_isLoading, petsCount=${_pets.length}, selectedPet=${_selectedPet?.name}');
    
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Budget Management',
          style: AppTextStyles.h2,
        ),
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
          color: Theme.of(context).colorScheme.surface,
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
    final currentMonthKey =
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    final currentSpent = _monthlyExpenses[currentMonthKey] ?? 0.0;

    if (budget == null) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
              onPressed: () => _showBudgetDialog(),
            ),
          ],
        ),
      );
    }

    final percentageUsed =
        (currentSpent / budget.monthlyLimit * 100).clamp(0, 100);
    final remaining =
        (budget.monthlyLimit - currentSpent).clamp(0, double.infinity);
    final isOverBudget = currentSpent > budget.monthlyLimit;

    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget
              ? [Colors.red, Colors.red.withOpacity(0.8)]
              : [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8)
                ],
        ),
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (isOverBudget)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'OVER BUDGET',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

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
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '\$${currentSpent.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
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
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '\$${isOverBudget ? (currentSpent - budget.monthlyLimit).toStringAsFixed(2) : remaining.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
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
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '\$${budget.monthlyLimit.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${percentageUsed.toStringAsFixed(1)}% used',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  if (isOverBudget)
                    Text(
                      '${(percentageUsed - 100).toStringAsFixed(1)}% over',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (percentageUsed / 100).clamp(0, 1),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.9),
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
          color: Theme.of(context).colorScheme.surface,
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
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
    final currentMonthKey =
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    final currentCategories = _categoryBreakdown[currentMonthKey] ?? {};

    if (currentCategories.isEmpty) {
      return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month\'s Category Breakdown',
            style: AppTextStyles.h3,
          ),
          AppSpacing.vSpaceMd,
          ...sortedCategories
              .map((entry) => Padding(
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
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildBudgetHistory() {
    
    if (_budgets.isEmpty) {
      return Container(
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
            final percentage =
                (spent / budget.monthlyLimit * 100).clamp(0, 100);

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
                      spent > budget.monthlyLimit
                          ? AppColors.error
                          : AppColors.primary,
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
