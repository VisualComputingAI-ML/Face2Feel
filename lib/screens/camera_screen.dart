import 'dart:io';
import 'package:face2feel/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'chat_screen.dart';

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
        });

        print("📸 Image captured, detecting emotion...");
        
        Map<String, dynamic> result = await ApiService.uploadImage(_image!);
        
        setState(() {
          _emotion = result["emotion"];
          _confidence = result["confidence"]?.toDouble();
          _isLoading = false;
        });

        // Show emotion result and option to chat
        _showEmotionResult();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Error detecting emotion: $e");
    }
  }

  void _showEmotionResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Emotion Detected!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _emotion!.toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text("Confidence: ${_confidence!.toStringAsFixed(2)}"),
            SizedBox(height: 20),
            Text("Would you like to chat with a counselor about how you're feeling?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Maybe Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToChat();
            },
            child: Text("Yes, Let's Chat"),
          ),
        ],
      ),
    );
  }
void _navigateToChat() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(), // No parameters needed
    ),
  );
}
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Capture Your Emotion"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emotion display if detected
              if (_emotion != null) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Current Emotion:",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _emotion!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _getEmotionColor(_emotion!),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Confidence: ${_confidence!.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
              ],

              // Image preview
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
  Icons.face,  // or Icons.face_outlined
  size: 60,
  color: Colors.blue.shade300,
),
                          SizedBox(height: 10),
                          Text(
                            "Capture your face\nto detect emotion",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
              ),

              SizedBox(height: 40),

              // Action buttons
              _isLoading
                  ? Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          "Analyzing your emotion...",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt),
                          SizedBox(width: 10),
                          Text(
                            "Capture Emotion",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),

              if (_emotion != null) ...[
                SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _navigateToChat,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Chat with Counselor",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'surprised':
        return Colors.orange;
      case 'fear':
        return Colors.purple;
      case 'disgust':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}