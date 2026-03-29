import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/auth_gate.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
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

  // Create and initialize auth service
  final authService = AuthService();
  await authService.initialize();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatefulWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Theme mode state (light by default, dark mode button will toggle this)
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>.value(
      value: widget.authService,
      child: MaterialApp(
        title: 'Pet Care',
        debugShowCheckedModeBanner: false,
        // Use our custom themes
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: _themeMode,
        // Use our routing system
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: AppRoutes.login,
        // Keep auth gate as home for now
        home: const AuthGate(),
      ),
    );
  }
}