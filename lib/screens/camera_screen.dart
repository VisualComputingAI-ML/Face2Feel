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

  // you’ll import this correctly below
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _isLoading = true;
      });

      try {
        // Change IP below to your laptop's IPv4 (same as in FastAPI)
        var uri = Uri.parse("http://192.168.43.100:8000/predict");

        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _image!.path,
          contentType: MediaType('image', 'jpeg'),
        ));

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          var data = jsonDecode(responseBody);
          setState(() {
            _emotion = data["emotion"];
            _confidence = data["confidence"];
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Emotion: $_emotion (Confidence: ${_confidence!.toStringAsFixed(2)})",
                ),
              ),
            );
          }
        } else {
          throw Exception("Server error: ${response.statusCode}");
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading image: $e")),
        );
      }
    } else {
      print("No image selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capture Emotion")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 250)
                : const Text("No image captured yet"),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("Capture Image"),
                  ),
            const SizedBox(height: 20),
            if (_emotion != null)
              Text(
                "Detected Emotion: $_emotion\nConfidence: ${_confidence?.toStringAsFixed(2)}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
