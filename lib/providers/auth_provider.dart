import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';
import '../services/google_signin_service.dart';

// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Check if user is authenticated
  bool get isAuthenticated => user != null;
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadUserFromStorage();
  }

  // Login user
  Future<void> login(String username, String pin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual authentication logic
      // For now, create a mock user based on credentials
      final user = User(
        id: 1,
        email: '$username@genepos.com',
        name: username,
        role: username.toLowerCase() == 'admin'
            ? UserRole.owner
            : UserRole.salesPerson,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Save user to storage
      await _saveUserToStorage(user);

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Google Sign-In
  Future<void> googleSignIn() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final googleSignInService = GoogleSignInService();
      final user = await googleSignInService.signIn();

      if (user != null) {
        // Save user to storage
        await _saveUserToStorage(user);
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Google Sign-In cancelled',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Logout user
  Future<void> logout() async {
    await _clearUserFromStorage();
    state = AuthState();
  }

  // Check if user has specific role
  bool hasRole(String role) => state.user?.role == role;

  // Check if user is admin
  bool get isAdmin => hasRole(AppConstants.roleAdmin);

  // Check if user is sales
  bool get isSales => hasRole(AppConstants.roleSales);

  // Check if user has permission
  bool hasPermission(String permission) {
    if (!state.isAuthenticated) return false;

    // Admin has all permissions
    if (isAdmin) return true;

    // Define role-based permissions
    final rolePermissions = {
      AppConstants.roleAdmin: [
        Permissions.viewProducts,
        Permissions.createProducts,
        Permissions.editProducts,
        Permissions.deleteProducts,
        Permissions.viewCategories,
        Permissions.createCategories,
        Permissions.editCategories,
        Permissions.deleteCategories,
        Permissions.viewCustomers,
        Permissions.createCustomers,
        Permissions.editCustomers,
        Permissions.deleteCustomers,
        Permissions.viewTransactions,
        Permissions.createTransactions,
        Permissions.refundTransactions,
        Permissions.viewUsers,
        Permissions.createUsers,
        Permissions.editUsers,
        Permissions.deleteUsers,
        Permissions.viewReports,
        Permissions.manageSettings,
        Permissions.backupData,
      ],
      AppConstants.roleSales: [
        Permissions.viewProducts,
        Permissions.viewCategories,
        Permissions.viewCustomers,
        Permissions.createCustomers,
        Permissions.editCustomers,
        Permissions.viewTransactions,
        Permissions.createTransactions,
      ],
    };

    final userPermissions = rolePermissions[state.user!.role] ?? [];
    return userPermissions.contains(permission);
  }

  // Load user from storage
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.userCacheKey);

      if (userJson != null) {
        // TODO: Parse user from JSON
        // For now, create a placeholder user
        final user = User(
          id: 1,
          email: 'admin@genepos.com',
          name: 'Admin User',
          role: UserRole.owner,
          isActive: true,
          createdAt: DateTime.now(),
        );

        state = state.copyWith(user: user);
      }
    } catch (e) {
      // Handle error silently
      print('Error loading user from storage: $e');
    }
  }

  // Save user to storage
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // TODO: Convert user to JSON
      await prefs.setString(AppConstants.userCacheKey, user.email);
    } catch (e) {
      print('Error saving user to storage: $e');
    }
  }

  // Clear user from storage
  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userCacheKey);
    } catch (e) {
      print('Error clearing user from storage: $e');
    }
  }
}
