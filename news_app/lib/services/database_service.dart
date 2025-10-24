import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/article.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('news_reader.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Tăng version nếu có thay đổi schema
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullType = 'TEXT';
    const intType = 'INTEGER NOT NULL DEFAULT 0';

    // Bảng bookmarks
    await db.execute('''
      CREATE TABLE bookmarks (
        id $idType,
        author $textNullType,
        title $textType,
        description $textNullType,
        url $textType UNIQUE,
        urlToImage $textNullType,
        publishedAt $textType,
        content $textNullType,
        bookmarkedAt $textType,
        isOffline $intType
      )
    ''');

    // Bảng offline articles
    await db.execute('''
      CREATE TABLE offline_articles (
        id $idType,
        author $textNullType,
        title $textType,
        description $textNullType,
        url $textType UNIQUE,
        urlToImage $textNullType,
        publishedAt $textType,
        content $textNullType,
        downloadedAt $textType,
        category $textNullType
      )
    ''');

    // Bảng reading history
    await db.execute('''
      CREATE TABLE reading_history (
        id $idType,
        url $textType UNIQUE,
        title $textType,
        readAt $textType,
        readCount $intType
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add upgrade logic here if needed
    }
  }

  // ==================== BOOKMARKS ====================

  Future<int> addBookmark(Article article) async {
    final db = await database;

    final data = {
      'author': article.author,
      'title': article.title,
      'description': article.description,
      'url': article.url,
      'urlToImage': article.urlToImage,
      'publishedAt': article.publishedAt,
      'content': article.content,
      'bookmarkedAt': DateTime.now().toIso8601String(),
      'isOffline': article.isOffline ? 1 : 0,
    };

    return await db.insert(
      'bookmarks',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeBookmark(String url) async {
    final db = await database;
    return await db.delete('bookmarks', where: 'url = ?', whereArgs: [url]);
  }

  Future<List<Article>> getBookmarks() async {
    final db = await database;
    final result = await db.query('bookmarks', orderBy: 'bookmarkedAt DESC');

    return result.map((json) {
      return Article.fromJson(json).copyWith(isBookmarked: true);
    }).toList();
  }

  Future<bool> isBookmarked(String url) async {
    final db = await database;
    final result = await db.query(
      'bookmarks',
      where: 'url = ?',
      whereArgs: [url],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> getBookmarksCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM bookmarks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== OFFLINE ARTICLES ====================

  Future<int> addOfflineArticle(Article article, String category) async {
    final db = await database;

    final data = {
      'author': article.author,
      'title': article.title,
      'description': article.description,
      'url': article.url,
      'urlToImage': article.urlToImage,
      'publishedAt': article.publishedAt,
      'content': article.content,
      'downloadedAt': DateTime.now().toIso8601String(),
      'category': category,
    };

    return await db.insert(
      'offline_articles',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeOfflineArticle(String url) async {
    final db = await database;
    return await db.delete(
      'offline_articles',
      where: 'url = ?',
      whereArgs: [url],
    );
  }

  Future<List<Article>> getOfflineArticles({String? category}) async {
    final db = await database;

    List<Map<String, dynamic>> result;
    if (category != null && category != 'all') {
      result = await db.query(
        'offline_articles',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'downloadedAt DESC',
      );
    } else {
      result = await db.query('offline_articles', orderBy: 'downloadedAt DESC');
    }

    return result.map((json) {
      return Article.fromJson(json).copyWith(isOffline: true);
    }).toList();
  }

  Future<bool> isOffline(String url) async {
    final db = await database;
    final result = await db.query(
      'offline_articles',
      where: 'url = ?',
      whereArgs: [url],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> getOfflineArticlesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM offline_articles');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, int>> getOfflineArticlesByCategory() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM offline_articles 
      GROUP BY category
    ''');

    Map<String, int> categoryCount = {};
    for (var row in result) {
      categoryCount[row['category'] as String] = row['count'] as int;
    }
    return categoryCount;
  }

  // ==================== READING HISTORY ====================

  Future<void> addToHistory(Article article) async {
    final db = await database;

    final existing = await db.query(
      'reading_history',
      where: 'url = ?',
      whereArgs: [article.url],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('reading_history', {
        'url': article.url,
        'title': article.title,
        'readAt': DateTime.now().toIso8601String(),
        'readCount': 1,
      });
    } else {
      await db.update(
        'reading_history',
        {
          'readAt': DateTime.now().toIso8601String(),
          'readCount': (existing.first['readCount'] as int) + 1,
        },
        where: 'url = ?',
        whereArgs: [article.url],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getReadingHistory({int limit = 50}) async {
    final db = await database;
    return await db.query(
      'reading_history',
      orderBy: 'readAt DESC',
      limit: limit,
    );
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('reading_history');
  }

  // ==================== UTILITY ====================

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('bookmarks');
    await db.delete('offline_articles');
    await db.delete('reading_history');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
