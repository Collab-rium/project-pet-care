import 'package:flutter/material.dart';
import 'dart:math';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_input.dart';
import '../components/atoms/app_dropdown.dart';
import '../components/molecules/app_form_field.dart';
import '../components/organisms/loading_widgets.dart';
import '../../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/validators.dart';
import '../core/services/logger_service.dart';
import '../core/services/file_logger_service.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Pet pet;
  final Expense? expense;

  const ExpenseFormScreen({
    super.key,
    required this.pet,
    this.expense,
  });

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _expenseRepository = ExpenseRepository();
  
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _expenseCategories = [
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

  @override
  void initState() {
    super.initState();
    LoggerService.info('ExpenseFormScreen: Screen opened (${widget.expense != null ? 'editing' : 'creating'})');
    FileLoggerService.log('ExpenseFormScreen: Screen initialized');
    
    if (widget.expense != null) {
      _amountController = TextEditingController(
        text: widget.expense!.amount.toString()
      );
      _descriptionController = TextEditingController(
        text: widget.expense!.description ?? ''
      );
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
    } else {
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _generateId() {
    return 'expense-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      LoggerService.info('ExpenseFormScreen: Saving expense (${widget.expense != null ? 'update' : 'create'})...');
      final amount = double.parse(_amountController.text);
      final now = DateTime.now();

      if (widget.expense != null) {
        // Update existing expense
        final updatedExpense = Expense(
          id: widget.expense!.id,
          userId: widget.expense!.userId,
          petId: widget.expense!.petId,
          amount: amount,
          category: _selectedCategory,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          date: _selectedDate,
          createdAt: widget.expense!.createdAt,
          updatedAt: now,
        );
        
        await _expenseRepository.updateExpense(updatedExpense);
        LoggerService.info('ExpenseFormScreen: Expense updated successfully');
        await FileLoggerService.log('ExpenseFormScreen: Expense updated (amount: \$${amount}, category: $_selectedCategory)');
      } else {
        // Create new expense
        final newExpense = Expense(
          id: _generateId(),
          userId: widget.pet.userId,
          petId: widget.pet.id,
          amount: amount,
          category: _selectedCategory,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          date: _selectedDate,
          createdAt: now,
          updatedAt: now,
        );
        
        await _expenseRepository.createExpense(newExpense);
        LoggerService.info('ExpenseFormScreen: Expense created successfully');
        await FileLoggerService.log('ExpenseFormScreen: Expense created (amount: \$${amount}, category: $_selectedCategory)');
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        AppErrorHandler.showSuccessSnackBar(
          context,
          widget.expense != null ? 'Expense updated successfully!' : 'Expense added successfully!',
        );
      }
    } catch (e, st) {
      LoggerService.error('ExpenseFormScreen: Save failed - $e', exception: e);
      await FileLoggerService.logError('ExpenseFormScreen save failed', exception: e, stackTrace: st);
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to save expense: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.expense != null ? 'Edit Expense' : 'Add Expense',
          style: AppTextStyles.h2,
        ),
        
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Saving expense...',
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.pageInsets,
            children: [
              // Pet info card
              Container(
                padding: AppSpacing.cardInsets,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Icon(
                        Icons.pets,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    AppSpacing.hSpaceMd,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expense for ${widget.pet.name}',
                          style: AppTextStyles.h4,
                        ),
                        AppSpacing.vSpaceXs,
                        Text(
                          '${widget.pet.species}${widget.pet.breed != null ? ' • ${widget.pet.breed}' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              AppSpacing.vSpaceLg,

              AppFormField(
                label: 'Amount',
                isRequired: true,
                child: AppInput(
                  controller: _amountController,
                  placeholder: 'Enter amount',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: AppValidators.positiveNumber,
                  prefixIcon: Icons.attach_money,
                ),
              ),

              AppFormField(
                label: 'Category',
                isRequired: true,
                child: AppDropdown(
                  value: _selectedCategory,
                  items: _expenseCategories,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),

              AppFormField(
                label: 'Date',
                isRequired: true,
                child: GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              AppFormField(
                label: 'Description',
                child: AppInput(
                  controller: _descriptionController,
                  placeholder: 'Enter description (optional)',
                  maxLines: 3,
                ),
              ),

              AppSpacing.vSpaceXl,

              AppButton.primary(
                text: widget.expense != null ? 'Update Expense' : 'Add Expense',
                onPressed: _saveExpense,
                isLoading: _isLoading,
                icon: widget.expense != null ? Icons.update : Icons.add,
              ),

              AppSpacing.vSpaceMd,

              AppButton.outlined(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),

              // Quick amount buttons for new expenses
              if (widget.expense == null) ...[
                AppSpacing.vSpaceLg,
                
                Text(
                  'Quick Amounts',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.vSpaceSm,
                
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _buildQuickAmountChip('5.00'),
                    _buildQuickAmountChip('10.00'),
                    _buildQuickAmountChip('20.00'),
                    _buildQuickAmountChip('50.00'),
                    _buildQuickAmountChip('100.00'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(String amount) {
    return GestureDetector(
      onTap: () {
        _amountController.text = amount;
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Text(
          '\$${amount}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}