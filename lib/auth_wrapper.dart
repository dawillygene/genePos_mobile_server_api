import 'package:flutter/material.dart';
import 'services/google_signin_service.dart';
import 'models/user.dart';
import 'pages/login_page.dart';
import 'pages/pos_main_page.dart';
import 'pages/splash_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  bool _isInitialized = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Check if user is already signed in
      final bool isSignedIn = await _googleSignInService.isSignedIn();

      if (isSignedIn) {
        // Try to get current user
        final User? user = await _googleSignInService.getCurrentUser();
        if (user != null) {
          setState(() {
            _currentUser = user;
            _isInitialized = true;
          });
          return;
        }
      }

      // Try silent sign-in
      final User? user = await _googleSignInService.silentSignIn();
      setState(() {
        _currentUser = user;
        _isInitialized = true;
      });
    } catch (e) {
      // Silent sign-in failed, user needs to sign in manually
      setState(() {
        _currentUser = null;
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

    if (_currentUser != null) {
      return POSMainPage(user: _currentUser!);
    }

    return const LoginPage();
  }
}
