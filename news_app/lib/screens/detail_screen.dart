import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../l10n/app_localizations.dart';

import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../providers/offline_provider.dart';
import '../providers/news_provider.dart';

class DetailScreen extends StatefulWidget {
  final Article article;

  const DetailScreen({super.key, required this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Article _article;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMMM dd, yyyy - HH:mm');
    String formattedDate = '';

    try {
      final date = DateTime.parse(_article.publishedAt);
      formattedDate = dateFormat.format(date);
    } catch (e) {
      formattedDate = _article.publishedAt;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.articleDetails),
        actions: [
          // Bookmark button
          Consumer<BookmarkProvider>(
            builder: (context, bookmarkProvider, child) {
              final isBookmarked = bookmarkProvider.isBookmarked(_article.url);

              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.orange : null,
                ),
                onPressed: () async {
                  final added = await bookmarkProvider.toggleBookmark(_article);

                  setState(() {
                    _article = _article.copyWith(isBookmarked: added);
                  });

                  // Update in NewsProvider
                  context.read<NewsProvider>().updateArticleBookmarkStatus(
                    _article.url,
                    added,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          added ? l10n.bookmarkAdded : l10n.bookmarkRemoved,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
              );
            },
          ),

          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareArticle(context, l10n),
            tooltip: l10n.share,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (_article.urlToImage != null)
              Image.network(
                _article.urlToImage!,
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
                  // Title
                  Text(
                    _article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Author and time
                  if (_article.author != null)
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _article.author!,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
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

                  // Description
                  if (_article.description != null) ...[
                    Text(
                      _article.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Content
                  if (_article.content != null) ...[
                    Text(
                      _article.content!,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      // Read full article
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(_article.url),
                          icon: const Icon(Icons.open_in_browser),
                          label: Text(l10n.readFullArticle),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Offline button
                      Consumer<OfflineProvider>(
                        builder: (context, offlineProvider, child) {
                          final isOffline = offlineProvider.isOffline(
                            _article.url,
                          );

                          return ElevatedButton(
                            onPressed: () async {
                              final added = await offlineProvider.toggleOffline(
                                _article,
                                'general', // Default category
                              );
                              setState(() {
                                _article = _article.copyWith(isOffline: added);
                              });

                              // Update in NewsProvider
                              context
                                  .read<NewsProvider>()
                                  .updateArticleOfflineStatus(
                                    _article.url,
                                    added,
                                  );

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      added
                                          ? l10n.offlineAdded
                                          : l10n.offlineRemoved,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              backgroundColor: isOffline ? Colors.green : null,
                              foregroundColor: isOffline ? Colors.white : null,
                            ),
                            child: Icon(
                              isOffline
                                  ? Icons.offline_pin
                                  : Icons.offline_pin_outlined,
                            ),
                          );
                        },
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

  Future<void> _shareArticle(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    try {
      String shareText = '${_article.title}\n\n';
      if (_article.description != null) {
        shareText += '${_article.description}\n\n';
      }

      shareText += 'Read more: ${_article.url}';

      await Share.share(shareText, subject: _article.title);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article shared successfully!'),
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
