import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_manager.dart';
import '../core/theme/config/theme_config.dart';

/// Theme selector screen
/// Allows users to preview and select themes, and toggle light/dark mode
class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Theme'),
        actions: [
          // Dark mode toggle in app bar
          IconButton(
            icon: Icon(
              themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeManager.toggleThemeMode(),
            tooltip: themeManager.isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dark Mode Section
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(
                themeManager.isDarkMode
                    ? 'Currently using dark mode'
                    : 'Currently using light mode',
              ),
              value: themeManager.isDarkMode,
              onChanged: (_) => themeManager.toggleThemeMode(),
              secondary: Icon(
                themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Theme Selection Header
          Text(
            'Select Theme',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a color theme for the app',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),

          const SizedBox(height: 16),

          // Theme Cards
          ...themeManager.availableThemes.map((theme) {
            final isSelected = theme.id == themeManager.currentThemeId;
            return ThemePreviewCard(
              theme: theme,
              isSelected: isSelected,
              onTap: () => themeManager.setTheme(theme.id),
            );
          }),
        ],
      ),
    );
  }
}

/// Preview card for a single theme
class ThemePreviewCard extends StatelessWidget {
  final ThemeConfig theme;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemePreviewCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.preview.primaryColor
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color Preview Circles
              _buildColorPreview(
                theme.preview.primaryColor,
                theme.preview.secondaryColor,
                theme.preview.backgroundColor,
              ),

              const SizedBox(width: 16),

              // Theme Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          theme.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            color: theme.preview.primaryColor,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),

              // Selection Radio
              Radio<String>(
                value: theme.id,
                groupValue:
                    Provider.of<ThemeManager>(context, listen: false)
                        .currentThemeId,
                onChanged: (value) {
                  if (value != null) {
                    onTap();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPreview(Color primary, Color secondary, Color background) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          // Background circle
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
            ),
          ),
          // Secondary circle
          Positioned(
            left: 10,
            bottom: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: secondary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          // Primary circle (on top)
          Positioned(
            left: 0,
            top: 6,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
