import 'package:flutter/material.dart';
import 'onboarding_page.dart';
import 'sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 1;
  final int totalPages = 3;

  final List<Map<String, dynamic>> onboardingData = [
    {
      'title': 'Find Any Driver',
      'description':
          'Easily find reliable drivers in your area. Connect with verified professionals and book rides with confidence.',
      'icon': Icons.person_add,
      'color': const Color(0xFF2196F3),
    },
    {
      'title': 'Find Car Parts',
      'description':
          'Browse and purchase genuine car parts from trusted sellers. Get exactly what you need for your vehicle maintenance.',
      'icon': Icons.build,
      'color': const Color(0xFF00BCD4),
    },
    {
      'title': 'Find Nearest Garage',
      'description':
          'Locate the nearest service garage to you. Check ratings, services, and book appointments instantly.',
      'icon': Icons.location_on,
      'color': const Color(0xFF009688),
    },
  ];

  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = onboardingData[currentPage - 1];

    return OnboardingPage(
      title: data['title'],
      description: data['description'],
      icon: data['icon'],
      backgroundColor: data['color'],
      pageNumber: currentPage,
      totalPages: totalPages,
      onNext: _nextPage,
      onSkip: _skipOnboarding,
    );
  }
}
