import 'dart:convert';
import 'package:face2feel/services/api_services.dart';
import 'package:http/http.dart' as http;


class ChatService {
  static Future<String> sendMessage(String emotion, String userMessage) async {
    try {
      print("💬 Sending chat message - Emotion: $emotion, Message: $userMessage");
      
      final response = await ApiService.chatWithCounselor(emotion, userMessage);
      
      print("✅ Chat response received: ${response['counselor_response']}");
      
      return response['counselor_response'];
    } catch (e) {
      print("❌ ChatService error: $e");
      
      // Better fallback responses based on emotion
      final fallbackResponses = {
        'happy': "I'm really glad you're feeling positive! What's been bringing you joy lately?",
        'sad': "I hear you're going through a tough time. I'm here to listen and support you.",
        'angry': "It sounds like you're dealing with strong emotions. I'm here to help you process them.",
        'neutral': "Thank you for sharing. I'm here to listen whenever you're ready to talk.",
        'fear': "I sense some anxiety. Remember, this is a safe space to share your concerns.",
        'surprised': "That sounds unexpected! Would you like to talk more about what surprised you?",
        'disgust': "I'm here to listen without judgment. Would you like to share what's bothering you?"
      };
      
      return fallbackResponses[emotion] ?? 
             "I'm here to listen and support you. Could you tell me more about what you're experiencing?";
    }
  }
}