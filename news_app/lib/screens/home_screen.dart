// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/article.dart';
// import '../services/news_service.dart';
// import 'detail_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final NewsService _newsService = NewsService();
//   final TextEditingController _searchController = TextEditingController();
//   late Future<List<Article>> _articlesFuture;
//   bool _isSearching = false;

//   @override
//   void initState() {
//     super.initState();
//     _articlesFuture = _newsService.fetchTopHeadlines();
//   }

//   void _performSearch(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         _articlesFuture = _newsService.fetchTopHeadlines();
//         _isSearching = false;
//       });
//     } else {
//       setState(() {
//         _articlesFuture = _newsService.searchNews(query);
//         _isSearching = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('News Reader'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(60),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search news...',
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _isSearching
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           _performSearch('');
//                         },
//                       )
//                     : null,
//               ),
//               onSubmitted: _performSearch,
//             ),
//           ),
//         ),
//       ),
//       body: FutureBuilder<List<Article>>(
//         future: _articlesFuture,
//         builder: (context, snapshot) {
//           // Đang tải dữ liệu
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           // Có lỗi xảy ra
//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 60, color: Colors.red),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Error: ${snapshot.error}',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _articlesFuture = _newsService.fetchTopHeadlines();
//                       });
//                     },
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           // Không có dữ liệu
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No articles found'));
//           }

//           // Hiển thị danh sách tin tức
//           final articles = snapshot.data!;
//           return RefreshIndicator(
//             onRefresh: () async {
//               setState(() {
//                 _articlesFuture = _isSearching
//                     ? _newsService.searchNews(_searchController.text)
//                     : _newsService.fetchTopHeadlines();
//               });
//             },
//             child: ListView.builder(
//               itemCount: articles.length,
//               itemBuilder: (context, index) {
//                 return _buildArticleCard(articles[index]);
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildArticleCard(Article article) {
//     final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
//     String formattedDate = '';

//     try {
//       final date = DateTime.parse(article.publishedAt);
//       formattedDate = dateFormat.format(date);
//     } catch (e) {
//       formattedDate = article.publishedAt;
//     }

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       elevation: 2,
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DetailScreen(article: article),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Hình ảnh
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: article.urlToImage != null
//                     ? Image.network(
//                         article.urlToImage!,
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return _buildPlaceholderImage();
//                         },
//                       )
//                     : _buildPlaceholderImage(),
//               ),
//               const SizedBox(width: 12),
//               // Nội dung
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       article.title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 3,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     if (article.author != null)
//                       Text(
//                         article.author!,
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPlaceholderImage() {
//     return Container(
//       width: 100,
//       height: 100,
//       color: Colors.grey[300],
//       child: const Icon(Icons.article, size: 40, color: Colors.grey),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../models/sort_option.dart';
import '../services/news_service.dart';
import '../services/preferences_service.dart';
import '../providers/theme_provider.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsService _newsService = NewsService();
  final PreferencesService _prefsService = PreferencesService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Article>> _articlesFuture;
  List<Article> _currentArticles = [];

  String _selectedCategory = 'general';
  SortOption _sortOption = SortOption.newest;
  bool _isSearching = false;

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
    _loadNews();
  }

  void _loadNews() {
    setState(() {
      _articlesFuture = _newsService.fetchByCategory(_selectedCategory);
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _loadNews();
      });
    } else {
      setState(() {
        _isSearching = true;
        _articlesFuture = _newsService.searchNews(query);
      });
    }
  }

  void _changeCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      _isSearching = false;
      _loadNews();
    });
    await _prefsService.saveSelectedCategory(category);
  }

  void _changeSortOption(SortOption? option) async {
    if (option != null) {
      setState(() {
        _sortOption = option;
        // Re-sort current articles
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Reader'),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: 'Toggle theme',
          ),
          // Sort button
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort articles',
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
                        option.displayName,
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
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
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
                    hintText: 'Search news...',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
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
              // Categories chips
              if (!_isSearching)
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
                              Text(
                                NewsService.getCategoryDisplayName(category),
                              ),
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
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadNews();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles found'));
          }

          _currentArticles = List.from(snapshot.data!);
          _sortArticles(_currentArticles);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                if (_isSearching) {
                  _articlesFuture = _newsService.searchNews(
                    _searchController.text,
                  );
                } else {
                  _loadNews();
                }
              });
            },
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
        onTap: () {
          Navigator.push(
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
              // Hình ảnh với Hero animation
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
              const SizedBox(width: 12),
              // Nội dung
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
