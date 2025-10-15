import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = "http://10.146.36.223:8000"; // Your server IP
  static const int timeoutSeconds = 30;

// In api_services.dart - Add better error handling
static Future<Map<String, dynamic>> uploadImage(File image) async {
  try {
    var uri = Uri.parse("$baseUrl/predict");
    print("📤 Uploading image to: $uri");

    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      image.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    print("🔄 Sending request...");
    
    var response = await request.send().timeout(Duration(seconds: 30));
    var responseBody = await response.stream.bytesToString();

    print("📥 Response status: ${response.statusCode}");
    print("📄 Response body: $responseBody");

    if (response.statusCode == 200) {
      final result = jsonDecode(responseBody);
      
      // ✅ ADD THIS VALIDATION
      if (result['emotion'] == null || result['confidence'] == null) {
        throw Exception("Invalid response format from server");
      }
      
      print("✅ Emotion detection successful: $result");
      return result;
    } else {
      print("❌ Server error: ${response.statusCode}");
      throw Exception("Failed to detect emotion: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ ApiService error: $e");
    rethrow;
  }
}

  static Future<Map<String, dynamic>> chatWithCounselor(String emotion, String message) async {
    try {
      var uri = Uri.parse("$baseUrl/chat");
      print("💬 Sending chat request to: $uri");
      
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'emotion': emotion,
          'message': message,
        }),
      ).timeout(Duration(seconds: timeoutSeconds));

      print("💬 Chat API response status: ${response.statusCode}");
      print("💬 Chat API response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("✅ Chat successful: ${responseData['counselor_response']}");
        return responseData;
      } else {
        print("❌ Chat API error: ${response.statusCode} - ${response.body}");
        throw Exception("Chat failed with status ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("❌ ApiService chat error: $e");
      rethrow;
    }
  }

  // Test server connection
  static Future<bool> testConnection() async {
    try {
      var response = await http.get(
        Uri.parse("$baseUrl/"),
      ).timeout(Duration(seconds: 10));
      
      print("🔗 Server connection test: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Server connection test failed: $e");
      return false;
    }
  }
}