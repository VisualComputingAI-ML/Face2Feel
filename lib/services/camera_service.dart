import 'dart:io';
import 'package:camera/camera.dart';


class CameraService {
  static CameraController? _cameraController;
  static bool _isInitialized = false;

  // Initialize camera
  static Future<bool> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      print("❌ Camera initialization failed: $e");
      _isInitialized = false;
      return false;
    }
  }

  // Capture image without showing preview
  static Future<File?> captureImage() async {
    if (!_isInitialized || _cameraController == null) {
      await initializeCamera();
    }

    try {
      final image = await _cameraController!.takePicture();
      return File(image.path);
    } catch (e) {
      print("❌ Image capture failed: $e");
      return null;
    }
  }

  // Dispose camera
  static void disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    _isInitialized = false;
  }

  // Get camera controller for preview (if needed)
  static CameraController? get cameraController => _cameraController;
  static bool get isInitialized => _isInitialized;
}