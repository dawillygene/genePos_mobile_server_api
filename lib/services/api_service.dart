import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/sale.dart';

class ApiService {
  static const String _baseUrl =
      'https://genepos.dawillygene.com/api'; // Production Laravel API URL
  static const String _tokenKey = 'auth_token';

  late final Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired, logout user
            _clearToken();
          }
          handler.next(error);
        },
      ),
    );

    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _authToken = token;
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _authToken = null;
  }

  // Authentication endpoints
  
  // Email/Password Registration (new method)
  Future<User> register(String name, String email, String password, String passwordConfirmation, {String role = 'owner'}) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        await _saveToken(data['token']);
        return User.fromJson(data['user']);
      }
      throw Exception('Registration failed');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveToken(data['token']);
        return User.fromJson(data['user']);
      }
      throw Exception('Login failed');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> googleSignIn(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google',
        data: {'id_token': idToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveToken(data['token']);
        return User.fromJson(data['user']);
      }
      throw Exception('Google sign-in failed');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _clearToken();
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/user');
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Product endpoints
  Future<List<Product>> getProducts({
    int page = 1,
    int perPage = 20,
    String? search,
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null) 'search': search,
          if (category != null) 'category': category,
        },
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> getProduct(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await _dio.post('/products', data: product.toJson());
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _dio.put(
        '/products/${product.id}',
        data: product.toJson(),
      );
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Sales endpoints
  Future<Sale> createSale(Sale sale) async {
    try {
      final response = await _dio.post('/sales', data: sale.toJson());
      return Sale.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Sale>> getSales({
    int page = 1,
    int perPage = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/sales',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
        },
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => Sale.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Sale> getSale(String id) async {
    try {
      final response = await _dio.get('/sales/$id');
      return Sale.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Shop Management endpoints
  Future<List<dynamic>> getShops() async {
    try {
      final response = await _dio.get('/shops');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createShop({
    required String name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? timezone,
  }) async {
    try {
      final response = await _dio.post(
        '/shops',
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (address != null) 'address': address,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (timezone != null) 'timezone': timezone,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getShopStatistics(int shopId) async {
    try {
      final response = await _dio.get('/shops/$shopId/statistics');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Team Management endpoints
  Future<List<dynamic>> getTeamMembers() async {
    try {
      final response = await _dio.get('/team');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addTeamMember({
    required String name,
    required String email,
    required String password,
    String role = 'sales_person',
  }) async {
    try {
      final response = await _dio.post(
        '/team',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> toggleTeamMemberStatus(int memberId) async {
    try {
      final response = await _dio.patch('/team/$memberId/toggle-status');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Analytics endpoints
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _dio.get('/dashboard');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getSalesReport({
    DateTime? startDate,
    DateTime? endDate,
    String period = 'daily',
  }) async {
    try {
      final response = await _dio.get(
        '/reports/sales',
        queryParameters: {
          'period': period,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
        },
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'];
      }
      return 'Server error: ${error.response!.statusCode}';
    }

    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }

    if (error.type == DioExceptionType.receiveTimeout) {
      return 'Server response timeout. Please try again.';
    }

    return 'Network error. Please check your connection and try again.';
  }

  bool get isAuthenticated => _authToken != null;
}
