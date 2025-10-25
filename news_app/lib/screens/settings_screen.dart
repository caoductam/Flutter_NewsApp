import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader(context, l10n.settingsAppearance),

          SwitchListTile(
            title: Text(l10n.settingsDarkMode),
            subtitle: Text(
              themeProvider.isDarkMode ? l10n.themeDark : l10n.themeLight,
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

          // Language Section
          _buildSectionHeader(context, l10n.settingsLanguage),

          ...LanguageProvider.supportedLocales.map((locale) {
            return RadioListTile<String>(
              title: Text(
                languageProvider.getLanguageName(locale.languageCode),
              ),
              value: locale.languageCode,
              groupValue: languageProvider.languageCode,
              onChanged: (value) async {
                if (value != null) {
                  await languageProvider.changeLanguage(value);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Language changed to ${languageProvider.getLanguageName(value)}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              secondary: const Icon(Icons.language),
            );
          }),

          const Divider(),

          // Storage Section
          _buildSectionHeader(context, l10n.settingsStorage),

          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Database Information'),
            subtitle: const Text('View storage usage'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showStorageDialog(context, l10n),
          ),

          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Remove all saved articles and settings'),
            onTap: () => _showClearAllDialog(context, l10n),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(context, l10n.settingsAbout),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About News Reader'),
            subtitle: Text(l10n.version),
            onTap: () {
              _showAboutDialog(context, l10n);
            },
          ),

          ListTile(
            leading: const Icon(Icons.api),
            title: Text(l10n.poweredBy),
            subtitle: const Text('Tap to visit website'),
            onTap: () {
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

  Widget _buildSectionHeader(BuildContext context, String title) {
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

  void _showStorageDialog(BuildContext context, AppLocalizations l10n) async {
    final db = DatabaseService.instance;
    final bookmarksCount = await db.getBookmarksCount();
    final offlineCount = await db.getOfflineArticlesCount();

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.settingsStorage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(l10n.bookmarksTitle, '$bookmarksCount'),
              const SizedBox(height: 8),
              _buildInfoRow(l10n.offlineTitle, '$offlineCount'),
              const SizedBox(height: 8),
              _buildInfoRow(
                l10n.totalArticles,
                '${bookmarksCount + offlineCount}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showClearAllDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsClearData),
        content: const Text(
          'This will remove all bookmarks, offline articles, and reading history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final db = DatabaseService.instance;
              await db.clearAllData();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
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
          '• Multi-language support\n'
          '• Bookmark articles\n'
          '• Offline reading\n'
          '• Share articles\n'
          '• Sort options',
        ),
      ],
    );
  }
}
