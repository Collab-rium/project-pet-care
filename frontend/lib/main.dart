import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/auth_gate.dart';
import 'core/theme/theme_manager.dart';
import 'core/utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized');
  } catch (e) {
    print('⚠️ Firebase initialization warning: $e');
    // App continues without Firebase
  }

  // Initialize notifications
  try {
    await NotificationService.initialize();
  } catch (e) {
    print('⚠️ Notification service initialization warning: $e');
  }

  // Create and initialize services
  final authService = AuthService();
  await authService.initialize();
  
  final themeManager = ThemeManager();
  await themeManager.initialize();

  runApp(MyApp(
    authService: authService,
    themeManager: themeManager,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ThemeManager themeManager;

  const MyApp({
    super.key,
    required this.authService,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<ThemeManager>.value(value: themeManager),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Pet Care',
            debugShowCheckedModeBanner: false,
            theme: themeManager.getLightTheme(),
            darkTheme: themeManager.getDarkTheme(),
            themeMode: themeManager.themeMode,
            onGenerateRoute: RouteGenerator.generateRoute,
            initialRoute: AppRoutes.login,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}