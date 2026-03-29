import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_input.dart';
import '../components/atoms/app_toggle.dart';
import '../components/molecules/app_form_field.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/validators.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Export settings
  bool _includeImages = true;
  bool _includeSettings = true;
  final _exportPasswordController = TextEditingController();
  
  // Import settings
  String? _selectedFilePath;
  final _importPasswordController = TextEditingController();
  bool _confirmOverwrite = false;
  
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Backup & Restore',
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Export Data'),
            Tab(text: 'Import Data'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExportTab(),
          _buildImportTab(),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    return ListView(
      padding: AppSpacing.pageInsets,
      children: [
        // Info section
        Container(
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info,
                color: AppColors.primary,
                size: 20,
              ),
              AppSpacing.hSpaceSm,
              Expanded(
                child: Text(
                  'Export your pet care data to a secure backup file. You can import this file later to restore your data.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        AppSpacing.vSpaceLg,

        // Export options
        Text(
          'Export Options',
          style: AppTextStyles.h3,
        ),

        AppSpacing.vSpaceMd,

        _buildToggleOption(
          'Include Photos',
          'Export pet photos along with data (larger file size)',
          Icons.photo_library,
          _includeImages,
          (value) => setState(() => _includeImages = value),
        ),

        AppSpacing.vSpaceSm,

        _buildToggleOption(
          'Include Settings',
          'Export app preferences and customizations',
          Icons.settings,
          _includeSettings,
          (value) => setState(() => _includeSettings = value),
        ),

        AppSpacing.vSpaceLg,

        // Password protection
        AppFormField(
          label: 'Password Protection (Optional)',
          child: AppInput.password(
            controller: _exportPasswordController,
            placeholder: 'Enter password to encrypt backup',
          ),
        ),

        AppSpacing.vSpaceXs,

        Text(
          'Recommended: Use a strong password to encrypt your backup file for security.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        AppSpacing.vSpaceLg,

        // Export summary
        Container(
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
                'Export Summary',
                style: AppTextStyles.h4,
              ),
              AppSpacing.vSpaceMd,
              _buildSummaryItem('Pets', '2 pets'),
              _buildSummaryItem('Reminders', '8 reminders'),
              _buildSummaryItem('Expenses', '15 expense records'),
              _buildSummaryItem('Weight Records', '12 weight entries'),
              _buildSummaryItem('Photos', _includeImages ? '23 photos' : 'Not included'),
              _buildSummaryItem('Settings', _includeSettings ? 'Included' : 'Not included'),
              _buildSummaryItem('Estimated Size', _includeImages ? '~45 MB' : '~2 MB'),
            ],
          ),
        ),

        AppSpacing.vSpaceLg,

        // Export button
        AppButton.primary(
          text: 'Export Data',
          onPressed: _isProcessing ? null : _exportData,
          isLoading: _isProcessing,
          icon: Icons.file_download,
        ),
      ],
    );
  }

  Widget _buildImportTab() {
    return ListView(
      padding: AppSpacing.pageInsets,
      children: [
        // Warning section
        Container(
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning,
                color: AppColors.warning,
                size: 20,
              ),
              AppSpacing.hSpaceSm,
              Expanded(
                child: Text(
                  'Importing data will replace your current data. Make sure you have a backup before proceeding.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),

        AppSpacing.vSpaceLg,

        // File selection
        Text(
          'Select Backup File',
          style: AppTextStyles.h3,
        ),

        AppSpacing.vSpaceMd,

        Container(
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedFilePath == null) ...[
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.file_upload,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      AppSpacing.vSpaceSm,
                      Text(
                        'No file selected',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(
                      Icons.file_present,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    AppSpacing.hSpaceSm,
                    Expanded(
                      child: Text(
                        _selectedFilePath!.split('/').last,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _selectedFilePath = null),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
              AppSpacing.vSpaceMd,
              AppButton.outlined(
                text: 'Choose File',
                onPressed: _selectBackupFile,
                icon: Icons.folder_open,
              ),
            ],
          ),
        ),

        AppSpacing.vSpaceLg,

        // Password input
        AppFormField(
          label: 'Password (if encrypted)',
          child: AppInput.password(
            controller: _importPasswordController,
            placeholder: 'Enter backup file password',
          ),
        ),

        AppSpacing.vSpaceLg,

        // Preview/validation section
        if (_selectedFilePath != null) ...[
          Container(
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
                  'Backup Preview',
                  style: AppTextStyles.h4,
                ),
                AppSpacing.vSpaceMd,
                _buildPreviewItem('Created', 'Dec 15, 2024 at 3:42 PM'),
                _buildPreviewItem('App Version', '1.0.0'),
                _buildPreviewItem('Data Size', '~2.1 MB'),
                _buildPreviewItem('Photos', '23 files (~43 MB)'),
                AppSpacing.vSpaceMd,
                Container(
                  padding: AppSpacing.cardInsets,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      AppSpacing.hSpaceXs,
                      Text(
                        'Backup file is valid and compatible',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.vSpaceLg,
        ],

        // Confirmation checkbox
        Container(
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: _confirmOverwrite,
                  onChanged: (value) => setState(() => _confirmOverwrite = value ?? false),
                  activeColor: AppColors.primary,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _confirmOverwrite = !_confirmOverwrite),
                  child: Text(
                    'I understand this will replace all my current data and cannot be undone.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),

        AppSpacing.vSpaceLg,

        // Import button
        AppButton.primary(
          text: 'Import Data',
          onPressed: (_isProcessing || _selectedFilePath == null || !_confirmOverwrite) 
              ? null 
              : _importData,
          isLoading: _isProcessing,
          icon: Icons.file_upload,
        ),
      ],
    );
  }

  Widget _buildToggleOption(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          AppSpacing.hSpaceMd,
          AppToggle(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['backup', 'json', 'zip'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path!;
        });
      }
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to select file: ${e.toString()}',
      );
    }
  }

  Future<void> _exportData() async {
    setState(() => _isProcessing = true);

    try {
      // Simulate export process
      await Future.delayed(Duration(seconds: 3));

      AppErrorHandler.showSuccessSnackBar(
        context,
        'Data exported successfully! File saved to Downloads.',
      );
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Export failed: ${e.toString()}',
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _isProcessing = true);

    try {
      // Simulate import process
      await Future.delayed(Duration(seconds: 4));

      AppErrorHandler.showSuccessSnackBar(
        context,
        'Data imported successfully! Please restart the app.',
      );
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Import failed: ${e.toString()}',
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _exportPasswordController.dispose();
    _importPasswordController.dispose();
    super.dispose();
  }
}