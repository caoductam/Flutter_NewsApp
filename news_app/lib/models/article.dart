class Article {
  final int? id; // Thêm id cho database
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String? content;
  final bool isBookmarked; // Thêm bookmark status
  final bool isOffline; // Thêm offline status

  Article({
    this.id,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
    this.isBookmarked = false,
    this.isOffline = false,
  });

  // Chuyển từ JSON sang Object
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      author: json['author'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'],
      isBookmarked: json['isBookmarked'] == 1 || json['isBookmarked'] == true,
      isOffline: json['isOffline'] == 1 || json['isOffline'] == true,
    );
  }

  // Chuyển từ Object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      'isBookmarked': isBookmarked ? 1 : 0,
      'isOffline': isOffline ? 1 : 0,
    };
  }

  // Copy with method để update article
  Article copyWith({
    int? id,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
    bool? isBookmarked,
    bool? isOffline,
  }) {
    return Article(
      id: id ?? this.id,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
