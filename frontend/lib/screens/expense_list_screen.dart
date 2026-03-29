import 'package:flutter/material.dart';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_dropdown.dart';
import '../components/organisms/loading_widgets.dart';
import '../components/organisms/empty_states.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  final Pet pet;

  const ExpenseListScreen({super.key, required this.pet});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _expenseRepository = ExpenseRepository();
  
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _selectedTimeRange = 'All Time';
  
  final List<String> _categories = [
    'All',
    'Food',
    'Vet',
    'Medicine',
    'Grooming',
    'Toys',
    'Accessories',
    'Training',
    'Boarding',
    'Insurance',
    'Other',
  ];
  
  final List<String> _timeRanges = [
    'All Time',
    'This Month',
    'Last Month',
    'Last 3 Months',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() => _isLoading = true);
      
      final expenses = await _expenseRepository.getPetExpenses(widget.pet.id);
      
      setState(() {
        _expenses = expenses;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to load expenses: ${e.toString()}',
      );
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Expense> filtered = _expenses;
    
    // Category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((e) => e.category == _selectedCategory).toList();
    }
    
    // Time range filter
    final now = DateTime.now();
    switch (_selectedTimeRange) {
      case 'This Month':
        filtered = filtered.where((e) => 
          e.date.year == now.year && e.date.month == now.month
        ).toList();
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1);
        filtered = filtered.where((e) => 
          e.date.year == lastMonth.year && e.date.month == lastMonth.month
        ).toList();
        break;
      case 'Last 3 Months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3);
        filtered = filtered.where((e) => e.date.isAfter(threeMonthsAgo)).toList();
        break;
      case 'This Year':
        filtered = filtered.where((e) => e.date.year == now.year).toList();
        break;
    }
    
    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    
    setState(() {
      _filteredExpenses = filtered;
    });
  }

  double get _totalAmount {
    return _filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<void> _navigateToAddExpense() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(pet: widget.pet),
      ),
    );
    
    if (result == true) {
      _loadExpenses();
    }
  }

  Future<void> _navigateToEditExpense(Expense expense) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(
          pet: widget.pet,
          expense: expense,
        ),
      ),
    );
    
    if (result == true) {
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${widget.pet.name} Expenses',
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadExpenses,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary card
          Container(
            color: AppColors.surface,
            padding: AppSpacing.pageInsets,
            child: Container(
              padding: AppSpacing.cardInsets,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.2),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: AppColors.onPrimary,
                      size: 24,
                    ),
                  ),
                  AppSpacing.hSpaceMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Spent',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onPrimary.withOpacity(0.9),
                          ),
                        ),
                        AppSpacing.vSpaceXs,
                        Text(
                          '\$${_totalAmount.toStringAsFixed(2)}',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_filteredExpenses.length} expense${_filteredExpenses.length != 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onPrimary.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Filters
          Container(
            color: AppColors.surface,
            padding: AppSpacing.pageInsets.copyWith(top: 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          AppSpacing.vSpaceXs,
                          AppDropdown(
                            value: _selectedCategory,
                            items: _categories,
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                                _applyFilters();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hSpaceSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time Range',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          AppSpacing.vSpaceXs,
                          AppDropdown(
                            value: _selectedTimeRange,
                            items: _timeRanges,
                            onChanged: (value) {
                              setState(() {
                                _selectedTimeRange = value;
                                _applyFilters();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Expense list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExpenses.isEmpty
                    ? _buildEmptyState()
                    : _buildExpenseList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_expenses.isEmpty) {
      return EmptyExpensesList(onAddExpense: _navigateToAddExpense);
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceMd,
            Text(
              'No expenses found',
              style: AppTextStyles.h3,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Try adjusting your filters',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vSpaceMd,
            AppButton.outlined(
              text: 'Clear Filters',
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _selectedTimeRange = 'All Time';
                  _applyFilters();
                });
              },
            ),
          ],
        ),
      );
    }
  }

  Widget _buildExpenseList() {
    return ListView.builder(
      padding: AppSpacing.pageInsets,
      itemCount: _filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = _filteredExpenses[index];
        return _buildExpenseCard(expense);
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToEditExpense(expense),
          borderRadius: AppSpacing.borderRadiusMd,
          child: Padding(
            padding: AppSpacing.cardInsets,
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(expense.category).withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: _getCategoryColor(expense.category),
                    size: 24,
                  ),
                ),
                
                AppSpacing.hSpaceMd,
                
                // Expense details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            expense.category,
                            style: AppTextStyles.h4,
                          ),
                          Text(
                            '\$${expense.amount.toStringAsFixed(2)}',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      
                      AppSpacing.vSpaceXs,
                      
                      Text(
                        '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      if (expense.description != null) ...[
                        AppSpacing.vSpaceXs,
                        Text(
                          expense.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Edit button
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => _navigateToEditExpense(expense),
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Vet':
        return Icons.medical_services;
      case 'Medicine':
        return Icons.medication;
      case 'Grooming':
        return Icons.content_cut;
      case 'Toys':
        return Icons.toys;
      case 'Accessories':
        return Icons.shopping_bag;
      case 'Training':
        return Icons.school;
      case 'Boarding':
        return Icons.hotel;
      case 'Insurance':
        return Icons.security;
      default:
        return Icons.receipt;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.green;
      case 'Vet':
        return Colors.red;
      case 'Medicine':
        return Colors.purple;
      case 'Grooming':
        return Colors.blue;
      case 'Toys':
        return Colors.orange;
      case 'Accessories':
        return Colors.pink;
      case 'Training':
        return Colors.teal;
      case 'Boarding':
        return Colors.brown;
      case 'Insurance':
        return Colors.indigo;
      default:
        return AppColors.textSecondary;
    }
  }
}