import 'package:flutter/material.dart';
import '../../screens/tasks_screen.dart';
import '../../screens/theme_selector_screen.dart';

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
      // Auth routes - these will be implemented when we create screens
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Login Screen - To be implemented')),
          ),
        );
        
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Register Screen - To be implemented')),
          ),
        );
        
      case AppRoutes.home:
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Dashboard Screen - To be implemented')),
          ),
        );
      
      case AppRoutes.tasks:
        final filter = args as String?;
        return MaterialPageRoute(
          builder: (_) => TasksScreen(filter: filter),
        );
      
      case AppRoutes.themeSelector:
        return MaterialPageRoute(
          builder: (_) => const ThemeSelectorScreen(),
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
