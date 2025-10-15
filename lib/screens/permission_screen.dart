import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chat_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isCheckingPermissions = false;
  String _statusMessage = "We need camera access to provide real-time emotional support";

  Future<void> _checkAndRequestPermissions() async {
    setState(() {
      _isCheckingPermissions = true;
      _statusMessage = "Checking permissions...";
    });

    try {
      // Check camera permission
      var cameraStatus = await Permission.camera.status;
      
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }

      if (cameraStatus.isGranted) {
        // Navigate to chat screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      } else {
        setState(() {
          _statusMessage = "Camera permission is required for emotional support. Please enable it in settings.";
          _isCheckingPermissions = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error checking permissions: $e";
        _isCheckingPermissions = false;
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Camera Permission Required"),
        content: Text("Face2Feel needs camera access to detect your emotions in real-time and provide appropriate support."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.psychology,
                  size: 60,
                  color: Colors.blueAccent,
                ),
              ),
              
              SizedBox(height: 40),
              
              // Title
              Text(
                "Welcome to Face2Feel",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              
              SizedBox(height: 16),
              
              // Description
              Text(
                "Your AI Emotional Support Companion",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 30),
              
              // Permission explanation
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "• Real-time emotion detection\n• Personalized support\n• Your privacy is protected",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40),
              
              // Action buttons
              if (!_isCheckingPermissions) ...[
                ElevatedButton(
                  onPressed: _checkAndRequestPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Allow Camera Access",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: _showPermissionDeniedDialog,
                  child: Text(
                    "Why do we need this?",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ] else ...[
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "Setting up camera...",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}