class EmotionData {
  final String emotion;
  final double confidence;
  final DateTime timestamp;

  EmotionData({
    required this.emotion,
    required this.confidence,
    required this.timestamp,
  });

  factory EmotionData.fromJson(Map<String, dynamic> json) {
    return EmotionData(
      emotion: json['emotion'],
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.now(),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final String emotion;
  final DateTime timestamp;
  final bool? isSystemCheckIn; // NEW: For system-generated emotional check-ins

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.emotion,
    required this.timestamp,
    this.isSystemCheckIn = false,
  });
}