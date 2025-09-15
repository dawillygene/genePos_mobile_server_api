import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.primaryWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.store,
                  size: 64,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 32),

              // App Name
              Text(
                'GenePos',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryWhite,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Point of Sale System',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.primaryWhite.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 48),

              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
