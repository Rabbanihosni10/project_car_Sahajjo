import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'screens/visitor_home_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/owner_home_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard.dart';

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
      home: const SplashScreen(),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/home': (context) => const HomeScreen(),
        '/visitor/home': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return VisitorHomeScreen(userData: userData);
        },
        '/driver/home': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return DriverHomeScreen(userData: userData);
        },
        '/owner/home': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return OwnerHomeScreen(userData: userData);
        },
        '/edit-profile': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return EditProfileScreen(userData: userData);
        },
        '/profile': (context) {
          // This will be handled by the home screens themselves
          return const Scaffold(body: Center(child: Text('Profile Screen')));
        },
        '/admin/login': (context) => const AdminLoginScreen(),
        '/admin/dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}
