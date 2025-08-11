import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gene_pos/constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _textController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Text animations
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _textSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Background animation
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    // Particle animation
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    // Start animations sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    await Future.delayed(Duration(milliseconds: 500));
    _logoController.forward();

    await Future.delayed(Duration(milliseconds: 1000));
    _textController.forward();

    await Future.delayed(Duration(milliseconds: 3000));
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_backgroundAnimation, _particleAnimation]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0 + 0.3 * math.sin(_backgroundAnimation.value),
                colors: [
                  kGradientStart.withOpacity(0.8),
                  kGradientMiddle,
                  kGradientEnd,
                  kPrimaryColor,
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated particles
                ...List.generate(20, (index) {
                  final progress =
                      (_particleAnimation.value + index / 20) % 1.0;
                  final angle = 2 * math.pi * index / 20;
                  final radius = screenSize.width * 0.4 * progress;

                  return Positioned(
                    left: screenSize.width / 2 + radius * math.cos(angle) - 3,
                    top: screenSize.height / 2 + radius * math.sin(angle) - 3,
                    child: Opacity(
                      opacity: (1 - progress) * 0.6,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kSecondaryColor.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Transform.rotate(
                              angle: _logoRotationAnimation.value * math.pi,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      kWhiteColor,
                                      kSecondaryColor,
                                      kAccentColor,
                                      kPrimaryColor,
                                    ],
                                    stops: [0.0, 0.3, 0.7, 1.0],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: kSecondaryColor.withOpacity(0.6),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.store_mall_directory,
                                  size: 80,
                                  color: kWhiteColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 40),

                      // Animated text
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _textSlideAnimation.value),
                            child: Opacity(
                              opacity: _textOpacityAnimation.value,
                              child: Column(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        kWhiteColor,
                                        kSecondaryColor,
                                        kWhiteColor,
                                      ],
                                      stops: [0.0, 0.5, 1.0],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Gene POS',
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: kWhiteColor,
                                        letterSpacing: 3.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Point of Sale System',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: kWhiteColor.withOpacity(0.9),
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(height: 60),
                                  // Loading indicator
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        kSecondaryColor,
                                      ),
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
