import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  String? _emotion;
  double? _confidence;
  bool _isLoading = false;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
  try {
    final picked = await picker.pickImage(source: ImageSource.camera);
    
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _isLoading = true;
        _emotion = null;
        _confidence = null;
      });

      print("📸 Image captured: ${_image!.path}");
      print("📱 Image size: ${_image!.lengthSync()} bytes");
      print("🌐 Sending request to server...");

      // Test the connection first
      try {
        var testResponse = await http.get(Uri.parse("http://10.145.122.110:8000/"));
        print("✅ Server connection test: ${testResponse.statusCode}");
        print("✅ Server response: ${testResponse.body}");
      } catch (e) {
        print("❌ Server connection failed: $e");
      }

      var uri = Uri.parse("http://10.145.122.110:8000/predict");
      print("🔗 API Endpoint: $uri");

      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _image!.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      print("📤 Starting file upload...");
      
      var response = await request.send();
      print("📥 Response received. Status: ${response.statusCode}");
      
      var responseBody = await response.stream.bytesToString();
      print("📄 Response body: $responseBody");

      if (response.statusCode == 200) {
        var data = jsonDecode(responseBody);
        print("✅ Prediction successful!");
        print("🎭 Emotion: ${data["emotion"]}");
        print("📊 Confidence: ${data["confidence"]}");
        
        setState(() {
          _emotion = data["emotion"];
          _confidence = data["confidence"];
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Emotion detected: $_emotion!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print("❌ Server error: ${response.statusCode}");
        throw Exception("Server returned ${response.statusCode}: $responseBody");
      }
    }
  } catch (e) {
    print("💥 ERROR: $e");
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capture Emotion")),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView to avoid overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _image != null
                  ? Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    )
                  : Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("No image captured yet"),
                        ],
                      ),
                    ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Processing image..."),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text("Capture Image"),
                    ),
              const SizedBox(height: 30),
              if (_emotion != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Detected Emotion:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _emotion!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Confidence: ${_confidence!.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}