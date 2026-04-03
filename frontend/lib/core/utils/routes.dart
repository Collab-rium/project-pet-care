import 'package:flutter/material.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/tasks_screen.dart';
import '../../screens/wallpaper_screen.dart';
import '../../screens/notification_settings_screen.dart';
import '../../screens/payment_subscription_screen.dart';
import '../../screens/backup_restore_screen.dart';
import '../../screens/account_screen.dart';
import '../../screens/pet_list_screen.dart';
import '../../screens/add_pet_screen.dart';
import '../../screens/budget_screen.dart';
import '../../screens/add_expense_screen.dart';
import '../../screens/expense_list_screen.dart';

/// App routes configuration
class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

  // Main routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Pet routes
  static const String petList = '/pets';
  static const String petDetail = '/pets/detail';
  static const String addPet = '/pets/add';
  static const String petProfile = '/pets/profile';

  // Tasks
  static const String tasks = '/tasks';

  // Weight tracking
  static const String weightTracking = '/weight';
  static const String addWeight = '/weight/add';

  // Reminders
  static const String reminders = '/reminders';
  static const String addReminder = '/reminders/add';
  static const String editReminder = '/reminders/edit';

  // Expenses & Budget
  static const String expenses = '/expenses';
  static const String addExpense = '/expenses/add';
  static const String budget = '/budget';
  static const String budgetDetail = '/budget/detail';

  // Gallery
  static const String gallery = '/gallery';

  // Settings & Account
  static const String settings = '/settings';
  static const String account = '/account';
  static const String themeSelector = '/settings/theme';
  static const String wallpaper = '/settings/wallpaper';
  static const String notificationSettings = '/settings/notifications';
  static const String backupRestore = '/settings/backup';
  static const String payment = '/payment';
  static const String privacyPolicy = '/privacy';

  // Onboarding
  static const String onboarding = '/onboarding';
}

/// Route generator
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );

      case AppRoutes.petList:
        return MaterialPageRoute(
          builder: (_) => const PetListScreen(),
        );

      case AppRoutes.addPet:
        return MaterialPageRoute(
          builder: (_) => const AddPetScreen(),
        );

      case AppRoutes.budget:
        return MaterialPageRoute(
          builder: (_) => const BudgetScreen(),
        );

      case AppRoutes.addExpense:
        return MaterialPageRoute(
          builder: (_) => const AddExpenseScreen(),
        );

      case AppRoutes.tasks:
        final filter = args as String?;
        return MaterialPageRoute(
          builder: (_) => TasksScreen(filter: filter),
        );

      case AppRoutes.wallpaper:
        return MaterialPageRoute(
          builder: (_) => const WallpaperScreen(),
        );

      case AppRoutes.notificationSettings:
        return MaterialPageRoute(
          builder: (_) => const NotificationSettingsScreen(),
        );

      case AppRoutes.payment:
        return MaterialPageRoute(
          builder: (_) => const PaymentSubscriptionScreen(),
        );

      case AppRoutes.backupRestore:
        return MaterialPageRoute(
          builder: (_) => const BackupRestoreScreen(),
        );

      case AppRoutes.account:
        return MaterialPageRoute(
          builder: (_) => const AccountScreen(),
        );

      // Add more routes as screens are implemented
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}
