import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';

class DetailScreen extends StatelessWidget {
  final Article article;

  const DetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy - HH:mm');
    String formattedDate = '';

    try {
      final date = DateTime.parse(article.publishedAt);
      formattedDate = dateFormat.format(date);
    } catch (e) {
      formattedDate = article.publishedAt;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Nút Share trên AppBar
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareArticle(context),
            tooltip: 'Share article',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh chính
            if (article.urlToImage != null)
              Image.network(
                article.urlToImage!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 80),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tác giả và thời gian
                  Row(
                    children: [
                      if (article.author != null) ...[
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            article.author!,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Mô tả
                  if (article.description != null) ...[
                    Text(
                      article.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Nội dung
                  if (article.content != null) ...[
                    Text(
                      article.content!,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Các nút action
                  Row(
                    children: [
                      // Nút đọc bài viết đầy đủ
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(article.url),
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Read Full Article'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nút share riêng lẻ
                      ElevatedButton(
                        onPressed: () => _shareArticle(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Icon(Icons.share),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm share bài viết
  Future<void> _shareArticle(BuildContext context) async {
    try {
      String shareText = '${article.title}\n\n';
      if (article.description != null) {
        shareText += '${article.description}\n\n';
      }
      shareText += 'Read more: ${article.url}';

      await Share.share(shareText, subject: article.title);

      // Thông báo sau khi share (không kiểm tra thành công/thất bại)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article shared!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
