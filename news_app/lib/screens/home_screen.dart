import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../l10n/app_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/article.dart';
import '../models/sort_option.dart';
import '../services/news_service.dart';
import '../services/preferences_service.dart';
import '../providers/theme_provider.dart';
import '../providers/news_provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/offline_provider.dart';
import 'detail_screen.dart';
import 'bookmarks_screen.dart';
import 'offline_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PreferencesService _prefsService = PreferencesService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'general';
  SortOption _sortOption = SortOption.newest;
  List<Article> _currentArticles = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _selectedCategory = await _prefsService.getSelectedCategory();
    final sortString = await _prefsService.getSortOption();
    _sortOption = SortOption.values.firstWhere(
      (e) => e.name == sortString,
      orElse: () => SortOption.newest,
    );

    // Load news
    if (mounted) {
      context.read<NewsProvider>().fetchNews(category: _selectedCategory);
    }
  }

  void _performSearch(String query) {
    context.read<NewsProvider>().searchNews(query);
  }

  void _changeCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
    });
    await _prefsService.saveSelectedCategory(category);
    if (mounted) {
      context.read<NewsProvider>().fetchNews(category: category);
    }
  }

  void _changeSortOption(SortOption? option) async {
    if (option != null) {
      setState(() {
        _sortOption = option;
        _sortArticles(_currentArticles);
      });
      await _prefsService.saveSortOption(option.name);
    }
  }

  void _sortArticles(List<Article> articles) {
    switch (_sortOption) {
      case SortOption.newest:
        articles.sort((a, b) {
          try {
            return DateTime.parse(
              b.publishedAt,
            ).compareTo(DateTime.parse(a.publishedAt));
          } catch (e) {
            return 0;
          }
        });
        break;
      case SortOption.oldest:
        articles.sort((a, b) {
          try {
            return DateTime.parse(
              a.publishedAt,
            ).compareTo(DateTime.parse(b.publishedAt));
          } catch (e) {
            return 0;
          }
        });
        break;
      case SortOption.titleAZ:
        articles.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleZA:
        articles.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: themeProvider.isDarkMode
                ? l10n.themeLight
                : l10n.themeDark,
          ),
          // Sort menu
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.settingsDefaultSort,
            onSelected: _changeSortOption,
            itemBuilder: (context) {
              return SortOption.values.map((option) {
                return PopupMenuItem<SortOption>(
                  value: option,
                  child: Row(
                    children: [
                      Icon(
                        option.icon,
                        color: _sortOption == option
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getSortDisplayName(option, l10n),
                        style: TextStyle(
                          fontWeight: _sortOption == option
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _sortOption == option
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          // Bookmarks button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookmarksScreen(),
                    ),
                  );
                },
                tooltip: l10n.bookmarksTitle,
              ),
              Consumer<BookmarkProvider>(
                builder: (context, bookmarkProvider, child) {
                  if (bookmarkProvider.bookmarksCount == 0) {
                    return const SizedBox();
                  }
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${bookmarkProvider.bookmarksCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          // Offline button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.offline_pin),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OfflineScreen(),
                    ),
                  );
                },
                tooltip: l10n.offlineTitle,
              ),
              Consumer<OfflineProvider>(
                builder: (context, offlineProvider, child) {
                  if (offlineProvider.offlineCount == 0) {
                    return const SizedBox();
                  }
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${offlineProvider.offlineCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: l10n.settingsTitle,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: context.watch<NewsProvider>().isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                  ),
                  onSubmitted: _performSearch,
                ),
              ),
              // Categories
              if (!context.watch<NewsProvider>().isSearching)
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: NewsService.categories.length,
                    itemBuilder: (context, index) {
                      final category = NewsService.categories[index];
                      final isSelected = category == _selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                NewsService.getCategoryIcon(category),
                                size: 16,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null,
                              ),
                              const SizedBox(width: 6),
                              Text(_getCategoryDisplayName(category, l10n)),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _changeCategory(category);
                            }
                          },
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.loading),
                ],
              ),
            );
          }

          if (newsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.error}: ${newsProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      newsProvider.refreshNews();
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (newsProvider.articles.isEmpty) {
            return Center(child: Text(l10n.noArticlesFound));
          }

          _currentArticles = List.from(newsProvider.articles);
          _sortArticles(_currentArticles);

          return RefreshIndicator(
            onRefresh: () => newsProvider.refreshNews(),
            child: ListView.builder(
              itemCount: _currentArticles.length,
              itemBuilder: (context, index) {
                return _buildArticleCard(_currentArticles[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
    String formattedDate = '';

    try {
      final date = DateTime.parse(article.publishedAt);
      formattedDate = dateFormat.format(date);
    } catch (e) {
      formattedDate = article.publishedAt;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () async {
          // Track article view
          context.read<NewsProvider>().trackArticleView(article);

          // Navigate to detail
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(article: article),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  Hero(
                    tag: 'image_${article.url}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: article.urlToImage != null
                          ? Image.network(
                              article.urlToImage!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage();
                              },
                            )
                          : _buildPlaceholderImage(),
                    ),
                  ),
                  // Badges
                  if (article.isBookmarked || article.isOffline)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Column(
                        children: [
                          if (article.isBookmarked)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bookmark,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          if (article.isOffline)
                            Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.only(top: 4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.offline_pin,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (article.author != null)
                      Text(
                        article.author!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[300],
      child: const Icon(Icons.article, size: 40, color: Colors.grey),
    );
  }

  String _getCategoryDisplayName(String category, AppLocalizations l10n) {
    switch (category) {
      case 'general':
        return l10n.categoryGeneral;
      case 'business':
        return l10n.categoryBusiness;
      case 'entertainment':
        return l10n.categoryEntertainment;
      case 'health':
        return l10n.categoryHealth;
      case 'science':
        return l10n.categoryScience;
      case 'sports':
        return l10n.categorySports;
      case 'technology':
        return l10n.categoryTechnology;
      default:
        return category;
    }
  }

  String _getSortDisplayName(SortOption option, AppLocalizations l10n) {
    switch (option) {
      case SortOption.newest:
        return l10n.sortNewest;
      case SortOption.oldest:
        return l10n.sortOldest;
      case SortOption.titleAZ:
        return l10n.sortTitleAZ;
      case SortOption.titleZA:
        return l10n.sortTitleZA;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
