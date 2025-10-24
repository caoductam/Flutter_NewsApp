import 'package:flutter/material.dart';

enum SortOption { newest, oldest, titleAZ, titleZA }

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.newest:
        return 'Mới nhất';
      case SortOption.oldest:
        return 'Cũ nhất';
      case SortOption.titleAZ:
        return 'Tiêu đề A-Z';
      case SortOption.titleZA:
        return 'Tiêu đề Z-A';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.newest:
        return Icons.arrow_downward;
      case SortOption.oldest:
        return Icons.arrow_upward;
      case SortOption.titleAZ:
        return Icons.sort_by_alpha;
      case SortOption.titleZA:
        return Icons.sort_by_alpha;
    }
  }

  String get description {
    switch (this) {
      case SortOption.newest:
        return 'Hiển thị tin mới nhất trước';
      case SortOption.oldest:
        return 'Hiển thị tin cũ nhất trước';
      case SortOption.titleAZ:
        return 'Sắp xếp tiêu đề từ A đến Z';
      case SortOption.titleZA:
        return 'Sắp xếp tiêu đề từ Z đến A';
    }
  }
}
