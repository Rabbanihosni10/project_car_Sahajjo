import 'package:flutter/material.dart';

class TermsAndConditionsOwnerScreen extends StatelessWidget {
  const TermsAndConditionsOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: const Text(
          'Car Owner Terms & Conditions',
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
                'Car Owner Terms and Conditions',
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
                '1. Vehicle Registration',
                'To list vehicles on CarSahajjo, you must:\n• Own the vehicle or have legal authority to rent it\n• Provide accurate vehicle information\n• Upload clear photos of the vehicle\n• Maintain valid registration documents\n• Ensure the vehicle meets safety standards\n• Provide proof of ownership',
              ),

              _buildSection(
                '2. Vehicle Requirements',
                'All vehicles listed must:\n• Be in good working condition\n• Have valid registration\n• Have comprehensive insurance coverage\n• Pass our vehicle inspection\n• Be clean and well-maintained\n• Meet safety and emission standards\n• Have working safety features (seat belts, airbags, etc.)',
              ),

              _buildSection(
                '3. Insurance Coverage',
                'You must maintain adequate insurance coverage for your vehicles, including:\n• Comprehensive vehicle insurance\n• Third-party liability coverage\n• Passenger insurance\n• Proof of insurance must be updated regularly\n\nCarSahajjo is not responsible for any damage or loss not covered by your insurance.',
              ),

              _buildSection(
                '4. Pricing and Earnings',
                'You have the flexibility to set competitive rental rates for your vehicles, subject to our minimum and maximum pricing guidelines. CarSahajjo charges a commission on each completed rental. Payments are processed weekly to your registered bank account. You are responsible for all applicable taxes.',
              ),

              _buildSection(
                '5. Vehicle Availability',
                'You must:\n• Keep your vehicle calendar updated\n• Respond to booking requests within 24 hours\n• Honor confirmed bookings\n• Notify users of any cancellations immediately\n• Maintain accurate availability information',
              ),

              _buildSection(
                '6. Vehicle Handover',
                'When handing over your vehicle:\n• Verify driver/renter identity\n• Document vehicle condition with photos\n• Check driver\'s license validity\n• Explain vehicle features and controls\n• Note fuel level and mileage\n• Provide emergency contact information\n• Use the app\'s check-in/check-out feature',
              ),

              _buildSection(
                '7. Maintenance and Safety',
                'You are responsible for:\n• Regular vehicle maintenance\n• Safety inspections as required\n• Addressing any mechanical issues promptly\n• Ensuring vehicle cleanliness\n• Keeping service records updated\n• Immediate reporting of any safety concerns',
              ),

              _buildSection(
                '8. Liability and Damages',
                'While renters are responsible for damage during their rental period:\n• You must report damages within 24 hours\n• Provide evidence of damages with photos\n• Follow our claims process\n• Maintain proper insurance\n• You may be liable for damages due to poor maintenance',
              ),

              _buildSection(
                '9. Prohibited Uses',
                'You may not:\n• List vehicles you don\'t own or have authority over\n• Provide false information\n• List unsafe or unroadworthy vehicles\n• Discriminate against renters\n• Engage in fraudulent activities\n• Use unlicensed or uninsured vehicles',
              ),

              _buildSection(
                '10. Cancellation Policy',
                'If you need to cancel a confirmed booking:\n• Notify the renter immediately\n• Cancel through the app\n• Penalties may apply for last-minute cancellations\n• Excessive cancellations may affect your account status',
              ),

              _buildSection(
                '11. Background Checks',
                'We reserve the right to conduct background checks on all car owners. You must provide accurate information for verification. False information may result in immediate account termination.',
              ),

              _buildSection(
                '12. Rating and Reviews',
                'Renters can rate your vehicles and service. Good ratings improve visibility and bookings. You can respond to reviews and dispute unfair ratings within 48 hours.',
              ),

              _buildSection(
                '13. Account Management',
                'Your account may be suspended or terminated for:\n• Violation of terms and conditions\n• Multiple customer complaints\n• Poor vehicle condition\n• False information\n• Safety violations\n• Fraudulent activities',
              ),

              _buildSection(
                '14. Data and Privacy',
                'Your information and vehicle data will be used as per our Privacy Policy. We may share necessary information with renters and authorities as required by law.',
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
                  'By registering as a car owner on CarSahajjo, you acknowledge that you have read, understood, and agree to be bound by these Car Owner Terms and Conditions.',
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
