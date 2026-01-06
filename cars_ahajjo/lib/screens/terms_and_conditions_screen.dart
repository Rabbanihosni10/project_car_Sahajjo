import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Terms and Conditions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last Updated: December 22, 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              _buildSection(
                '1. Acceptance of Terms',
                'By accessing and using CarSahajjo, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these terms, please do not use our service.',
              ),

              _buildSection(
                '2. User Accounts',
                'When you create an account with us, you must provide accurate, complete, and current information. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account.\n\nYou are responsible for safeguarding the password and for all activities that occur under your account.',
              ),

              _buildSection(
                '3. Service Description',
                'CarSahajjo is a platform that connects car owners, drivers, and visitors for car rental and ride-sharing services. We act as an intermediary and are not responsible for the actual services provided by car owners or drivers.',
              ),

              _buildSection(
                '4. User Responsibilities',
                '• Provide accurate and truthful information\n• Maintain the confidentiality of your account\n• Notify us immediately of any unauthorized use\n• Comply with all applicable laws and regulations\n• Respect other users and their property\n• Not use the service for any illegal or unauthorized purpose',
              ),

              _buildSection(
                '5. Payment Terms',
                'All payments are processed through secure payment gateways. Users agree to pay all fees and charges incurred through their account. Prices are subject to change with notice. Refunds are subject to our refund policy.',
              ),

              _buildSection(
                '6. Cancellation Policy',
                'Cancellations made 24 hours before the scheduled time may receive a full refund. Cancellations made within 24 hours may incur a cancellation fee. No-shows will be charged the full amount.',
              ),

              _buildSection(
                '7. Liability',
                'CarSahajjo shall not be liable for any indirect, incidental, special, consequential or punitive damages resulting from your use or inability to use the service. We do not guarantee the availability, quality, or safety of services provided by car owners or drivers.',
              ),

              _buildSection(
                '8. Insurance',
                'Car owners must maintain appropriate insurance coverage. Users are responsible for verifying insurance coverage before using any vehicle. CarSahajjo is not responsible for any damages or accidents that occur during the rental period.',
              ),

              _buildSection(
                '9. Privacy Policy',
                'Your use of CarSahajjo is also governed by our Privacy Policy. We collect and use your information as described in our Privacy Policy. By using our service, you consent to such processing.',
              ),

              _buildSection(
                '10. Intellectual Property',
                'The service and its original content, features, and functionality are owned by CarSahajjo and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
              ),

              _buildSection(
                '11. Termination',
                'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms. Upon termination, your right to use the service will immediately cease.',
              ),

              _buildSection(
                '12. Changes to Terms',
                'We reserve the right to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days notice prior to any new terms taking effect. Continued use of the service after changes constitutes acceptance of the new terms.',
              ),

              _buildSection(
                '13. Dispute Resolution',
                'Any disputes arising from these terms shall be resolved through arbitration in accordance with applicable laws. You agree to waive any right to a jury trial or to participate in a class action.',
              ),

              _buildSection(
                '14. Governing Law',
                'These Terms shall be governed and construed in accordance with the laws of the jurisdiction in which CarSahajjo operates, without regard to its conflict of law provisions.',
              ),

              _buildSection(
                '15. Contact Information',
                'For car owner support, contact us at:\n\nEmail: rabbanihosni10@gmail.com\nPhone: +880-173-2268241\nOwner Help Center: Available 24/7',
              ),

              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2196F3)),
                ),
                child: const Text(
                  'By clicking "I agree to Terms & Conditions" on the signup page, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
