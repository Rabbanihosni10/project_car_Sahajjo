import 'package:flutter/material.dart';
import '../models/user.dart';
import 'signup_visitor.dart';
import 'signup_driver.dart';
import 'signup_car_owner.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Car Sahajjo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Select your role to get started',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Role Selection Cards
              _buildRoleCard(
                role: UserRole.visitor,
                title: 'Visitor',
                subtitle: 'Book and ride',
                icon: Icons.person,
                description: 'Looking to book a ride? Sign up as a visitor.',
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                role: UserRole.driver,
                title: 'Driver',
                subtitle: 'Earn money driving',
                icon: Icons.directions_car,
                description: 'Want to drive and earn? Join us as a driver.',
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                role: UserRole.carOwner,
                title: 'Car Owner',
                subtitle: 'Manage your fleet',
                icon: Icons.business,
                description: 'Own a car business? Manage it with us.',
              ),
              const SizedBox(height: 30),

              // Continue Button
              if (_selectedRole != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _navigateToSignUp(_selectedRole!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required String description,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = _selectedRole == role ? null : role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<UserRole>(
                  value: role,
                  groupValue: _selectedRole,
                  activeColor: const Color(0xFF2196F3),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSignUp(UserRole role) {
    Widget nextScreen;
    switch (role) {
      case UserRole.visitor:
        nextScreen = const SignUpVisitorScreen();
        break;
      case UserRole.driver:
        nextScreen = const SignUpDriverScreen();
        break;
      case UserRole.carOwner:
        nextScreen = const SignUpCarOwnerScreen();
        break;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => nextScreen));
  }
}
