import 'package:flutter/material.dart';

import '../components/atoms/app_button.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';

class PaymentSubscriptionScreen extends StatefulWidget {
  const PaymentSubscriptionScreen({super.key});

  @override
  State<PaymentSubscriptionScreen> createState() => _PaymentSubscriptionScreenState();
}

class _PaymentSubscriptionScreenState extends State<PaymentSubscriptionScreen> {
  String _selectedPlan = 'free';
  bool _isYearly = false;

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      id: 'free',
      name: 'Free',
      monthlyPrice: 0,
      yearlyPrice: 0,
      features: [
        'Up to 3 pets',
        'Basic reminders',
        'Weight tracking',
        'Local storage only',
      ],
      limitations: [
        'No cloud backup',
        'Limited photo storage (50MB)',
        'No expense analytics',
      ],
    ),
    SubscriptionPlan(
      id: 'basic',
      name: 'Basic',
      monthlyPrice: 4.99,
      yearlyPrice: 49.99,
      features: [
        'Unlimited pets',
        'All reminder types',
        'Expense tracking',
        'Photo gallery',
        'Cloud backup',
        '500MB storage',
      ],
      limitations: [
        'Basic analytics only',
      ],
    ),
    SubscriptionPlan(
      id: 'premium',
      name: 'Premium',
      monthlyPrice: 9.99,
      yearlyPrice: 99.99,
      features: [
        'Everything in Basic',
        'Advanced analytics',
        'Vet integration',
        'Multiple device sync',
        '2GB storage',
        'Priority support',
        'Custom themes',
      ],
      limitations: [],
      isPopular: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Subscription Plans',
          style: AppTextStyles.h2,
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: AppSpacing.pageInsets,
        children: [
          // Coming soon banner
          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.construction,
                  size: 48,
                  color: AppColors.primary,
                ),
                AppSpacing.vSpaceMd,
                Text(
                  'Coming Soon!',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.vSpaceSm,
                Text(
                  'Subscription features are currently under development. You can use all features for free during the beta period.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          AppSpacing.vSpaceLg,

          // Billing toggle
          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Monthly',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: !_isYearly ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.hSpaceMd,
                Switch(
                  value: _isYearly,
                  onChanged: (value) => setState(() => _isYearly = value),
                  activeColor: AppColors.primary,
                ),
                AppSpacing.hSpaceMd,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yearly',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _isYearly ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_isYearly)
                      Text(
                        'Save 17%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          AppSpacing.vSpaceLg,

          // Subscription plans
          ..._plans.map((plan) => _buildPlanCard(plan)),

          AppSpacing.vSpaceLg,

          // Features comparison
          _buildFeaturesComparison(),

          AppSpacing.vSpaceLg,

          // Email notification section
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
                Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    AppSpacing.hSpaceSm,
                    Text(
                      'Get Notified',
                      style: AppTextStyles.h4,
                    ),
                  ],
                ),
                AppSpacing.vSpaceMd,
                Text(
                  'Be the first to know when subscription plans are available! We\'ll send you an email when you can upgrade to Premium features.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.vSpaceMd,
                AppButton.outlined(
                  text: 'Notify Me When Available',
                  onPressed: _requestNotification,
                  icon: Icons.email,
                ),
              ],
            ),
          ),

          AppSpacing.vSpaceXl,
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isSelected = _selectedPlan == plan.id;
    final price = _isYearly ? plan.yearlyPrice : plan.monthlyPrice;
    final isFree = plan.id == 'free';

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: plan.isPopular
              ? AppColors.primary
              : isSelected
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.border,
          width: plan.isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (plan.isPopular)
            Positioned(
              top: 0,
              right: 24,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSpacing.radiusSm),
                    bottomRight: Radius.circular(AppSpacing.radiusSm),
                  ),
                ),
                child: Text(
                  'Popular',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Padding(
            padding: AppSpacing.cardInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.isPopular) AppSpacing.vSpaceSm,
                
                // Header
                Row(
                  children: [
                    Radio<String>(
                      value: plan.id,
                      groupValue: _selectedPlan,
                      onChanged: (value) => setState(() => _selectedPlan = value!),
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: AppTextStyles.h3,
                          ),
                          AppSpacing.vSpaceXs,
                          if (isFree)
                            Text(
                              'Free Forever',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.success,
                              ),
                            )
                          else
                            Row(
                              children: [
                                Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                AppSpacing.hSpaceXs,
                                Text(
                                  '/${_isYearly ? 'year' : 'month'}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                AppSpacing.vSpaceMd,

                // Features
                Text(
                  'Features:',
                  style: AppTextStyles.h4,
                ),
                AppSpacing.vSpaceSm,
                ...plan.features.map((feature) => _buildFeatureItem(feature, true)),

                if (plan.limitations.isNotEmpty) ...[
                  AppSpacing.vSpaceMd,
                  Text(
                    'Limitations:',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.vSpaceSm,
                  ...plan.limitations.map((limitation) => _buildFeatureItem(limitation, false)),
                ],

                if (!isFree) ...[
                  AppSpacing.vSpaceMd,
                  AppButton.primary(
                    text: 'Coming Soon',
                    onPressed: null,
                    icon: Icons.lock,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature, bool isPositive) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.check : Icons.close,
            size: 16,
            color: isPositive ? AppColors.success : AppColors.error,
          ),
          AppSpacing.hSpaceXs,
          Expanded(
            child: Text(
              feature,
              style: AppTextStyles.bodySmall.copyWith(
                color: isPositive ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison() {
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
            'Feature Comparison',
            style: AppTextStyles.h3,
          ),
          AppSpacing.vSpaceMd,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Feature')),
                DataColumn(label: Text('Free')),
                DataColumn(label: Text('Basic')),
                DataColumn(label: Text('Premium')),
              ],
              rows: [
                _buildComparisonRow('Pets', '3', 'Unlimited', 'Unlimited'),
                _buildComparisonRow('Cloud Backup', '✗', '✓', '✓'),
                _buildComparisonRow('Storage', 'Local only', '500MB', '2GB'),
                _buildComparisonRow('Analytics', 'Basic', 'Basic', 'Advanced'),
                _buildComparisonRow('Vet Integration', '✗', '✗', '✓'),
                _buildComparisonRow('Priority Support', '✗', '✗', '✓'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildComparisonRow(String feature, String free, String basic, String premium) {
    return DataRow(
      cells: [
        DataCell(Text(feature, style: AppTextStyles.bodySmall)),
        DataCell(Text(free, style: AppTextStyles.bodySmall)),
        DataCell(Text(basic, style: AppTextStyles.bodySmall)),
        DataCell(Text(premium, style: AppTextStyles.bodySmall)),
      ],
    );
  }

  void _requestNotification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Get Notified'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email address to be notified when subscription plans are available:'),
            AppSpacing.vSpaceMd,
            TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thank you! We\'ll notify you when plans are available.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final List<String> limitations;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    this.limitations = const [],
    this.isPopular = false,
  });
}