/// Core constants for the POS system
class AppConstants {
  // App Information
  static const String appName = 'Gene POS';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Complete Point of Sale System';

  // Database
  static const String databaseName = 'gene_pos.db';
  static const int databaseVersion = 1;

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleSales = 'sales';
  static const String roleManager = 'manager';

  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentMobile = 'mobile';
  static const String paymentBankTransfer = 'bank_transfer';

  // Transaction Types
  static const String transactionSale = 'sale';
  static const String transactionRefund = 'refund';
  static const String transactionCredit = 'credit';

  // Default Values
  static const double defaultTaxRate = 0.0;
  static const int defaultCreditLimit = 0;
  static const int lowStockThreshold = 10;

  // UI Constants
  static const double borderRadius = 8.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double iconSize = 24.0;

  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 500);

  // File Paths
  static const String receiptsPath = 'receipts';
  static const String productsPath = 'products';
  static const String backupsPath = 'backups';

  // API Endpoints (for future cloud sync)
  static const String baseUrl = 'https://api.genepos.com';
  static const String loginEndpoint = '/auth/login';
  static const String syncEndpoint = '/sync';

  // Cache Keys
  static const String userCacheKey = 'current_user';
  static const String settingsCacheKey = 'app_settings';
  static const String lastSyncCacheKey = 'last_sync';

  // Error Messages
  static const String networkError = 'Network connection failed';
  static const String databaseError = 'Database operation failed';
  static const String authenticationError = 'Authentication failed';
  static const String permissionError = 'Insufficient permissions';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String saveSuccess = 'Data saved successfully';
  static const String deleteSuccess = 'Item deleted successfully';

  // Validation Messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String invalidAmount = 'Please enter a valid amount';
}

/// App Colors
class AppColors {
  static const int primaryColor = 0xFF1976D2;
  static const int secondaryColor = 0xFFDC004E;
  static const int accentColor = 0xFFFF9800;
  static const int backgroundColor = 0xFFFFFFFF;
  static const int surfaceColor = 0xFFF5F5F5;
  static const int errorColor = 0xFFD32F2F;
  static const int successColor = 0xFF388E3C;
  static const int warningColor = 0xFFF57C00;
  static const int textPrimaryColor = 0xFF212121;
  static const int textSecondaryColor = 0xFF757575;
}

/// App Themes
class AppThemes {
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';
  static const String systemTheme = 'system';
}

/// Screen Routes
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String categories = '/categories';
  static const String customers = '/customers';
  static const String transactions = '/transactions';
  static const String pos = '/pos';
  static const String settings = '/settings';
  static const String profile = '/profile';
}

/// Permission Levels
class Permissions {
  // Product permissions
  static const String viewProducts = 'view_products';
  static const String createProducts = 'create_products';
  static const String editProducts = 'edit_products';
  static const String deleteProducts = 'delete_products';

  // Category permissions
  static const String viewCategories = 'view_categories';
  static const String createCategories = 'create_categories';
  static const String editCategories = 'edit_categories';
  static const String deleteCategories = 'delete_categories';

  // Customer permissions
  static const String viewCustomers = 'view_customers';
  static const String createCustomers = 'create_customers';
  static const String editCustomers = 'edit_customers';
  static const String deleteCustomers = 'delete_customers';

  // Transaction permissions
  static const String viewTransactions = 'view_transactions';
  static const String createTransactions = 'create_transactions';
  static const String refundTransactions = 'refund_transactions';

  // User permissions
  static const String viewUsers = 'view_users';
  static const String createUsers = 'create_users';
  static const String editUsers = 'edit_users';
  static const String deleteUsers = 'delete_users';

  // System permissions
  static const String viewReports = 'view_reports';
  static const String manageSettings = 'manage_settings';
  static const String backupData = 'backup_data';
}

/// Date Formats
class DateFormats {
  static const String displayDate = 'MMM dd, yyyy';
  static const String displayTime = 'HH:mm';
  static const String displayDateTime = 'MMM dd, yyyy HH:mm';
  static const String isoDate = 'yyyy-MM-dd';
  static const String isoDateTime = 'yyyy-MM-dd HH:mm:ss';
  static const String receiptDate = 'yyyy-MM-dd HH:mm:ss';
}

/// Number Formats
class NumberFormats {
  static const String currency = '#,##0.00';
  static const String quantity = '#,##0';
  static const String percentage = '#,##0.00';
}

/// File Extensions
class FileExtensions {
  static const String imageJpg = '.jpg';
  static const String imagePng = '.png';
  static const String imageWebp = '.webp';
  static const String pdf = '.pdf';
  static const String csv = '.csv';
  static const String json = '.json';
}

/// Validation Rules
class ValidationRules {
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxPhoneLength = 15;
  static const int maxEmailLength = 100;
  static const double maxAmount = 999999.99;
  static const int maxQuantity = 99999;
}
