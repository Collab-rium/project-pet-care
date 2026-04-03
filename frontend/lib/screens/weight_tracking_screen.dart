import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_input.dart';
import '../components/molecules/app_form_field.dart';
import '../components/organisms/loading_widgets.dart';
import '../components/organisms/empty_states.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/validators.dart';

class WeightTrackingScreen extends StatefulWidget {
  final Pet pet;

  const WeightTrackingScreen({super.key, required this.pet});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  final _weightRepository = WeightRepository();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<WeightRecord> _weightRecords = [];
  bool _isLoading = true;
  bool _isAddingRecord = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadWeightRecords();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadWeightRecords() async {
    try {
      setState(() => _isLoading = true);
      final records = await _weightRepository.getPetWeightRecords(widget.pet.id);
      setState(() {
        _weightRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to load weight records: ${e.toString()}',
      );
      setState(() => _isLoading = false);
    }
  }

  String _generateId() {
    return 'weight-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';
  }

  Future<void> _addWeightRecord() async {
    if (_weightController.text.isEmpty) {
      AppErrorHandler.showErrorSnackBar(context, 'Please enter a weight');
      return;
    }

    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      AppErrorHandler.showErrorSnackBar(context, 'Please enter a valid weight');
      return;
    }

    setState(() => _isAddingRecord = true);

    try {
      final now = DateTime.now();
      final newRecord = WeightRecord(
        id: _generateId(),
        userId: widget.pet.userId,
        petId: widget.pet.id,
        weight: weight,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _weightRepository.createWeightRecord(newRecord);

      _weightController.clear();
      _notesController.clear();
      _selectedDate = DateTime.now();
      
      await _loadWeightRecords();
      
      AppErrorHandler.showSuccessSnackBar(context, 'Weight recorded successfully!');
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to record weight: ${e.toString()}',
      );
    } finally {
      setState(() => _isAddingRecord = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${widget.pet.name} Weight',
          style: AppTextStyles.h2,
        ),
        
        elevation: 0,
      ),
      body: _isLoading 
          ? const ChartLoadingSkeleton()
          : Column(
              children: [
                // Add weight form
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: AppSpacing.pageInsets,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Record Weight',
                        style: AppTextStyles.h3,
                      ),
                      AppSpacing.vSpaceSm,
                      
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AppInput(
                              controller: _weightController,
                              placeholder: 'Weight (kg)',
                              keyboardType: TextInputType.number,
                              validator: AppValidators.positiveNumber,
                            ),
                          ),
                          AppSpacing.hSpaceSm,
                          
                          Expanded(
                            flex: 2,
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
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    AppSpacing.hSpaceXs,
                                    Text(
                                      '${_selectedDate.day}/${_selectedDate.month}',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.hSpaceSm,
                          
                          AppButton.primary(
                            text: 'Add',
                            onPressed: _addWeightRecord,
                            isLoading: _isAddingRecord,
                          ),
                        ],
                      ),
                      
                      AppSpacing.vSpaceSm,
                      
                      AppInput(
                        controller: _notesController,
                        placeholder: 'Notes (optional)',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

                // Chart and records
                Expanded(
                  child: _weightRecords.isEmpty
                      ? EmptyWeightList(onAddWeight: () {
                          // Focus on weight input
                          FocusScope.of(context).requestFocus(FocusNode());
                        })
                      : _buildContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: AppSpacing.pageInsets,
      children: [
        // Chart section
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weight Trend',
                style: AppTextStyles.h3,
              ),
              AppSpacing.vSpaceMd,
              SizedBox(
                height: 200,
                child: _buildChart(),
              ),
            ],
          ),
        ),
        
        AppSpacing.vSpaceLg,
        
        // Records list
        Text(
          'Weight History',
          style: AppTextStyles.h3,
        ),
        AppSpacing.vSpaceSm,
        
        ..._weightRecords.map((record) => _buildWeightRecord(record)).toList(),
      ],
    );
  }

  Widget _buildChart() {
    if (_weightRecords.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Need at least 2 records to show chart',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Sort by date for proper chart display
    final sortedRecords = List<WeightRecord>.from(_weightRecords)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedRecords.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final minWeight = sortedRecords.map((r) => r.weight).reduce((a, b) => a < b ? a : b) - 1;
    final maxWeight = sortedRecords.map((r) => r.weight).reduce((a, b) => a > b ? a : b) + 1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < sortedRecords.length) {
                  final record = sortedRecords[value.toInt()];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${record.date.day}/${record.date.month}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
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
              interval: 1,
              reservedSize: 42,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${value.toStringAsFixed(1)}kg',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        minX: 0,
        maxX: (sortedRecords.length - 1).toDouble(),
        minY: minWeight,
        maxY: maxWeight,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Theme.of(context).colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightRecord(WeightRecord record) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(
              Icons.monitor_weight,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          
          AppSpacing.hSpaceMd,
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.weight} kg',
                  style: AppTextStyles.h3,
                ),
                AppSpacing.vSpaceXs,
                Text(
                  '${record.date.day}/${record.date.month}/${record.date.year}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (record.notes != null) ...[
                  AppSpacing.vSpaceXs,
                  Text(
                    record.notes!,
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
          
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: () async {
              final confirmed = await AppErrorHandler.showConfirmDialog(
                context,
                'Delete Record',
                'Are you sure you want to delete this weight record?',
              );
              
              if (confirmed) {
                try {
                  await _weightRepository.deleteWeightRecord(record.id);
                  await _loadWeightRecords();
                  AppErrorHandler.showSuccessSnackBar(
                    context,
                    'Record deleted successfully',
                  );
                } catch (e) {
                  AppErrorHandler.showErrorSnackBar(
                    context,
                    'Failed to delete record: ${e.toString()}',
                  );
                }
              }
            },
            padding: EdgeInsets.all(8),
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
}