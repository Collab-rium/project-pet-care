import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_dropdown.dart';
import '../components/organisms/loading_widgets.dart';
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
  List<Expense> _currentMonthExpenses = [];

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

      // Load current month's expenses
      final currentMonthExpenses = await _expenseRepository.getPetExpenses(_selectedPet!.id);
      final filteredExpenses = currentMonthExpenses.where((expense) {
        return expense.date.year == now.year && expense.date.month == now.month;
      }).toList();

      setState(() {
        _budgets = budgets;
        _monthlyExpenses = monthlyExpenses;
        _categoryBreakdown = categoryBreakdown;
        _currentMonthExpenses = filteredExpenses;
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

    if (result != null && _selectedPet != null) {
      try {
        final amount = result;
        final now = DateTime.now();

        final budget = Budget(
          id: _currentBudget?.id ??
              'budget-${DateTime.now().millisecondsSinceEpoch}',
          userId: 'user-1',
          petId: _selectedPet!.id,
          monthlyLimit: amount,
          currentSpent: _currentBudget?.currentSpent ?? 0.0,
          month: now.month.toString().padLeft(2, '0'),
          year: now.year,
          createdAt: _currentBudget?.createdAt ?? now,
          updatedAt: now,
        );

        if (_currentBudget != null) {
          await _budgetRepository.updateBudget(budget);
        } else {
          await _budgetRepository.createBudget(budget);
        }

        AppErrorHandler.showSuccessSnackBar(
          context,
          _currentBudget != null
              ? 'Budget updated to \$${amount.toStringAsFixed(2)}'
              : 'Budget set to \$${amount.toStringAsFixed(2)}',
        );
        await _loadData(); // Refresh data
      } catch (e) {
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

  Future<void> _showAddExpenseDialog() async {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    String selectedCategory = 'Food';
    final categories = ['Food', 'Medical', 'Grooming', 'Toys', 'Other'];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    hintText: 'What was purchased?',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                    hintText: 'Enter amount',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                final description = descriptionController.text.trim();
                
                if (description.isEmpty) {
                  AppErrorHandler.showErrorSnackBar(
                    context,
                    'Please enter a description',
                  );
                  return;
                }
                
                if (amount == null || amount <= 0) {
                  AppErrorHandler.showErrorSnackBar(
                    context,
                    'Please enter a valid amount',
                  );
                  return;
                }
                
                Navigator.pop(context, {
                  'description': description,
                  'amount': amount,
                  'category': selectedCategory,
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null && _selectedPet != null) {
      try {
        final now = DateTime.now();
        final expense = Expense(
          id: 'expense-${now.millisecondsSinceEpoch}',
          userId: 'user-1',
          petId: _selectedPet!.id,
          amount: result['amount'],
          category: result['category'],
          description: result['description'],
          date: now,
          createdAt: now,
          updatedAt: now,
        );

        await _expenseRepository.createExpense(expense);
        await _updateBudgetSpending();
        await _loadData();

        AppErrorHandler.showSuccessSnackBar(
          context,
          'Expense added: \$${result['amount'].toStringAsFixed(2)}',
        );
      } catch (e) {
        AppErrorHandler.showErrorSnackBar(
          context,
          'Failed to add expense: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _updateBudgetSpending() async {
    if (_selectedPet == null || _currentBudget == null) return;

    try {
      final total = _currentMonthExpenses.fold<double>(
        0.0,
        (sum, expense) => sum + expense.amount,
      );

      final updatedBudget = Budget(
        id: _currentBudget!.id,
        userId: _currentBudget!.userId,
        petId: _currentBudget!.petId,
        monthlyLimit: _currentBudget!.monthlyLimit,
        currentSpent: total,
        month: _currentBudget!.month,
        year: _currentBudget!.year,
        createdAt: _currentBudget!.createdAt,
        updatedAt: DateTime.now(),
      );

      await _budgetRepository.updateBudget(updatedBudget);
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to update budget spending: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Budget Management',
          style: AppTextStyles.h2.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: _selectedPet != null
          ? FloatingActionButton(
              onPressed: _showAddExpenseDialog,
              child: Icon(Icons.add),
              tooltip: 'Add Expense',
            )
          : null,
      body: _isLoading
          ? const ChartLoadingSkeleton()
          : _pets.isEmpty
              ? _buildEmptyPetsState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyPetsState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
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
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Pet selector
        Container(
          color: colorScheme.surfaceContainerHighest,
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

              // Expenses list
              _buildExpensesList(),

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
    final colorScheme = Theme.of(context).colorScheme;
    final budget = _currentBudget;
    final now = DateTime.now();
    final currentMonthKey =
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    final currentSpent = _monthlyExpenses[currentMonthKey] ?? 0.0;

    if (budget == null) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 48,
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
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
                color: colorScheme.onSurfaceVariant,
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
              ? [colorScheme.error, colorScheme.error.withOpacity(0.8)]
              : [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
        ),
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
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
                  color: colorScheme.onPrimary,
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
                    color: colorScheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'OVER BUDGET',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
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
                        color: colorScheme.onPrimary.withOpacity(0.8),
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
                          color: colorScheme.onPrimary,
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
                        color: colorScheme.onPrimary.withOpacity(0.8),
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
                          color: colorScheme.onPrimary,
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
                        color: colorScheme.onPrimary.withOpacity(0.8),
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
                          color: colorScheme.onPrimary,
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
                      color: colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  if (isOverBudget)
                    Text(
                      '${(percentageUsed - 100).toStringAsFixed(1)}% over',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withOpacity(0.8),
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
                  backgroundColor: colorScheme.onPrimary.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary.withOpacity(0.9),
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
    final colorScheme = Theme.of(context).colorScheme;
    if (_monthlyExpenses.isEmpty) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: colorScheme.outline),
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
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No spending data available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
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
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
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
                              color:
                                  colorScheme.onSurfaceVariant.withOpacity(0.6),
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
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.6),
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
                    color: colorScheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withOpacity(0.1),
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
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final currentMonthKey =
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    final currentCategories = _categoryBreakdown[currentMonthKey] ?? {};

    if (currentCategories.isEmpty) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: colorScheme.outline),
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
                  color: colorScheme.onSurfaceVariant,
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
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
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
                            color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    if (_budgets.isEmpty) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: colorScheme.outline),
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
                  color: colorScheme.onSurfaceVariant,
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
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
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
                border: Border.all(color: colorScheme.outline),
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
                    backgroundColor: colorScheme.outline,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      spent > budget.monthlyLimit
                          ? colorScheme.error
                          : colorScheme.primary,
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

  Widget _buildExpensesList() {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_currentMonthExpenses.isEmpty) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Month\'s Expenses',
              style: AppTextStyles.h3,
            ),
            AppSpacing.vSpaceMd,
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  AppSpacing.vSpaceSm,
                  Text(
                    'No expenses recorded yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vSpaceXs,
                  Text(
                    'Tap the + button to add your first expense',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final totalSpent = _currentMonthExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
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
                'This Month\'s Expenses',
                style: AppTextStyles.h3,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  '${_currentMonthExpenses.length} items',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vSpaceMd,
          
          // Expense list
          ..._currentMonthExpenses.map((expense) {
            final dateStr = '${expense.date.month}/${expense.date.day}';
            
            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.sm),
              padding: AppSpacing.cardInsets,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                children: [
                  // Icon based on category
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      size: 24,
                      color: colorScheme.primary,
                    ),
                  ),
                  AppSpacing.hSpaceSm,
                  
                  // Expense details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.description ?? 'No description',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                expense.category,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            AppSpacing.hSpaceXs,
                            Text(
                              dateStr,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Amount
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          // Total
          Container(
            margin: EdgeInsets.only(top: AppSpacing.sm),
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Spent',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalSpent.toStringAsFixed(2)}',
                  style: AppTextStyles.h3.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Medical':
        return Icons.medical_services;
      case 'Grooming':
        return Icons.cut;
      case 'Toys':
        return Icons.toys;
      case 'Other':
      default:
        return Icons.shopping_bag;
    }
  }
}
