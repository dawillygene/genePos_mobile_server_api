import 'package:gene_pos/models/user_model.dart';
import 'package:gene_pos/database_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // Hash password using SHA-256 (similar to Laravel's Hash facade)
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register a new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final db = await DatabaseHelper().database;

      // Check if user already exists
      final existingUsers = await db.query(
        'users',
        where: 'email = ? OR username = ?',
        whereArgs: [email, username],
      );

      if (existingUsers.isNotEmpty) {
        return {
          'success': false,
          'message': 'User already exists with this email or username',
        };
      }

      // Create new user
      final user = User(
        name: name,
        email: email,
        password: _hashPassword(password),
        username: username,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Insert into database
      final userId = await db.insert('users', user.toMap());

      // Create user with ID
      _currentUser = user.copyWith(id: userId);

      return {
        'success': true,
        'message': 'User registered successfully',
        'user': _currentUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final db = await DatabaseHelper().database;

      // Find user by email or username
      final users = await db.query(
        'users',
        where: 'email = ? OR username = ?',
        whereArgs: [emailOrUsername, emailOrUsername],
      );

      if (users.isEmpty) {
        return {'success': false, 'message': 'User not found'};
      }

      final userData = users.first;
      final user = User.fromMap(userData);

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (user.password != hashedPassword) {
        return {'success': false, 'message': 'Invalid credentials'};
      }

      // Check if user is suspended
      if (user.isSuspended) {
        return {'success': false, 'message': 'Account is suspended'};
      }

      _currentUser = user;

      // Save user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);

      return {
        'success': true,
        'message': 'Login successful',
        'user': _currentUser,
      };
    } catch (e) {
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  // Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  // Check login status
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      final user = await getUserById(userId);
      if (user != null && !user.isSuspended) {
        _currentUser = user;
      }
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? username,
    String? profileImage,
  }) async {
    if (_currentUser == null) {
      return {'success': false, 'message': 'User not authenticated'};
    }

    try {
      final db = await DatabaseHelper().database;

      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        username: username ?? _currentUser!.username,
        profileImage: profileImage ?? _currentUser!.profileImage,
        updatedAt: DateTime.now(),
      );

      await db.update(
        'users',
        updatedUser.toMap(),
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      _currentUser = updatedUser;

      return {
        'success': true,
        'message': 'Profile updated successfully',
        'user': _currentUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Profile update failed: ${e.toString()}',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      return {'success': false, 'message': 'User not authenticated'};
    }

    try {
      // Verify current password
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (_currentUser!.password != hashedCurrentPassword) {
        return {'success': false, 'message': 'Current password is incorrect'};
      }

      final db = await DatabaseHelper().database;

      final updatedUser = _currentUser!.copyWith(
        password: _hashPassword(newPassword),
        updatedAt: DateTime.now(),
      );

      await db.update(
        'users',
        updatedUser.toMap(),
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      _currentUser = updatedUser;

      return {'success': true, 'message': 'Password changed successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Password change failed: ${e.toString()}',
      };
    }
  }

  // Get user by ID
  Future<User?> getUserById(int id) async {
    try {
      final db = await DatabaseHelper().database;

      final users = await db.query('users', where: 'id = ?', whereArgs: [id]);

      if (users.isEmpty) return null;

      return User.fromMap(users.first);
    } catch (e) {
      return null;
    }
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  // Validate password strength
  Map<String, dynamic> validatePassword(String password) {
    if (password.length < 8) {
      return {
        'valid': false,
        'message': 'Password must be at least 8 characters long',
      };
    }

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      return {
        'valid': false,
        'message':
            'Password must contain at least one uppercase letter, one lowercase letter, and one number',
      };
    }

    return {'valid': true, 'message': 'Password is strong'};
  }
}
