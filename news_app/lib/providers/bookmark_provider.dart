import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/database_service.dart';

class BookmarkProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<Article> _bookmarks = [];
  bool _isLoading = false;
  Set<String> _bookmarkedUrls = {};

  List<Article> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  int get bookmarksCount => _bookmarks.length;

  BookmarkProvider() {
    loadBookmarks();
  }

  // Load tất cả bookmarks
  Future<void> loadBookmarks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookmarks = await _db.getBookmarks();
      _bookmarkedUrls = _bookmarks.map((a) => a.url).toSet();
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kiểm tra article có được bookmark chưa
  bool isBookmarked(String url) {
    return _bookmarkedUrls.contains(url);
  }

  // Toggle bookmark
  Future<bool> toggleBookmark(Article article) async {
    try {
      if (isBookmarked(article.url)) {
        // Remove bookmark
        await _db.removeBookmark(article.url);
        _bookmarks.removeWhere((a) => a.url == article.url);
        _bookmarkedUrls.remove(article.url);
        notifyListeners();
        return false;
      } else {
        // Add bookmark
        await _db.addBookmark(article);
        final bookmarkedArticle = article.copyWith(isBookmarked: true);
        _bookmarks.insert(0, bookmarkedArticle);
        _bookmarkedUrls.add(article.url);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
      return isBookmarked(article.url);
    }
  }

  // Add bookmark
  Future<void> addBookmark(Article article) async {
    if (!isBookmarked(article.url)) {
      await toggleBookmark(article);
    }
  }

  // Remove bookmark
  Future<void> removeBookmark(String url) async {
    if (isBookmarked(url)) {
      try {
        await _db.removeBookmark(url);
        _bookmarks.removeWhere((a) => a.url == url);
        _bookmarkedUrls.remove(url);
        notifyListeners();
      } catch (e) {
        debugPrint('Error removing bookmark: $e');
      }
    }
  }

  // Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    try {
      for (var article in _bookmarks) {
        await _db.removeBookmark(article.url);
      }
      _bookmarks.clear();
      _bookmarkedUrls.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing bookmarks: $e');
    }
  }

  // Search trong bookmarks
  List<Article> searchBookmarks(String query) {
    if (query.isEmpty) return _bookmarks;

    final lowercaseQuery = query.toLowerCase();
    return _bookmarks.where((article) {
      return article.title.toLowerCase().contains(lowercaseQuery) ||
          (article.description?.toLowerCase().contains(lowercaseQuery) ??
              false) ||
          (article.author?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }
}
