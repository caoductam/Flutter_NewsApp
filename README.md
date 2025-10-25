# Flutter News App

Ứng dụng tin tức giàu tính năng được xây dựng bằng Flutter, cung cấp tin tức cập nhật theo thời gian thực, nội dung được cá nhân hóa và trải nghiệm đọc liền mạch trên nhiều nền tảng.

## 📱 Tính năng

- **Bảng tin**
- Cập nhật tin tức theo thời gian thực
- Phân loại tin tức (Kinh doanh, Công nghệ, Thể thao, v.v.)
- Chức năng kéo để làm mới
- Cuộn vô hạn cho trải nghiệm duyệt web liền mạch

- **Tìm kiếm & Lọc**
- Tìm kiếm nâng cao với tính năng tự động hoàn thành
- Lọc theo ngày, danh mục và nguồn
- Sắp xếp theo mức độ liên quan, ngày hoặc mức độ phổ biến
- Theo dõi lịch sử tìm kiếm

- **Cá nhân hóa**
- Đánh dấu bài viết để đọc ngoại tuyến
- Tùy chỉnh tùy chọn bảng tin
- Hỗ trợ giao diện Tối/Sáng
- Điều chỉnh cỡ chữ

- **Hỗ trợ đa ngôn ngữ**
- Tiếng Anh (Mặc định)
- Tiếng Việt
- Dễ dàng thêm ngôn ngữ

- **Chia sẻ & Tương tác**
- Chia sẻ bài viết qua mạng xã hội
- Sao chép liên kết bài viết
- Tùy chọn mở trong trình duyệt
- Ước tính thời gian đọc

## 🚀 Bắt đầu

### Yêu cầu hệ thống

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- IDE: Android Studio / VS Code
- Git
- News API Key (Sign up at [newsapi.org](https://newsapi.org))

### Thiết lập phát triển

1. **Cài đặt Flutter**
   ```bash
   # Check Flutter installation
   flutter doctor -v
   ```

2. **Clone Repository**
   ```bash
   git clone https://github.com/caoductam/Flutter_NewsApp.git
   cd Flutter_NewsApp
   ```

3. **Cài đặt các phụ thuộc**
   ```bash
   flutter pub get
   ```

4. **Cấu hình Khóa API**
   - Create a `.env` file in the project root
   ```env
   NEWS_API_KEY=your_api_key_here
   ```

5. **Chạy ứng dụng**
   ```bash
   # Debug mode
   flutter run

   # Release mode
   flutter run --release
   ```

## 📂 Cấu trúc dự án
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

## 📦 Các phụ thuộc

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

## 🔧 Cấu hình

### Thiết lập API
1. Lấy khóa API của bạn từ [newsapi.org](https://newsapi.org)
2. Cấu hình khóa API trong `lib/core/constants/api_constants.dart`:
```dart
class ApiConstants {
static const String apiKey = 'YOUR_API_KEY';
static const String baseUrl = 'https://newsapi.org/v2';
}
```
### Biến môi trường
Tạo tệp `.env` với nội dung sau:
```env
NEWS_API_KEY=your_api_key_here
API_BASE_URL=https://newsapi.org/v2
```
## 💡 Hướng dẫn sử dụng

### Đọc tin tức
1. Khởi chạy ứng dụng
2. Duyệt qua các danh mục khác nhau
3. Chạm vào bất kỳ bài viết nào để đọc toàn bộ nội dung
4. Sử dụng tính năng kéo để làm mới để cập nhật nội dung

### Chức năng tìm kiếm
1. Chạm vào biểu tượng tìm kiếm
2. Nhập từ khóa
3. Sử dụng bộ lọc để lọc kết quả
4. Xem lịch sử tìm kiếm

### Dấu trang
1. Chạm vào biểu tượng dấu trang trên bất kỳ bài viết nào
2. Truy cập dấu trang từ thanh điều hướng phía dưới
3. Xóa dấu trang bằng cách vuốt hoặc chạm lại vào biểu tượng dấu trang

### Tùy chỉnh
1. Truy cập cài đặt từ menu
2. Điều chỉnh giao diện (sáng/tối)
3. Thay đổi ngôn ngữ
4. Chỉnh sửa cỡ chữ
5. Cấu hình thông báo

## ⚠️ Khắc phục sự cố

### Các vấn đề thường gặp

1. **Các vấn đề về khóa API**
- Xác minh khóa API trong tệp `.env`
- Kiểm tra giới hạn yêu cầu API
- Đảm bảo kết nối internet phù hợp

2. **Lỗi biên dịch**
```bash
# Dọn dẹp và biên dịch lại
flutter clean
flutter pub get
flutter run
```

3. **Các vấn đề về hiệu suất**
- Xóa bộ nhớ đệm ứng dụng
- Cập nhật Flutter SDK
- Kiểm tra rò rỉ bộ nhớ

4. **Đang tải hình ảnh**
- Xác minh kết nối internet
- Kiểm tra tính hợp lệ của URL hình ảnh
- Xóa bộ nhớ đệm hình ảnh

### Chế độ gỡ lỗi
```bash
# Chạy với chế độ ghi nhật ký chi tiết
flutter run -v
```

## 📞 Thông tin liên hệ

Để được hỗ trợ hoặc giải đáp thắc mắc:

- **Nhà phát triển**: Cao Đức Tâm
- **Email**: [ductam2024@gmail.com]
- **GitHub**: [@caoductam](https://github.com/caoductam)

## Bản cập nhật và phiên bản

- **Phiên bản hiện tại**: 1.0.0
- **Cập nhật lần cuối**: 25 tháng 10, 2025
- **Phiên bản Flutter**: 3.x.x
- **Phiên bản Dart**: 3.x.x
