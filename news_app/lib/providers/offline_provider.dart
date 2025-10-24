import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/database_service.dart';

class OfflineProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<Article> _offlineArticles = [];
  Map<String, int> _categoryCount = {};
  bool _isLoading = false;
  Set<String> _offlineUrls = {};
  List<Article> get offlineArticles => _offlineArticles;
  Map<String, int> get categoryCount => _categoryCount;
  bool get isLoading => _isLoading;
  int get offlineCount => _offlineArticles.length;
  OfflineProvider() {
    loadOfflineArticles();
  }
  // Load tất cả offline articles
  Future<void> loadOfflineArticles({String? category}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _offlineArticles = await _db.getOfflineArticles(category: category);
      _offlineUrls = _offlineArticles.map((a) => a.url).toSet();
      _categoryCount = await _db.getOfflineArticlesByCategory();
    } catch (e) {
      debugPrint('Error loading offline articles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kiểm tra article có offline chưa
  bool isOffline(String url) {
    return _offlineUrls.contains(url);
  }

  // Toggle offline
  Future<bool> toggleOffline(Article article, String category) async {
    try {
      if (isOffline(article.url)) {
        // Remove offline
        await _db.removeOfflineArticle(article.url);
        _offlineArticles.removeWhere((a) => a.url == article.url);
        _offlineUrls.remove(article.url);
        _categoryCount = await _db.getOfflineArticlesByCategory();
        notifyListeners();
        return false;
      } else {
        // Add offline
        await _db.addOfflineArticle(article, category);
        final offlineArticle = article.copyWith(isOffline: true);
        _offlineArticles.insert(0, offlineArticle);
        _offlineUrls.add(article.url);
        _categoryCount = await _db.getOfflineArticlesByCategory();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error toggling offline: $e');
      return isOffline(article.url);
    }
  }

  // Add offline article
  Future<void> addOfflineArticle(Article article, String category) async {
    if (!isOffline(article.url)) {
      await toggleOffline(article, category);
    }
  }

  // Remove offline article
  Future<void> removeOfflineArticle(String url) async {
    if (isOffline(url)) {
      try {
        await _db.removeOfflineArticle(url);
        _offlineArticles.removeWhere((a) => a.url == url);
        _offlineUrls.remove(url);
        _categoryCount = await _db.getOfflineArticlesByCategory();
        notifyListeners();
      } catch (e) {
        debugPrint('Error removing offline article: $e');
      }
    }
  }

  // Clear all offline articles
  Future<void> clearAllOfflineArticles() async {
    try {
      for (var article in _offlineArticles) {
        await _db.removeOfflineArticle(article.url);
      }
      _offlineArticles.clear();
      _offlineUrls.clear();
      _categoryCount.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing offline articles: $e');
    }
  }

  // Get offline articles by category
  Future<List<Article>> getOfflineByCategory(String category) async {
    return await _db.getOfflineArticles(category: category);
  }

  // Search trong offline articles
  List<Article> searchOfflineArticles(String query) {
    if (query.isEmpty) return _offlineArticles;
    final lowercaseQuery = query.toLowerCase();
    return _offlineArticles.where((article) {
      return article.title.toLowerCase().contains(lowercaseQuery) ||
          (article.description?.toLowerCase().contains(lowercaseQuery) ??
              false) ||
          (article.author?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Get storage size estimate (approximate)
  String getStorageSize() {
    int totalChars = 0;
    for (var article in _offlineArticles) {
      totalChars += article.title.length;
      totalChars += article.description?.length ?? 0;
      totalChars += article.content?.length ?? 0;
      totalChars += article.url.length;
    }
    // Rough estimate: 1 char ≈ 2 bytes (UTF-8)
    double sizeInKB = (totalChars * 2) / 1024;

    if (sizeInKB < 1024) {
      return '${sizeInKB.toStringAsFixed(2)} KB';
    } else {
      return '${(sizeInKB / 1024).toStringAsFixed(2)} MB';
    }
  }
}
