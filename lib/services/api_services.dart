import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = "http://10.145.122.110:8000"; // Update this IP

  static Future<Map<String, dynamic>> uploadImage(File image) async {
    try {
      var uri = Uri.parse("$baseUrl/predict");

      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      print("Uploading image to: $uri");
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("Response: ${response.statusCode} - $responseBody");

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception("Failed to upload image: ${response.statusCode} - $responseBody");
      }
    } catch (e) {
      print("ApiService error: $e");
      rethrow;
    }
  }
}