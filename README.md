b# GenePos - Point of Sale System

A comprehensive Point of Sale (POS) system built with Flutter for the frontend, Laravel for the backend API, MySQL for the database, and Google Sign-In for authentication.

## 🚀 Features

### Frontend (Flutter)
- **Google Sign-In Authentication** - Secure login with persistent sessions
- **Product Management** - Browse, search, and filter products by category
- **Cart Management** - Add/remove items, adjust quantities, apply discounts
- **Sales Processing** - Complete transactions with multiple payment methods
- **Sales History** - View past transactions with detailed information
- **Dashboard Analytics** - Real-time sales data and charts
- **Responsive Design** - Works on tablets and mobile devices
- **Offline Capability** - Local storage for cart persistence

### Backend (Laravel)
- **RESTful API** - Clean and well-documented API endpoints
- **Google OAuth Integration** - Secure authentication with Google
- **Database Management** - MySQL with proper relationships
- **Role-based Access** - Admin, Manager, and Cashier roles
- **Sales Reporting** - Detailed analytics and reporting
- **Inventory Management** - Stock tracking and low-stock alerts

### Core Functionality
- **Multi-Payment Support** - Cash, Card, Mobile payments
- **Tax Calculations** - Configurable tax rates
- **Discount System** - Item-level and order-level discounts
- **Receipt Generation** - Printable receipts (PDF)
- **Real-time Updates** - Live inventory and sales data
- **User Management** - Role-based access control

## 🛠️ Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider/Riverpod** - State management
- **Google Sign-In** - Authentication
- **FL Chart** - Data visualization
- **Dio** - HTTP client for API calls

### Backend
- **Laravel** - PHP web framework
- **MySQL** - Relational database
- **Laravel Sanctum** - API authentication
- **Google API Client** - Google OAuth verification

### Development Tools
- **VS Code** - Recommended IDE
- **Android Studio** - For Android development
- **Xcode** - For iOS development (macOS only)
- **Postman/Insomnia** - API testing

## 📋 Prerequisites

### Flutter Development
- Flutter SDK 3.8.0 or higher
- Dart SDK 3.8.0 or higher
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- VS Code with Flutter extension

### Laravel Development
- PHP 8.1 or higher
- Composer
- MySQL 8.0 or higher
- Node.js and npm

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/genepos.git
cd genepos
```

### 2. Flutter Setup

```bash
# Install dependencies
flutter pub get

# Generate model files
dart run build_runner build

# Run the app
flutter run
```

### 3. Laravel Backend Setup

Follow the detailed setup guide in [LARAVEL_SETUP.md](LARAVEL_SETUP.md)

### 4. Google Sign-In Configuration

1. **Create a Google Cloud Project**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one
   - Enable Google Sign-In API

2. **Configure OAuth 2.0**
   - Go to Credentials → Create Credentials → OAuth 2.0 Client IDs
   - Configure for Android, iOS, and Web applications
   - Download the configuration files

3. **Flutter Configuration**
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Update `android/app/build.gradle` with your package name

4. **Laravel Configuration**
   - Add Google client ID and secret to `.env` file
   - Configure in `config/services.php`

## 📱 App Structure

```
lib/
├── models/           # Data models (Product, Sale, User, etc.)
├── services/         # API services and business logic
├── pages/           # UI screens and pages
├── widgets/         # Reusable UI components
├── providers/       # State management
└── utils/           # Helper functions and constants
```

## 🎯 Key Features Walkthrough

### 1. Authentication Flow
- Users sign in with their Google account
- JWT tokens manage session persistence
- Automatic token refresh for seamless experience

### 2. Product Management
- Grid view with search and category filters
- Real-time stock quantity display
- Add to cart with quantity controls

### 3. Cart Operations
- Dynamic quantity adjustments
- Item-level and order-level discounts
- Tax calculations with configurable rates
- Multiple payment method support

### 4. Sales Processing
- Complete checkout flow
- Customer information capture
- Receipt generation and printing
- Inventory automatic updates

### 5. Analytics Dashboard
- Daily, weekly, monthly sales charts
- Top-selling products analysis
- Payment method breakdowns
- Real-time performance metrics

## 🔧 Configuration

### API Endpoint Configuration
Update the base URL in `lib/services/api_service.dart`:
```dart
static const String _baseUrl = 'http://localhost:8000/api'; // Development
// static const String _baseUrl = 'https://your-api.com/api'; // Production
```

### Tax Rate Configuration
Adjust tax rates in `lib/services/cart_service.dart`:
```dart
double _taxRate = 0.10; // 10% tax rate
```

### Theme Customization
Modify colors and themes in `lib/colors.dart`:
```dart
class AppColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  // Add your custom colors here
}
```

## 📊 Database Schema

### Core Tables
- **users** - User authentication and roles
- **products** - Product catalog with inventory
- **sales** - Transaction records
- **sale_items** - Individual items in transactions

### Relationships
- User → Sales (One-to-Many)
- Sale → SaleItems (One-to-Many)
- Product → SaleItems (One-to-Many)

## 🔒 Security Features

- **Secure Authentication** - Google OAuth with JWT tokens
- **API Rate Limiting** - Prevent abuse and ensure stability
- **Role-based Access** - Different permissions for different user roles
- **Input Validation** - Comprehensive validation on all inputs
- **HTTPS Enforcement** - Secure data transmission

## 🧪 Testing

### Flutter Tests
```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Laravel Tests
```bash
# Run PHP unit tests
php artisan test

# Run specific test
php artisan test --filter=AuthTest
```

## 📱 Platform Support

- ✅ **Android** - Full support with Google Play Services
- ✅ **iOS** - Full support with native integrations
- ✅ **Web** - Basic support for administration
- ⚠️ **Desktop** - Limited support

## 🚀 Deployment

### Flutter App Deployment
- **Android**: Build APK or AAB for Google Play Store
- **iOS**: Build IPA for App Store
- **Web**: Deploy to Firebase Hosting or any web server

### Laravel API Deployment
- **Shared Hosting**: Use cPanel with composer support
- **VPS/Cloud**: Deploy on DigitalOcean, AWS, or Google Cloud
- **Docker**: Use the provided Dockerfile for containerization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/your-username/genepos/issues) page
2. Create a new issue with detailed description
3. Contact support at support@genepos.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Laravel team for the robust backend framework
- Google for authentication services
- Open source community for various packages used

---

**Built with ❤️ by the GenePos Team** Flutter project.

# Gene POS - Point of Sale Application

A comprehensive Point of Sale (POS) application built with Flutter frontend, Laravel backend, and MySQL database. Features Google Sign-In authentication and persistent user sessions.

## 🚀 Features

- **Authentication**: Google Sign-In with persistent sessions
- **Product Management**: Browse, search, and filter products with categories
- **Cart Operations**: Add/remove items, quantity management, real-time total calculation
- **Sales Processing**: Complete checkout flow with receipt generation
- **Dashboard Analytics**: Sales overview with interactive charts using FL Chart
- **Inventory Management**: Product stock tracking and management
- **Multi-platform Support**: Android, iOS, Web, Windows, macOS, Linux

## 🛠 Technology Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.8+
- **Language**: Dart
- **State Management**: Provider pattern
- **UI Components**: Material Design 3
- **HTTP Client**: Dio with interceptors
- **Charts**: FL Chart for analytics
- **Authentication**: Google Sign-In
- **Storage**: Hive for local data persistence

### Backend (Laravel) - To be implemented
- **Framework**: Laravel 11
- **Database**: MySQL
- **Authentication**: Laravel Sanctum + Google OAuth
- **API**: RESTful endpoints

## 📱 Flutter App Structure

```
lib/
├── main.dart                    # App entry point with theme configuration
├── colors.dart                  # Material Design 3 color scheme
├── auth_wrapper.dart            # Authentication state management
├── models/                      # Data models with JSON serialization
│   ├── user.dart               # User model
│   ├── product.dart            # Product model with category enum
│   ├── cart_item.dart          # Cart item with quantity management
│   └── sale.dart               # Sales transaction model
├── services/                    # Business logic and API communication
│   ├── api_service.dart        # HTTP client with token management
│   ├── google_signin_service.dart  # Google authentication
│   └── cart_service.dart       # Cart state management
└── pages/                       # UI screens
    ├── splash_screen.dart      # Loading screen
    ├── login_page.dart         # Google Sign-In interface
    ├── pos_main_page.dart      # Main POS interface with navigation
    ├── product_grid_page.dart  # Product browsing with search/filter
    ├── cart_page.dart          # Shopping cart and checkout
    ├── sales_history_page.dart # Transaction history
    └── dashboard_page.dart     # Analytics dashboard with charts
```

## 🔧 Setup Instructions

### 1. Flutter Development Environment

```bash
# Verify Flutter installation
flutter doctor

# Install dependencies
flutter pub get

# Run the app (choose your platform)
flutter run                    # Default platform
flutter run -d chrome         # Web
flutter run -d android        # Android
flutter run -d ios           # iOS (macOS only)
```

### 2. Google Sign-In Configuration

#### Android Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Google+ API and Google Sign-In API
4. Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client IDs"
5. Select "Android" application type
6. Get SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
7. Add SHA-1 fingerprint and package name (`com.example.genepos`)
8. Download `google-services.json` and place in `android/app/`

#### iOS Setup (macOS only)
1. In Google Cloud Console, create iOS OAuth client
2. Add iOS bundle ID (`com.example.genepos`)
3. Download `GoogleService-Info.plist` and add to `ios/Runner/`
4. Update `ios/Runner/Info.plist` with URL scheme

#### Web Setup
1. Create Web OAuth client in Google Cloud Console
2. Add authorized origins (e.g., `http://localhost:3000`)
3. Update `web/index.html` with client ID

### 3. Laravel Backend Setup

Follow the detailed guide in `LARAVEL_SETUP.md` to:
- Install Laravel with MySQL
- Set up Google OAuth verification
- Create RESTful API endpoints
- Configure CORS for Flutter app
- Set up authentication with Laravel Sanctum

### 4. Database Configuration

The app expects these API endpoints from your Laravel backend:

```
POST   /api/auth/google         # Google token verification
GET    /api/user               # Get authenticated user
POST   /api/logout             # Logout user
GET    /api/products           # Get all products
POST   /api/products           # Create product
PUT    /api/products/{id}      # Update product
DELETE /api/products/{id}      # Delete product
GET    /api/sales              # Get sales history
POST   /api/sales              # Create new sale
GET    /api/dashboard/stats    # Get dashboard statistics
```

## 📦 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # State management
  dio: ^5.4.0                   # HTTP client
  google_sign_in: ^6.1.6       # Google authentication
  shared_preferences: ^2.2.2    # Persistent storage
  fl_chart: ^0.66.0             # Charts and graphs
  mobile_scanner: ^3.5.7       # Barcode scanning
  printing: ^5.11.1            # Receipt printing
  intl: ^0.19.0                # Date formatting
  equatable: ^2.0.5            # Value equality
  json_annotation: ^4.8.1       # JSON serialization
```

## 🎨 UI Features

### Material Design 3
- Dynamic color theming
- Consistent spacing and typography
- Responsive layouts for all screen sizes
- Dark/light theme support

### Navigation
- Bottom navigation rail on main POS screen
- Intuitive tab-based navigation
- Back button handling
- Deep linking support

### Components
- Product cards with images and stock status
- Interactive shopping cart with quantity controls
- Real-time total calculations
- Chart visualizations for analytics
- Responsive search and filter interface

## 🔒 Authentication Flow

1. **Splash Screen**: Check existing authentication
2. **Login**: Google Sign-In with OAuth 2.0
3. **Token Management**: Automatic refresh and storage
4. **Persistent Sessions**: Users stay logged in
5. **Secure API Calls**: Token-based authentication

## 📊 Sample Data

The app includes sample data for testing:
- 20+ sample products across different categories
- Mock sales transactions
- Dashboard statistics
- Cart functionality with sample items

## 🚧 Development Status

### ✅ Completed
- Flutter app architecture
- Google Sign-In integration
- Complete POS user interface
- Cart management system
- Dashboard with analytics
- Product browsing and search
- Sample data for testing

### 🔄 In Progress
- Laravel backend implementation
- MySQL database setup
- API integration testing

### 📋 TODO
- Receipt printing functionality
- Barcode scanning integration
- Inventory management features
- Multi-user support
- Offline mode capability
- Payment gateway integration

## 🛠 Build and Deployment

### Debug Build
```bash
flutter build apk --debug
flutter build web --debug
```

### Release Build
```bash
flutter build apk --release
flutter build web --release
flutter build ios --release  # macOS only
```

### Testing
```bash
flutter test
flutter analyze
```

## 📝 Configuration Files

- `pubspec.yaml`: Dependencies and assets
- `analysis_options.yaml`: Linting rules
- `android/app/build.gradle`: Android configuration
- `ios/Runner/Info.plist`: iOS configuration
- `web/index.html`: Web configuration

## 🔧 Troubleshooting

### Common Issues
1. **Google Sign-In not working**: Verify SHA-1 fingerprint and package name
2. **Build errors**: Run `flutter clean && flutter pub get`
3. **API connection issues**: Check CORS configuration in Laravel backend
4. **Missing dependencies**: Run `flutter pub deps` to verify

### Debug Commands
```bash
flutter doctor -v           # Detailed environment info
flutter analyze            # Code analysis
flutter test               # Run tests
adb logcat                 # Android logs
```

## 📚 Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)
- [Provider State Management](https://pub.dev/packages/provider)
- [FL Chart Documentation](https://pub.dev/packages/fl_chart)
- [Laravel Documentation](https://laravel.com/docs)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Support

For support and questions:
- Create an issue in the repository
- Check existing documentation
- Review the Laravel setup guide in `LARAVEL_SETUP.md`

---

**Next Steps**: Follow the `LARAVEL_SETUP.md` guide to complete your backend setup and start using your POS application!
