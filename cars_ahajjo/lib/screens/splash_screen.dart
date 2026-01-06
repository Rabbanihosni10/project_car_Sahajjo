import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart';
import '../services/auth_services.dart';
import '../services/message_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize socket connection globally
    MessageService.initializeSocket();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // Navigate based on login status and role
    Timer(const Duration(seconds: 3), () {
      _navigateBasedOnAuthStatus();
    });
  }

  Future<void> _navigateBasedOnAuthStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // User is logged in, navigate to appropriate home screen
      final userData = await AuthService.getUserData();
      final role = userData?['role'] as String? ?? 'visitor';

      switch (role) {
        case 'driver':
          Navigator.of(
            context,
          ).pushReplacementNamed('/driver/home', arguments: userData ?? {});
          break;
        case 'owner':
        case 'carOwner':
          Navigator.of(
            context,
          ).pushReplacementNamed('/owner/home', arguments: userData ?? {});
          break;
        case 'visitor':
        default:
          Navigator.of(
            context,
          ).pushReplacementNamed('/visitor/home', arguments: userData ?? {});
          break;
      }
    } else {
      // User not logged in, navigate to onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon/Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    size: 60,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 30),
                // App Name
                const Text(
                  'Car Sahajjo',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                // Tagline
                const Text(
                  'Your Reliable Car Service App\n        Anywhere, Anytime',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 50),
                // Loading Indicator
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
