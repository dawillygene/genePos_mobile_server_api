import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gene_pos/constants.dart';
import 'package:gene_pos/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _formController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _formSlideAnimation;
  late Animation<double> _formOpacityAnimation;
  late Animation<double> _backgroundAnimation;

  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    // Form animation controller
    _formController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    // Background animation controller
    _backgroundController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..repeat();

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // Form animations
    _formSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );

    _formOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Background animation
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    // Start animations
    _logoController.forward().then((_) {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _backgroundController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kGradientStart,
                  kGradientMiddle,
                  kGradientEnd,
                  kAccentColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  0.0,
                  0.3 + 0.2 * math.sin(_backgroundAnimation.value),
                  0.7 + 0.2 * math.cos(_backgroundAnimation.value),
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background particles
                ...List.generate(10, (index) {
                  return Positioned(
                    left:
                        (screenSize.width * (index / 10) +
                            50 * math.sin(_backgroundAnimation.value + index)) %
                        screenSize.width,
                    top:
                        (screenSize.height * (index / 10) +
                            30 * math.cos(_backgroundAnimation.value + index)) %
                        screenSize.height,
                    child: Container(
                      width: 4 + index % 3,
                      height: 4 + index % 3,
                      decoration: BoxDecoration(
                        color: kWhiteColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),

                // Main content
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 60),
                        _buildAnimatedLogo(),
                        SizedBox(height: 48.0),
                        _buildAnimatedForm(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value * math.pi,
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [kWhiteColor, kSecondaryColor, kPrimaryColor],
                      stops: [0.0, 0.7, 1.0],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(Icons.store, size: 60, color: kWhiteColor),
                ),
                SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [kWhiteColor, kSecondaryColor],
                  ).createShader(bounds),
                  child: Text(
                    'Gene POS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: kWhiteColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedForm() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _formSlideAnimation.value),
          child: Opacity(
            opacity: _formOpacityAnimation.value,
            child: _buildGlassmorphicContainer(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: kWhiteColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        color: kWhiteColor.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.0),
                    _buildAnimatedTextField(
                      controller: _emailController,
                      hintText: 'Email Address',
                      icon: Icons.email_outlined,
                      delay: 200,
                    ),
                    SizedBox(height: 20.0),
                    _buildAnimatedTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      delay: 400,
                    ),
                    SizedBox(height: 32.0),
                    _isLoading ? _buildLoadingSpinner() : _buildLoginButton(),
                    SizedBox(height: 20.0),
                    _buildRegisterButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphicContainer({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kGlassLight, kGlassDark],
              ),
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(color: kGlassBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              gradient: LinearGradient(
                colors: [
                  kWhiteColor.withOpacity(0.1),
                  kWhiteColor.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: kWhiteColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: TextStyle(
                color: kWhiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: kWhiteColor.withOpacity(0.6),
                  fontSize: 16,
                ),
                prefixIcon: Icon(icon, color: kSecondaryColor, size: 24),
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: kSecondaryColor, width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 18.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSpinner() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [kSecondaryColor, kAccentColor]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kSecondaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kWhiteColor),
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kSecondaryColor, kAccentColor]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: kSecondaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: _handleLogin,
                child: Center(
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: kWhiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterButton() {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: kWhiteColor.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Don\'t have an account? ',
                            style: TextStyle(
                              color: kWhiteColor.withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              color: kSecondaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleLogin() async {
    // Validate inputs
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your email or username');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final result = await authService.login(
        emailOrUsername: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          _showSuccessSnackBar(result['message']);
          // Navigate to dashboard after successful login
          Future.delayed(Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          });
        } else {
          _showErrorSnackBar(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Login failed: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: kWhiteColor)),
        backgroundColor: Colors.red.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: kWhiteColor)),
        backgroundColor: Colors.green.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}
