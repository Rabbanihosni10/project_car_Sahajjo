import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'screens/visitor_home_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/owner_home_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/forum_screen.dart';
import 'screens/driver_details_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/garage_map_screen.dart';
import 'screens/owner_garage_map_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/car_info_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/notifications_screen.dart';
import 'screens/people_feature.dart';
import 'screens/my_connections_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';

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
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return ProfileScreen(userData: userData);
        },
        '/wallet': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return WalletScreen(userData: userData);
        },
        '/admin/login': (context) => const AdminLoginScreen(),
        '/admin/dashboard': (context) => const AdminDashboard(),
        '/notifications': (context) => const NotificationsScreen(),
        '/forum': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return ForumScreen(userData: userData);
        },
        '/driver-details': (context) {
          final driverData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return DriverDetailsScreen(driverData: driverData);
        },
        '/messages': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return MessagesScreen(userData: userData);
        },
        '/map': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return GarageMapScreen(userData: userData);
        },
        '/ai-chat': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return AIChatScreen(userData: userData);
        },
        '/car-info': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return CarInfoScreen(userData: userData);
        },
        '/owner/garages': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return OwnerGarageMapScreen(userData: userData);
        },
        '/people': (context) => const PeopleDiscoveryScreen(),
        '/my-connections': (context) => const MyConnectionsScreen(),
        '/marketplace': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return MarketplaceScreen(userData: userData);
        },
        '/marketplace/product': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return ProductDetailsScreen(
            productId: args['productId'] ?? '',
            userData: args['userData'],
            buyNow: args['buyNow'] ?? false,
          );
        },
        '/cart': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return CartScreen(userData: userData);
        },
        '/checkout': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return CheckoutScreen(userData: userData);
        },
      },
    );
  }
}
