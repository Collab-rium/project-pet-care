import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dashboard_screen.dart';
import 'pet_list_screen.dart';
import 'budget_screen.dart';
import 'account_screen.dart';
import '../core/services/logger_service.dart';
import '../core/services/file_logger_service.dart';

/// Home screen with bottom navigation and wallpaper support
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _wallpaperPath;

  final _screens = const [
    DashboardScreen(),
    PetListScreen(),
    BudgetScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    LoggerService.info('HomeScreen: Screen opened');
    FileLoggerService.log('HomeScreen: Screen initialized');
    _loadWallpaper();
  }

  Future<void> _loadWallpaper() async {
    try {
      LoggerService.info('HomeScreen: Loading wallpaper...');
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _wallpaperPath = prefs.getString('wallpaper_path');
      });
      LoggerService.info('HomeScreen: Wallpaper loaded (${_wallpaperPath != null ? 'set' : 'not set'})');
      await FileLoggerService.log('HomeScreen: Wallpaper loaded');
    } catch (e, st) {
      LoggerService.error('HomeScreen: Failed to load wallpaper - $e', exception: e);
      await FileLoggerService.logError('HomeScreen wallpaper load failed', exception: e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Wallpaper background
          if (_wallpaperPath != null && File(_wallpaperPath!).existsSync())
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.file(
                  File(_wallpaperPath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Main content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Pets',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
