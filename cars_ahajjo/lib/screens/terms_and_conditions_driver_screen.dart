import 'package:flutter/material.dart';

class TermsAndConditionsDriverScreen extends StatelessWidget {
  const TermsAndConditionsDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: const Text(
          'Driver Terms & Conditions',
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
                'Driver Terms and Conditions',
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
                '1. Driver Requirements',
                'To register as a driver on CarSahajjo, you must:\n• Possess a valid driving license\n• Have at least 2 years of driving experience\n• Be at least 21 years of age\n• Have a clean driving record\n• Pass our background verification check\n• Complete orientation and training program',
              ),

              _buildSection(
                '2. License and Documentation',
                'You must maintain valid and up-to-date documentation at all times, including:\n• Valid driving license\n• Vehicle registration documents\n• Insurance papers\n• Identity proof\n\nFailure to maintain valid documents may result in immediate suspension of your account.',
              ),

              _buildSection(
                '3. Vehicle Standards',
                'Any vehicle you drive must meet the following standards:\n• Be in good working condition\n• Pass safety inspections\n• Have valid insurance coverage\n• Be clean and well-maintained\n• Meet age and model requirements\n• Have all required safety equipment',
              ),

              _buildSection(
                '4. Professional Conduct',
                'As a driver, you agree to:\n• Maintain professional behavior with all passengers\n• Dress appropriately and maintain personal hygiene\n• Follow traffic laws and regulations\n• Not drive under the influence of alcohol or drugs\n• Not smoke in the vehicle while on duty\n• Respect passenger privacy and property\n• Provide safe and courteous service',
              ),

              _buildSection(
                '5. Earnings and Payments',
                'Driver earnings are calculated based on distance, time, and service type. Payments are processed weekly to your registered bank account. CarSahajjo charges a commission on each completed trip. You are responsible for all applicable taxes on your earnings.',
              ),

              _buildSection(
                '6. Insurance and Liability',
                'You must maintain appropriate commercial vehicle insurance. You are responsible for any damages or injuries that occur due to your negligence. CarSahajjo is not liable for accidents that occur during trips unless caused by platform defects.',
              ),

              _buildSection(
                '7. Trip Acceptance',
                'While you have the freedom to accept or decline trips, excessive cancellations or rejections may affect your driver rating and account standing. Once a trip is accepted, you must complete it unless there are safety concerns.',
              ),

              _buildSection(
                '8. Safety and Security',
                'You must:\n• Verify passenger identity before starting trips\n• Use the app\'s GPS navigation\n• Report any safety incidents immediately\n• Not share passenger information with third parties\n• Follow emergency protocols\n• Use the panic button in case of emergencies',
              ),

              _buildSection(
                '9. Rating and Reviews',
                'Passengers can rate and review your service. Low ratings may result in warnings or account deactivation. You have the right to dispute unfair ratings within 48 hours of receiving them.',
              ),

              _buildSection(
                '10. Account Suspension',
                'Your account may be suspended or terminated for:\n• Violation of terms and conditions\n• Criminal activity\n• Multiple customer complaints\n• Poor rating consistently\n• Fraud or dishonest behavior\n• Safety violations',
              ),

              _buildSection(
                '11. Working Hours',
                'You are free to set your own working hours. However, you must be available during any scheduled commitments. Extended periods of inactivity may result in account review.',
              ),

              _buildSection(
                '12. Data Privacy',
                'Your personal information and trip data will be collected and used as per our Privacy Policy. You consent to GPS tracking while you are online on the platform.',
              ),

              _buildSection(
                '13. Independent Contractor Status',
                'You are an independent contractor, not an employee of CarSahajjo. You are responsible for your own taxes, insurance, and expenses. You control your own work schedule and methods.',
              ),

              _buildSection(
                '14. Dispute Resolution',
                'Any disputes with passengers or CarSahajjo will be resolved through our dispute resolution process. Serious disputes may be subject to arbitration as per applicable laws.',
              ),

              _buildSection(
                '15. Contact Information',
                'For driver support, contact us at:\n\nEmail: rabbanihosni10.com\nPhone: +880-173-2268241\nDriver Help Center: Available 24/7',
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
                  'By registering as a driver on CarSahajjo, you acknowledge that you have read, understood, and agree to be bound by these Driver Terms and Conditions.',
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
