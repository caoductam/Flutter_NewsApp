import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';
import '../providers/offline_provider.dart';
import '../services/news_service.dart';
import 'detail_screen.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({Key? key}) : super(key: key);

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  List<Article> _filteredArticles = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfflineProvider>().loadOfflineArticles();
    });
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredArticles = context
            .read<OfflineProvider>()
            .searchOfflineArticles(query);
      }
    });
  }

  void _changeCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      _isSearching = false;
    });
    await context.read<OfflineProvider>().loadOfflineArticles(
      category: category == 'all' ? null : category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Articles'),
        actions: [
          Consumer<OfflineProvider>(
            builder: (context, offlineProvider, child) {
              if (offlineProvider.offlineArticles.isEmpty)
                return const SizedBox();

              return PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'storage',
                    child: Row(
                      children: [
                        const Icon(Icons.storage),
                        const SizedBox(width: 8),
                        Text('Storage: ${offlineProvider.getStorageSize()}'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Clear All'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'clear') {
                    _showClearDialog(context);
                  } else if (value == 'storage') {
                    _showStorageInfo(context, offlineProvider);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<OfflineProvider>(
        builder: (context, offlineProvider, child) {
          if (offlineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (offlineProvider.offlineArticles.isEmpty) {
            return _buildEmptyState();
          }

          final displayArticles = _isSearching
              ? _filteredArticles
              : offlineProvider.offlineArticles;

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search offline articles...',
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: _performSearch,
                ),
              ),

              // Category filter
              if (!_isSearching)
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildCategoryChip(
                        'all',
                        'All',
                        offlineProvider.offlineCount,
                      ),
                      ...NewsService.categories.map((category) {
                        final count =
                            offlineProvider.categoryCount[category] ?? 0;
                        if (count == 0) return const SizedBox.shrink();
                        return _buildCategoryChip(
                          category,
                          NewsService.getCategoryDisplayName(category),
                          count,
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Counter & Storage info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.offline_pin, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${displayArticles.length} article${displayArticles.length != 1 ? 's' : ''}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.storage, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      offlineProvider.getStorageSize(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // List
              Expanded(
                child: displayArticles.isEmpty
                    ? Center(
                        child: Text(
                          'No offline articles found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayArticles.length,
                        itemBuilder: (context, index) {
                          return _buildOfflineCard(
                            displayArticles[index],
                            offlineProvider,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label, int count) {
    final isSelected = category == _selectedCategory;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _changeCategory(category);
          }
        },
        avatar: category != 'all'
            ? Icon(
                NewsService.getCategoryIcon(category),
                size: 16,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              )
            : null,
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Offline Articles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save articles for offline reading',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineCard(Article article, OfflineProvider provider) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    String formattedDate = '';

    try {
      final date = DateTime.parse(article.publishedAt);
      formattedDate = dateFormat.format(date);
    } catch (e) {
      formattedDate = article.publishedAt;
    }

    return Dismissible(
      key: Key(article.url),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteDialog(context, article.title);
      },
      onDismissed: (direction) {
        provider.removeOfflineArticle(article.url);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Article removed from offline storage'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                provider.addOfflineArticle(article, _selectedCategory);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                // Offline badge & Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: article.urlToImage != null
                          ? Image.network(
                              article.urlToImage!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            )
                          : _buildPlaceholder(),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.offline_pin,
                          size: 12,
                          color: Colors.white,
                        ),
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
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (article.description != null)
                        Text(
                          article.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.article, color: Colors.grey),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context, String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Article'),
            content: Text('Remove "$title" from offline storage?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Offline Articles'),
        content: const Text(
          'Are you sure you want to remove all offline articles? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<OfflineProvider>().clearAllOfflineArticles();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All offline articles cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo(BuildContext context, OfflineProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Total Articles', '${provider.offlineCount}'),
            const SizedBox(height: 8),
            _buildInfoRow('Storage Used', provider.getStorageSize()),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'By Category:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...provider.categoryCount.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _buildInfoRow(
                  NewsService.getCategoryDisplayName(entry.key),
                  '${entry.value} article${entry.value != 1 ? 's' : ''}',
                ),
              );
            }),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
