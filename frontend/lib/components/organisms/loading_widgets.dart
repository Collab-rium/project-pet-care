import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';

/// Loading skeleton widgets
class LoadingSkeleton extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const LoadingSkeleton({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? AppSpacing.borderRadiusSm,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.border,
                AppColors.borderLight,
                AppColors.border,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
              transform: SlidingGradientTransform(_animation.value),
            ),
          ),
        );
      },
    );
  }
}

class SlidingGradientTransform extends GradientTransform {
  final double offset;
  
  const SlidingGradientTransform(this.offset);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(offset * bounds.width, 0, 0);
  }
}

/// Pet list loading skeleton
class PetListLoadingSkeleton extends StatelessWidget {
  const PetListLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      padding: AppSpacing.pageInsets,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.md),
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Row(
            children: [
              LoadingSkeleton(
                height: 64,
                width: 64,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              AppSpacing.hSpaceMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingSkeleton(
                      height: 20,
                      width: double.infinity,
                    ),
                    AppSpacing.vSpaceXs,
                    LoadingSkeleton(
                      height: 16,
                      width: 150,
                    ),
                    AppSpacing.vSpaceXs,
                    LoadingSkeleton(
                      height: 14,
                      width: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Chart loading skeleton
class ChartLoadingSkeleton extends StatelessWidget {
  const ChartLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingSkeleton(height: 24, width: 120),
          AppSpacing.vSpaceMd,
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final heights = [60.0, 120.0, 80.0, 160.0, 100.0, 140.0, 90.0];
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: LoadingSkeleton(
                      height: heights[index],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard cards loading skeleton
class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: AppSpacing.cardInsets,
                margin: EdgeInsets.only(right: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingSkeleton(height: 16, width: 80),
                    AppSpacing.vSpaceSm,
                    LoadingSkeleton(height: 28, width: 60),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: AppSpacing.cardInsets,
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingSkeleton(height: 16, width: 70),
                    AppSpacing.vSpaceSm,
                    LoadingSkeleton(height: 28, width: 50),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: AppSpacing.cardInsets,
                margin: EdgeInsets.only(left: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingSkeleton(height: 16, width: 90),
                    AppSpacing.vSpaceSm,
                    LoadingSkeleton(height: 28, width: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vSpaceLg,
        // Chart
        ChartLoadingSkeleton(),
      ],
    );
  }
}

/// Loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.background.withOpacity(0.8),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.borderRadiusLg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: AppSpacing.elevationLg,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    if (message != null) ...[
                      AppSpacing.vSpaceMd,
                      Text(
                        message!,
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}