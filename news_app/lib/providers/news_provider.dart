import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import '../services/database_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  final DatabaseService _db = DatabaseService.instance;

  List<Article> _articles = [];
  bool _isLoading = false;
  String? _error;
  String _currentCategory = 'general';
  String _searchQuery = '';
  bool _isSearching = false;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentCategory => _currentCategory;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  // Fetch news by category
  Future<void> fetchNews({String category = 'general'}) async {
    _isLoading = true;
    _error = null;
    _currentCategory = category;
    _isSearching = false;
    _searchQuery = '';
    notifyListeners();

    try {
      _articles = await _newsService.fetchByCategory(category);
      await _markBookmarkedArticles();
      await _markOfflineArticles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search news
  Future<void> searchNews(String query) async {
    if (query.isEmpty) {
      await fetchNews(category: _currentCategory);
      return;
    }

    _isLoading = true;
    _error = null;
    _isSearching = true;
    _searchQuery = query;
    notifyListeners();

    try {
      _articles = await _newsService.searchNews(query);
      await _markBookmarkedArticles();
      await _markOfflineArticles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh news
  Future<void> refreshNews() async {
    if (_isSearching && _searchQuery.isNotEmpty) {
      await searchNews(_searchQuery);
    } else {
      await fetchNews(category: _currentCategory);
    }
  }

  // Mark bookmarked articles
  Future<void> _markBookmarkedArticles() async {
    for (int i = 0; i < _articles.length; i++) {
      final isBookmarked = await _db.isBookmarked(_articles[i].url);
      if (isBookmarked) {
        _articles[i] = _articles[i].copyWith(isBookmarked: true);
      }
    }
  }

  // Mark offline articles
  Future<void> _markOfflineArticles() async {
    for (int i = 0; i < _articles.length; i++) {
      final isOffline = await _db.isOffline(_articles[i].url);
      if (isOffline) {
        _articles[i] = _articles[i].copyWith(isOffline: true);
      }
    }
  }

  // Update article bookmark status
  void updateArticleBookmarkStatus(String url, bool isBookmarked) {
    final index = _articles.indexWhere((a) => a.url == url);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(isBookmarked: isBookmarked);
      notifyListeners();
    }
  }

  // Update article offline status
  void updateArticleOfflineStatus(String url, bool isOffline) {
    final index = _articles.indexWhere((a) => a.url == url);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(isOffline: isOffline);
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Track article view in history
  Future<void> trackArticleView(Article article) async {
    try {
      await _db.addToHistory(article);
    } catch (e) {
      debugPrint('Error tracking article view: $e');
    }
  }
}
