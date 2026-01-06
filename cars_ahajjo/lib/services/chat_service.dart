import 'package:http/http.dart' as http;
import 'package:cars_ahajjo/services/auth_services.dart';
import 'package:cars_ahajjo/utils/constrains.dart';
import 'dart:convert';

class ChatService {
  static String get _baseUrl => '${AppConstants.baseUrl}/chat';

  // Add your Gemini API key here
  static const String _geminiApiKey =
      'AIzaSyDqPGTZ9KZ1Z8hZxZ9Z9Z9Z9Z9Z9Z9Z9Z9'; // Replace with actual key
  static const String _geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  /// Ask AI Assistant a question (with optional image)
  static Future<String> askAI(String question, {String? imagePath}) async {
    try {
      // If we have an image, we MUST use the backend because client-side 
      // direct API calls with images are complex and less secure
      if (imagePath != null) {
        return await _askBackendWithImage(question, imagePath);
      }
      
      // Try Gemini API first for real-time responses (Text Only)
      final geminiResponse = await _askGemini(question);
      if (geminiResponse != null) {
        return geminiResponse;
      }

      // Fallback to backend endpoint
      final token = await AuthService.getToken();
      if (token == null) {
        return 'Please login to use AI Chat.';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/ask'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'question': question}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']?['answer'] ??
            data['answer'] ??
            'No response from AI';
      } else {
        return _getLocalAIResponse(question);
      }
    } catch (e) {
      print('Error: $e');
      return _getLocalAIResponse(question);
    }
  }

  static Future<String> _askBackendWithImage(String question, String imagePath) async {
      try {
        final token = await AuthService.getToken();
        if (token == null) return 'Please login to use AI Chat.';

        var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/ask'));
        request.headers['Authorization'] = 'Bearer $token';
        
        request.fields['question'] = question;
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['data']?['answer'] ?? data['answer'] ?? 'No response';
        } else {
          try {
             final errData = jsonDecode(response.body);
             return "Error: ${errData['message'] ?? 'Failed to analyze image'}";
          } catch (_) {
             return "Failed to analyze image. Status: ${response.statusCode}";
          }
        }
      } catch (e) {
        print("Image upload error: $e");
        return "Failed to upload image for analysis. Please check your connection.";
      }
  }

  /// Call Gemini API directly for real-time AI responses
  static Future<String?> _askGemini(String question) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_geminiUrl?key=$_geminiApiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {
                      'text':
                          'You are a helpful car assistant for a car rental and service app called CarSahajjo. '
                          'Provide helpful, concise advice about cars, maintenance, driving, and rentals. '
                          'User question: $question',
                    },
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 500},
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null && text.isNotEmpty) {
          return text;
        }
      }
    } catch (e) {
      print('Gemini API error: $e');
    }
    return null;
  }

  /// Local AI responses for common queries
  static String _getLocalAIResponse(String question) {
    final lowerQuestion = question.toLowerCase();

    // Car maintenance
    if (lowerQuestion.contains('oil change')) {
      return 'Regular oil changes every 5,000-7,500 km keep your engine healthy. Use the recommended oil grade from your manual.';
    }
    if (lowerQuestion.contains('tire') || lowerQuestion.contains('tyre')) {
      return 'Check tire pressure monthly and rotate tires every 10,000 km. Replace when tread depth is below 1.6mm.';
    }
    if (lowerQuestion.contains('brake')) {
      return 'Brake pads should be replaced when thickness is below 3mm. Listen for squeaking sounds as a warning sign.';
    }
    if (lowerQuestion.contains('battery')) {
      return 'Car batteries typically last 3-5 years. Keep terminals clean and check water level in non-sealed batteries.';
    }

    // Driving tips
    if (lowerQuestion.contains('speed') || lowerQuestion.contains('highway')) {
      return 'Follow traffic limits. On highways, maintain steady speed around 80-100 km/h. Avoid sudden acceleration/braking.';
    }
    if (lowerQuestion.contains('fuel') || lowerQuestion.contains('gas')) {
      return 'Improve fuel efficiency: maintain proper tire pressure, avoid idling, accelerate gradually, and service your car regularly.';
    }
    if (lowerQuestion.contains('safe') || lowerQuestion.contains('accident')) {
      return 'Drive defensively: stay alert, maintain safe distance from other vehicles, avoid distractions, and always use seatbelts.';
    }

    // Rental tips
    if (lowerQuestion.contains('rent')) {
      return 'When renting a car: check condition before taking it, photograph any damage, drive carefully, and return on time to avoid charges.';
    }

    // Default response
    return 'I\'m your AI assistant for car-related questions. Ask me about maintenance, driving tips, fuel efficiency, or rental advice!';
  }

  /// Get chat history
  static Future<List<dynamic>> getChatHistory() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/history'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Clear chat history
  static Future<bool> clearHistory() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/history'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
