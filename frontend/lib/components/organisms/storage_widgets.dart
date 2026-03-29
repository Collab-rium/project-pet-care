import 'package:flutter/material.dart';
import '../../components/molecules/app_card.dart';
import '../../components/atoms/app_button.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';
import '../../core/utils/storage_service.dart';

/// Widget to display storage warning banner
class StorageWarningBanner extends StatefulWidget {
  const StorageWarningBanner({super.key});

  @override
  State<StorageWarningBanner> createState() => _StorageWarningBannerState();
}

class _StorageWarningBannerState extends State<StorageWarningBanner> {
  StorageInfo? _storageInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkStorage();
  }

  Future<void> _checkStorage() async {
    try {
      final info = await StorageService.getStorageInfo();
      if (mounted) {
        setState(() {
          _storageInfo = info;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _storageInfo == null) {
      return const SizedBox.shrink();
    }

    if (!_storageInfo!.needsWarning) {
      return const SizedBox.shrink();
    }

    final isCritical = _storageInfo!.isCritical;
    final percentage = StorageService.getUsagePercentage(_storageInfo!);

    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      child: AppCard(
        backgroundColor: isCritical
            ? AppColors.errorLight.withOpacity(0.1)
            : AppColors.warningLight.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCritical ? Icons.error : Icons.warning,
                  color: isCritical ? AppColors.error : AppColors.warning,
                ),
                AppSpacing.hSpaceSm,
                Expanded(
                  child: Text(
                    isCritical ? '⚠️ Storage Critical' : 'Storage Warning',
                    style: AppTextStyles.h4.copyWith(
                      color: isCritical ? AppColors.error : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Storage usage: ${_storageInfo!.totalMB.toStringAsFixed(1)} MB',
              style: AppTextStyles.bodyLarge,
            ),
            AppSpacing.vSpaceXs,
            // Progress bar
            ClipRRect(
              borderRadius: AppSpacing.borderRadiusSm,
              child: LinearProgressIndicator(
                value: percentage > 1.0 ? 1.0 : percentage,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCritical ? AppColors.error : AppColors.warning,
                ),
                minHeight: 8,
              ),
            ),
            AppSpacing.vSpaceSm,
            Text(
              isCritical
                  ? 'Storage is running low. Consider deleting old photos or exporting data.'
                  : 'Storage usage is getting high. You may want to manage your photos.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vSpaceSm,
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    text: 'Manage Storage',
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    size: ButtonSize.small,
                  ),
                ),
                AppSpacing.hSpaceSm,
                Expanded(
                  child: AppButton.text(
                    text: 'Dismiss',
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          _storageInfo = null;
                        });
                      }
                    },
                    size: ButtonSize.small,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Storage info display widget for settings
class StorageInfoWidget extends StatefulWidget {
  const StorageInfoWidget({super.key});

  @override
  State<StorageInfoWidget> createState() => _StorageInfoWidgetState();
}

class _StorageInfoWidgetState extends State<StorageInfoWidget> {
  StorageInfo? _storageInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    setState(() => _loading = true);
    try {
      final info = await StorageService.getStorageInfo();
      if (mounted) {
        setState(() {
          _storageInfo = info;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _clearCache() async {
    try {
      await StorageService.clearCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
        _loadStorageInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing cache: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_storageInfo == null) {
      return const Center(child: Text('Unable to load storage info'));
    }

    final percentage = StorageService.getUsagePercentage(_storageInfo!);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Storage Usage', style: AppTextStyles.h3),
          AppSpacing.vSpaceMd,
          // Total usage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _storageInfo!.formattedTotal,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: _storageInfo!.isCritical
                      ? AppColors.error
                      : _storageInfo!.needsWarning
                          ? AppColors.warning
                          : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.vSpaceSm,
          ClipRRect(
            borderRadius: AppSpacing.borderRadiusSm,
            child: LinearProgressIndicator(
              value: percentage > 1.0 ? 1.0 : percentage,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                _storageInfo!.isCritical
                    ? AppColors.error
                    : _storageInfo!.needsWarning
                        ? AppColors.warning
                        : AppColors.success,
              ),
              minHeight: 12,
            ),
          ),
          AppSpacing.vSpaceMd,
          // Breakdown
          _buildStorageRow('Database', _storageInfo!.formattedDatabase),
          AppSpacing.vSpaceXs,
          _buildStorageRow('Photos', _storageInfo!.formattedPhotos),
          AppSpacing.vSpaceXs,
          _buildStorageRow('Cache', _storageInfo!.formattedCache),
          AppSpacing.vSpaceMd,
          AppButton.outlined(
            text: 'Clear Cache',
            onPressed: _clearCache,
            fullWidth: true,
            icon: Icons.delete_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
