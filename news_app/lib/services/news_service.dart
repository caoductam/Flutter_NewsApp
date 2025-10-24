import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/article.dart';

class NewsService {
  // Thay YOUR_API_KEY bằng API key của bạn
  static const String _apiKey = 'de8bdaf5bb7f4cecb245d29d81fa6f6c';
  static const String _baseUrl = 'https://newsapi.org/v2';

  // Danh sách category hỗ trợ
  static const List<String> categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  // Lấy tin tức top headlines
  Future<List<Article>> fetchTopHeadlines({String country = 'us'}) async {
    final url = Uri.parse(
      '$_baseUrl/top-headlines?country=$country&apiKey=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List articles = jsonData['articles'];

        return articles.map((article) => Article.fromJson(article)).toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  // Lấy tin tức theo category
  Future<List<Article>> fetchByCategory(
    String category, {
    String country = 'us',
  }) async {
    final url = Uri.parse(
      '$_baseUrl/top-headlines?country=$country&category=$category&apiKey=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List articles = jsonData['articles'];

        return articles.map((article) => Article.fromJson(article)).toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  // Tìm kiếm tin tức theo từ khóa
  Future<List<Article>> searchNews(String query) async {
    final url = Uri.parse(
      '$_baseUrl/everything?q=$query&apiKey=$_apiKey&sortBy=publishedAt',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List articles = jsonData['articles'];

        return articles.map((article) => Article.fromJson(article)).toList();
      } else {
        throw Exception('Failed to search news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching news: $e');
    }
  }

  // Lấy tên hiển thị của category
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'general':
        return 'Tổng hợp';
      case 'business':
        return 'Kinh doanh';
      case 'entertainment':
        return 'Giải trí';
      case 'health':
        return 'Sức khỏe';
      case 'science':
        return 'Khoa học';
      case 'sports':
        return 'Thể thao';
      case 'technology':
        return 'Công nghệ';
      default:
        return category;
    }
  }

  // Lấy icon cho category
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'general':
        return Icons.article;
      case 'business':
        return Icons.business;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      case 'science':
        return Icons.science;
      case 'sports':
        return Icons.sports_soccer;
      case 'technology':
        return Icons.computer;
      default:
        return Icons.article;
    }
  }
}
