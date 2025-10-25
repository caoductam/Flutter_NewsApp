# Flutter News App

A feature-rich news application built with Flutter that delivers real-time news updates, personalized content, and a seamless reading experience across multiple platforms.

## 📱 Features

- **News Feed**
  - Real-time news updates
  - Categorized news sections (Business, Technology, Sports, etc.)
  - Pull-to-refresh functionality
  - Infinite scroll for seamless browsing

- **Search & Filter**
  - Advanced search with autocomplete
  - Filter by date, category, and source
  - Sort by relevance, date, or popularity
  - Search history tracking

- **Personalization**
  - Bookmark articles for offline reading
  - Customize news feed preferences
  - Dark/Light theme support
  - Font size adjustment

- **Multi-language Support**
  - English (Default)
  - Vietnamese
  - Easy to add more languages

- **Sharing & Interaction**
  - Share articles via social media
  - Copy article link
  - Open in browser option
  - Reading time estimation

## 🚀 Getting Started

### System Requirements

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- IDE: Android Studio / VS Code
- Git
- News API Key (Sign up at [newsapi.org](https://newsapi.org))

### Development Setup

1. **Install Flutter**
   ```bash
   # Check Flutter installation
   flutter doctor -v
   ```

2. **Clone Repository**
   ```bash
   git clone https://github.com/caoductam/Flutter_NewsApp.git
   cd Flutter_NewsApp
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Configure API Key**
   - Create a `.env` file in the project root
   ```env
   NEWS_API_KEY=your_api_key_here
   ```

5. **Run the App**
   ```bash
   # Debug mode
   flutter run

   # Release mode
   flutter run --release
   ```

## 📱 App Screenshots

[Place your screenshots here]

Example screenshot locations:
- Home Screen
- Article Details
- Search Interface
- Bookmarks
- Settings

## 📂 Project Structure

```
lib/
├── config/                 # App configuration files
│   ├── theme/             # App theming
│   └── routes/            # Route definitions
│
├── core/                  # Core functionality
│   ├── api/               # API handling
│   ├── utils/             # Utility functions
│   └── constants/         # App constants
│
├── features/              # Feature modules
│   ├── news/             # News feature
│   ├── bookmarks/        # Bookmarks feature
│   └── settings/         # Settings feature
│
├── l10n/                 # Localization files
│   ├── app_en.arb       # English translations
│   └── app_vi.arb       # Vietnamese translations
│
├── models/               # Data models
├── providers/           # State management
├── screens/             # UI screens
└── services/            # Business logic & API services
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  provider: ^6.0.0
  
  # Network & API
  http: ^1.1.0
  dio: ^5.0.0
  
  # Local Storage
  shared_preferences: ^2.2.0
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  
  # UI Components
  cached_network_image: ^3.3.0
  flutter_html: ^3.0.0
  shimmer: ^3.0.0
  
  # Utilities
  url_launcher: ^6.2.0
  share_plus: ^7.1.0
  intl: ^0.18.0
```

## 🔧 Configuration

### API Setup
1. Get your API key from [newsapi.org](https://newsapi.org)
2. Configure the API key in `lib/core/constants/api_constants.dart`:
   ```dart
   class ApiConstants {
     static const String apiKey = 'YOUR_API_KEY';
     static const String baseUrl = 'https://newsapi.org/v2';
   }
   ```

### Environment Variables
Create a `.env` file with the following:
```env
NEWS_API_KEY=your_api_key_here
API_BASE_URL=https://newsapi.org/v2
```

## 💡 Usage Guide

### Reading News
1. Launch the app
2. Browse through different categories
3. Tap on any article to read full content
4. Use pull-to-refresh to update content

### Search Function
1. Tap the search icon
2. Enter keywords
3. Use filters for refined results
4. View search history

### Bookmarks
1. Tap the bookmark icon on any article
2. Access bookmarks from the bottom navigation
3. Remove bookmarks by swiping or tapping the bookmark icon again

### Customization
1. Access settings from the menu
2. Adjust theme (light/dark)
3. Change language
4. Modify text size
5. Configure notifications

## ⚠️ Troubleshooting

### Common Issues

1. **API Key Issues**
   - Verify API key in `.env` file
   - Check API request limits
   - Ensure proper internet connection

2. **Build Errors**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Performance Issues**
   - Clear app cache
   - Update Flutter SDK
   - Check for memory leaks

4. **Image Loading**
   - Verify internet connection
   - Check image URL validity
   - Clear image cache

### Debug Mode
```bash
# Run with verbose logging
flutter run -v
```

## 📞 Contact Information

For support or queries:

- **Developer**: Cao Duc Tam
- **Email**: [ductam2024@gmail.com]
- **GitHub**: [@caoductam](https://github.com/caoductam)

## Updates and Versions

- **Current Version**: 1.0.0
- **Last Updated**: October 25, 2025
- **Flutter Version**: 3.x.x
- **Dart Version**: 3.x.x