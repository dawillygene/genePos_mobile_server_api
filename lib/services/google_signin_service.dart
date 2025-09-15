import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class GoogleSignInService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userDataKey = 'user_data';

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  final ApiService _apiService = ApiService();

  GoogleSignInService();

  Future<User?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return null; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication authentication =
          await account.authentication;
      final String? idToken = authentication.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      // Send the ID token to your Laravel backend
      final User user = await _apiService.googleSignIn(idToken);

      // Save login state locally
      await _saveLoginState(true, user);

      return user;
    } catch (error) {
      print('Google Sign-In Error: $error');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _apiService.logout();
      await _clearLoginState();
    } catch (error) {
      print('Sign-Out Error: $error');
      // Clear local state even if remote logout fails
      await _clearLoginState();
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final bool isLoggedIn = await _getLoginState();
      if (!isLoggedIn) {
        return null;
      }

      // Try to get current user from API
      final User user = await _apiService.getCurrentUser();

      // Update local user data
      await _saveUserData(user);

      return user;
    } catch (error) {
      print('Get Current User Error: $error');
      // If API call fails, try to get user from local storage
      return await _getUserDataFromLocal();
    }
  }

  Future<bool> isSignedIn() async {
    try {
      final bool localState = await _getLoginState();
      final bool googleState = await _googleSignIn.isSignedIn();
      final bool apiState = _apiService.isAuthenticated;

      return localState && googleState && apiState;
    } catch (error) {
      return false;
    }
  }

  Future<void> _saveLoginState(bool isLoggedIn, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
    await _saveUserData(user);
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, user.toJson().toString());
  }

  Future<bool> _getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<User?> _getUserDataFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString(_userDataKey);
      if (userData != null) {
        // Note: You might want to use proper JSON parsing here
        // For now, this is a simplified version
        return null; // Return parsed user data
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  Future<void> _clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userDataKey);
  }

  // Check if user needs to re-authenticate
  Future<bool> needsReAuthentication() async {
    try {
      final User? user = await getCurrentUser();
      return user == null;
    } catch (error) {
      return true;
    }
  }

  // Silent sign-in (if user previously signed in)
  Future<User?> silentSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account == null) {
        return null;
      }

      final GoogleSignInAuthentication authentication =
          await account.authentication;
      final String? idToken = authentication.idToken;

      if (idToken == null) {
        return null;
      }

      final User user = await _apiService.googleSignIn(idToken);
      await _saveLoginState(true, user);

      return user;
    } catch (error) {
      print('Silent Sign-In Error: $error');
      return null;
    }
  }
}
