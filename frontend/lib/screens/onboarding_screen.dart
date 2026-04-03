import 'package:flutter/material.dart';

import '../components/atoms/app_button.dart';
import '../components/molecules/app_form_field.dart';
import '../components/atoms/app_input.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/error_handler.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Quick pet form data
  final _petNameController = TextEditingController();
  final _petSpeciesController = TextEditingController();
  String _selectedSpecies = 'dog';
  
  final List<String> _species = ['dog', 'cat', 'bird', 'fish', 'rabbit', 'hamster', 'other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: AppSpacing.pageInsets,
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 3 ? AppSpacing.sm : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage ? AppColors.primary : AppColors.border,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Skip button
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildAddPetPage(),
                  _buildFeatureTourPage(),
                  _buildCompletePage(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: AppSpacing.pageInsets,
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: AppButton.outlined(
                        text: 'Back',
                        onPressed: _previousPage,
                      ),
                    ),
                  if (_currentPage > 0) AppSpacing.hSpaceMd,
                  Expanded(
                    flex: _currentPage > 0 ? 1 : 2,
                    child: AppButton.primary(
                      text: _getButtonText(),
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: AppSpacing.pageInsets,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App icon/logo placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Icon(
              Icons.pets,
              size: 64,
              color: AppColors.primary,
            ),
          ),

          AppSpacing.vSpaceXl,

          Text(
            'Welcome to Pet Care',
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),

          AppSpacing.vSpaceLg,

          Text(
            'Your all-in-one companion for managing your pets\' health, reminders, and memories.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.vSpaceXl,

          // Features preview
          _buildFeaturePreview(
            Icons.notifications_active,
            'Smart Reminders',
            'Never miss medication or vet appointments',
          ),

          AppSpacing.vSpaceLg,

          _buildFeaturePreview(
            Icons.photo_camera,
            'Photo Memories',
            'Capture and organize your pet\'s precious moments',
          ),

          AppSpacing.vSpaceLg,

          _buildFeaturePreview(
            Icons.analytics,
            'Health Tracking',
            'Monitor weight, expenses, and health records',
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetPage() {
    return Padding(
      padding: AppSpacing.pageInsets,
      child: Column(
        children: [
          AppSpacing.vSpaceXl,
          
          Icon(
            Icons.pets,
            size: 80,
            color: AppColors.primary,
          ),

          AppSpacing.vSpaceLg,

          Text(
            'Add Your First Pet',
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),

          AppSpacing.vSpaceMd,

          Text(
            'Let\'s start by adding your pet\'s basic information. You can add more details later.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.vSpaceXl,

          // Quick form
          AppFormField(
            label: 'Pet Name',
            child: AppInput(
              controller: _petNameController,
              placeholder: 'e.g., Max, Luna, Buddy',
            ),
          ),

          AppSpacing.vSpaceLg,

          AppFormField(
            label: 'Species',
            child: DropdownButton<String>(
              value: _selectedSpecies,
              isExpanded: true,
              items: _species.map((species) {
                return DropdownMenuItem(
                  value: species,
                  child: Text(_capitalizeFirst(species)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSpecies = value!),
              underline: Container(
                height: 1,
                color: AppColors.border,
              ),
            ),
          ),

          Spacer(),

          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusMd,
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
                    'Don\'t worry! You can add more pets and detailed information anytime from the app.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTourPage() {
    return Padding(
      padding: AppSpacing.pageInsets,
      child: Column(
        children: [
          AppSpacing.vSpaceXl,
          
          Text(
            'Explore the Features',
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),

          AppSpacing.vSpaceMd,

          Text(
            'Here\'s a quick tour of what you can do with Pet Care',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.vSpaceXl,

          Expanded(
            child: ListView(
              children: [
                _buildDetailedFeature(
                  Icons.dashboard,
                  'Dashboard',
                  'Get an overview of upcoming reminders, recent activities, and your pets\' status at a glance.',
                  AppColors.primary,
                ),

                AppSpacing.vSpaceLg,

                _buildDetailedFeature(
                  Icons.schedule,
                  'Reminders',
                  'Set up medication schedules, vet appointments, feeding times, and grooming sessions.',
                  AppColors.secondary,
                ),

                AppSpacing.vSpaceLg,

                _buildDetailedFeature(
                  Icons.trending_up,
                  'Weight Tracking',
                  'Monitor your pet\'s weight over time with interactive charts and health insights.',
                  AppColors.success,
                ),

                AppSpacing.vSpaceLg,

                _buildDetailedFeature(
                  Icons.receipt,
                  'Expense Tracking',
                  'Keep track of veterinary bills, food costs, and other pet-related expenses.',
                  AppColors.warning,
                ),

                AppSpacing.vSpaceLg,

                _buildDetailedFeature(
                  Icons.photo_album,
                  'Photo Gallery',
                  'Store and organize photos of your pets, create albums, and capture memories.',
                  AppColors.info,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletePage() {
    return Padding(
      padding: AppSpacing.pageInsets,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success animation placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: AppColors.success,
            ),
          ),

          AppSpacing.vSpaceXl,

          Text(
            'You\'re All Set!',
            style: AppTextStyles.h1.copyWith(
              color: AppColors.success,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.vSpaceLg,

          Text(
            'Welcome to Pet Care! You\'re ready to start managing your pets\' health and happiness.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.vSpaceXl,

          // Quick stats about what they can do now
          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(
                  'What\'s Next?',
                  style: AppTextStyles.h3,
                ),
                AppSpacing.vSpaceMd,
                _buildNextStepItem(Icons.add, 'Add more pets to your profile'),
                _buildNextStepItem(Icons.alarm, 'Set up your first reminder'),
                _buildNextStepItem(Icons.camera, 'Take some photos of your pets'),
                _buildNextStepItem(Icons.settings, 'Customize your app preferences'),
              ],
            ),
          ),

          AppSpacing.vSpaceXl,

          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: AppColors.primary,
                  size: 20,
                ),
                AppSpacing.hSpaceSm,
                Expanded(
                  child: Text(
                    'Tip: Check out the settings to customize themes, notifications, and backup options!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePreview(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Icon(
            icon,
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
                title,
                style: AppTextStyles.h4,
              ),
              AppSpacing.vSpaceXs,
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedFeature(IconData icon, String title, String description, Color color) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    color: color,
                  ),
                ),
                AppSpacing.vSpaceXs,
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.success,
          ),
          AppSpacing.hSpaceSm,
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (_currentPage) {
      case 0:
        return 'Get Started';
      case 1:
        return 'Continue';
      case 2:
        return 'Looks Great!';
      case 3:
        return 'Start Using Pet Care';
      default:
        return 'Next';
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Skip Onboarding?'),
        content: Text('Are you sure you want to skip the setup? You can always access these features later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completeOnboarding();
            },
            child: Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding() {
    // Save that onboarding is complete (placeholder for SharedPreferences)
    // Save pet data if provided
    if (_petNameController.text.isNotEmpty) {
      // Create pet with basic info
    }
    
    AppErrorHandler.showSuccessSnackBar(
      context,
      'Welcome to Pet Care! Onboarding complete.',
    );
    
    // Navigate to main app (placeholder)
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  String _capitalizeFirst(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _petNameController.dispose();
    _petSpeciesController.dispose();
    super.dispose();
  }
}