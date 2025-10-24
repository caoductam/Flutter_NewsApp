import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/news_service.dart';
import '../services/preferences_service.dart';
import '../models/sort_option.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefsService = PreferencesService();
  String _selectedCategory = 'general';
  String _sortOption = 'newest';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final category = await _prefsService.getSelectedCategory();
    final sort = await _prefsService.getSortOption();

    setState(() {
      _selectedCategory = category;
      _sortOption = sort;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Theme Section
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(
              themeProvider.isDarkMode
                  ? 'Dark theme is enabled'
                  : 'Light theme is enabled',
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          const Divider(),

          // Default Category Section
          _buildSectionHeader('Default Category'),
          ...NewsService.categories.map((category) {
            return RadioListTile<String>(
              title: Text(NewsService.getCategoryDisplayName(category)),
              subtitle: Text('Show $category news by default'),
              value: category,
              groupValue: _selectedCategory,
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                  await _prefsService.saveSelectedCategory(value);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Default category changed to ${NewsService.getCategoryDisplayName(value)}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              secondary: Icon(NewsService.getCategoryIcon(category)),
            );
          }).toList(),
          const Divider(),

          // Default Sort Section
          _buildSectionHeader('Default Sort Order'),
          ...SortOption.values.map((option) {
            return RadioListTile<String>(
              title: Text(option.displayName),
              subtitle: Text(
                'Sort articles by ${option.displayName.toLowerCase()}',
              ),
              value: option.name,
              groupValue: _sortOption,
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _sortOption = value;
                  });
                  await _prefsService.saveSortOption(value);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Default sort changed to ${option.displayName}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              secondary: Icon(option.icon),
            );
          }).toList(),
          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About News Reader'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.api),
            title: const Text('Powered by NewsAPI.org'),
            subtitle: const Text('Tap to visit website'),
            onTap: () {
              // Launch NewsAPI website
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('NewsAPI.org - News data source')),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'News Reader',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.article, size: 48),
      children: [
        const Text('A modern news reading application built with Flutter.'),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• Browse news by category\n'
          '• Search articles\n'
          '• Dark/Light theme\n'
          '• Sort options\n'
          '• Share articles\n'
          '• Offline reading support',
        ),
      ],
    );
  }
}
