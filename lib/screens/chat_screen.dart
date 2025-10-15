import 'package:face2feel/services/api_services.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/chat_service.dart';
import '../services/camera_service.dart';
import '../models/emotion_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _isCameraActive = false;
  String _currentEmotion = "neutral";
  double _currentConfidence = 0.0;
  Timer? _emotionDetectionTimer;
  int _detectionCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeRealTimeDetection();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _emotionDetectionTimer?.cancel();
    CameraService.disposeCamera();
    super.dispose();
  }

  Future<void> _initializeRealTimeDetection() async {
    try {
      setState(() => _isCameraActive = true);
      await CameraService.initializeCamera();
      
      // Start periodic emotion detection every 10 seconds
      _emotionDetectionTimer = Timer.periodic(Duration(seconds: 10), (timer) {
        _detectCurrentEmotion();
      });
    } catch (e) {
      print("❌ Camera initialization failed: $e");
      setState(() => _isCameraActive = false);
    }
  }

  Future<void> _detectCurrentEmotion() async {
    if (!_isCameraActive) return;

    try {
      final image = await CameraService.captureImage();
      if (image != null) {
        final result = await ApiService.uploadImage(image);
        
        setState(() {
          _currentEmotion = result['emotion'] ?? 'neutral';
          _currentConfidence = (result['confidence'] ?? 0.0).toDouble();
          _detectionCount++;
        });

        print("🎭 Real-time emotion detected: $_currentEmotion (confidence: $_currentConfidence)");
        
        // If emotion changes significantly, we could trigger special responses
        _handleEmotionChange();
      }
    } catch (e) {
      print("❌ Emotion detection failed: $e");
    }
  }

  void _handleEmotionChange() {
    // You can add logic here to handle significant emotion changes
    // For example, if emotion becomes very sad, the counselor could check in
    if (_currentEmotion == 'sad' && _currentConfidence > 0.8) {
      // Don't interrupt if user is typing or recently sent a message
      if (!_isLoading && _messages.isNotEmpty && _messages.last.isUser) {
        _addEmpatheticCheckIn();
      }
    }
  }

  void _addEmpatheticCheckIn() {
    final checkInMessages = {
      'sad': "I notice you might be feeling down. I'm here for you. Would you like to talk about what's bothering you?",
      'angry': "I sense some frustration. It's okay to feel this way. Would you like to discuss what's upsetting you?",
      'fear': "I notice you might be feeling anxious. Remember, you're safe here. Would you like to talk about what's worrying you?",
    };

    final message = checkInMessages[_currentEmotion];
    if (message != null && !_isRecentCheckIn()) {
      setState(() {
        _messages.add(ChatMessage(
          message: message,
          isUser: false,
          emotion: _currentEmotion,
          timestamp: DateTime.now(),
          isSystemCheckIn: true,
        ));
      });
      _scrollToBottom();
    }
  }

  bool _isRecentCheckIn() {
    if (_messages.isEmpty) return false;
    final lastMessage = _messages.last;
    return !lastMessage.isUser && lastMessage.isSystemCheckIn == true;
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        message: "Hello! I'm your emotional support companion. "
            "I'll be here to listen and support you. "
            "I can detect your emotions through the camera to provide better support. "
            "How are you feeling today?",
        isUser: false,
        emotion: "neutral",
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
  final message = _messageController.text.trim();
  if (message.isEmpty || _isLoading) return;

  // Add user message
  setState(() {
    _messages.add(ChatMessage(
      message: message,
      isUser: true,
      emotion: _currentEmotion,
      timestamp: DateTime.now(),
    ));
  });

  _messageController.clear();
  setState(() => _isLoading = true);
  _scrollToBottom();

  try {
    print("🔄 Sending message to counselor...");
    
    // Use current emotion for context-aware responses
    final response = await ChatService.sendMessage(_currentEmotion, message);
    
    print("✅ Counselor response received");
    
    setState(() {
      _messages.add(ChatMessage(
        message: response,
        isUser: false,
        emotion: _currentEmotion,
        timestamp: DateTime.now(),
      ));
    });
  } catch (e) {
    print("❌ Error in _sendMessage: $e");
    
    // More specific error messages
    String errorMessage;
    if (e.toString().contains('Connection timed out')) {
      errorMessage = "I'm having trouble connecting right now. Please check your internet connection and try again.";
    } else if (e.toString().contains('404') || e.toString().contains('500')) {
      errorMessage = "The counseling service is temporarily unavailable. Please try again in a moment.";
    } else {
      errorMessage = "I'm here to listen, but I'm having technical difficulties. Please try sending your message again.";
    }
    
    setState(() {
      _messages.add(ChatMessage(
        message: errorMessage,
        isUser: false,
        emotion: _currentEmotion,
        timestamp: DateTime.now(),
      ));
    });
  } finally {
    setState(() => _isLoading = false);
    _scrollToBottom();
  }
}

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Emotional Support"),
            Row(
              children: [
                _buildEmotionIndicator(),
                SizedBox(width: 8),
                Text(
                  "Detected: $_currentEmotion",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: _getEmotionColor(_currentEmotion),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isCameraActive ? Icons.videocam : Icons.videocam_off),
            onPressed: () {
              setState(() => _isCameraActive = !_isCameraActive);
            },
            tooltip: _isCameraActive ? "Real-time detection active" : "Detection paused",
          ),
        ],
      ),
      body: Column(
        children: [
          // Detection status bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Icon(
                  _isCameraActive ? Icons.check_circle : Icons.pause_circle,
                  size: 16,
                  color: _isCameraActive ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  _isCameraActive 
                    ? "Real-time emotion detection active" 
                    : "Detection paused",
                  style: TextStyle(fontSize: 12),
                ),
                Spacer(),
                Text(
                  "Detections: $_detectionCount",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Typing indicator
          if (_isLoading)
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.psychology, size: 16, color: Colors.grey),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Counselor is thinking...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Message input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Share how you're feeling...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _getEmotionColor(_currentEmotion),
                  foregroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionIndicator() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getEmotionColor(_currentEmotion),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isSystemCheckIn = message.isSystemCheckIn == true;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isSystemCheckIn 
                  ? Colors.orange 
                  : _getEmotionColor(message.emotion),
              child: Icon(
                isSystemCheckIn ? Icons.visibility : Icons.psychology, 
                size: 16, 
                color: Colors.white
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? _getEmotionColor(_currentEmotion)
                    : (isSystemCheckIn ? Colors.orange.shade50 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(16),
                border: isSystemCheckIn 
                    ? Border.all(color: Colors.orange.shade200)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (isSystemCheckIn) ...[
                    SizedBox(height: 4),
                    Text(
                      "Based on your current emotional state",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: _getEmotionColor(_currentEmotion),
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
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
        return Colors.blueAccent;
    }
  }
}