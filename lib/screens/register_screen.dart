import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gene_pos/constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
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
  final TextEditingController _usernameController = TextEditingController();
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
    _usernameController.dispose();
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
                  kAccentColor,
                  kGradientMiddle,
                  kGradientStart,
                  kPrimaryColor,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [
                  0.0,
                  0.3 + 0.2 * math.cos(_backgroundAnimation.value),
                  0.7 + 0.2 * math.sin(_backgroundAnimation.value),
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background particles
                ...List.generate(15, (index) {
                  return Positioned(
                    left:
                        (screenSize.width * (index / 15) +
                            40 * math.cos(_backgroundAnimation.value + index)) %
                        screenSize.width,
                    top:
                        (screenSize.height * (index / 15) +
                            35 * math.sin(_backgroundAnimation.value + index)) %
                        screenSize.height,
                    child: Container(
                      width: 3 + index % 4,
                      height: 3 + index % 4,
                      decoration: BoxDecoration(
                        color: kWhiteColor.withOpacity(0.2),
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
                        SizedBox(height: 40),
                        _buildAnimatedLogo(),
                        SizedBox(height: 32.0),
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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [kSecondaryColor, kAccentColor, kPrimaryColor],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kSecondaryColor.withOpacity(0.4),
                        blurRadius: 25,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(Icons.person_add, size: 50, color: kWhiteColor),
                ),
                SizedBox(height: 12),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [kWhiteColor, kSecondaryColor],
                  ).createShader(bounds),
                  child: Text(
                    'Join Gene POS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kWhiteColor,
                      letterSpacing: 1.5,
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
                      'Create Account',
                      style: TextStyle(
                        color: kWhiteColor,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fill in your details to get started',
                      style: TextStyle(
                        color: kWhiteColor.withOpacity(0.8),
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 28.0),
                    _buildAnimatedTextField(
                      controller: _usernameController,
                      hintText: 'Full Name',
                      icon: Icons.person_outline,
                      delay: 0,
                    ),
                    SizedBox(height: 18.0),
                    _buildAnimatedTextField(
                      controller: _emailController,
                      hintText: 'Email Address',
                      icon: Icons.email_outlined,
                      delay: 200,
                    ),
                    SizedBox(height: 18.0),
                    _buildAnimatedTextField(
                      controller: _passwordController,
                      hintText: 'Create Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      delay: 400,
                    ),
                    SizedBox(height: 28.0),
                    _isLoading
                        ? _buildLoadingSpinner()
                        : _buildRegisterButton(),
                    SizedBox(height: 18.0),
                    _buildLoginButton(),
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
                  color: kSecondaryColor.withOpacity(0.1),
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
        gradient: LinearGradient(colors: [kAccentColor, kSecondaryColor]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withOpacity(0.4),
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

  Widget _buildRegisterButton() {
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
              gradient: LinearGradient(colors: [kAccentColor, kSecondaryColor]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: kAccentColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: _handleRegister,
                child: Center(
                  child: Text(
                    'Create Account',
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

  Widget _buildLoginButton() {
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
                  onTap: () => Navigator.pop(context),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              color: kWhiteColor.withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: 'Sign In',
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

  void _handleRegister() {
    setState(() {
      _isLoading = true;
    });

    // Simulate registration process
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushNamed(context, '/dashboard');
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}
