import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Sahajjo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
      ),
      home: const SignInScreen(),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
