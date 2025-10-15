import openai
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize OpenAI with new API format
client = openai.OpenAI(api_key=os.getenv("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"))

def get_counseling_response(emotion: str, user_message: str) -> str:
    """
    Get empathetic counseling response based on detected emotion
    """
    
    # Emotion-specific counseling prompts
    emotion_prompts = {
        "happy": "The user is feeling happy and positive. Acknowledge their happiness and encourage them to savor this moment. Be warm and celebratory.",
        "sad": "The user is feeling sad. Offer comfort, validation, and gentle support. Help them feel understood and not alone. Ask thoughtful questions.",
        "angry": "The user is feeling angry. Help them process their feelings without judgment. Offer calming techniques and validation.",
        "surprised": "The user is feeling surprised. Be curious about what surprised them and help them process this unexpected event.",
        "neutral": "The user is feeling neutral. Be gently engaging and create space for them to explore what's on their mind.",
        "fear": "The user is feeling fearful or anxious. Offer reassurance and help them feel safe. Provide grounding techniques.",
        "disgust": "The user is feeling disgusted. Validate their feelings and help them process what's causing this reaction."
    }
    
    # System prompt for the counselor
    system_prompt = f"""You are a compassionate, empathetic AI counselor. The user has been detected as feeling {emotion}.

{emotion_prompts.get(emotion, "Be warm, empathetic, and supportive.")}

Guidelines:
- Be warm, validating, and non-judgmental
- Use empathetic listening techniques
- Ask open-ended questions to encourage reflection
- Provide supportive responses, not clinical advice
- Keep responses conversational and natural (2-4 sentences)
- Focus on emotional support and validation
- Respond directly to what the user said
- Don't be too formal or clinical"""

    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message}
            ],
            max_tokens=150,
            temperature=0.8
        )
        
        return response.choices[0].message.content.strip()
        
    except Exception as e:
        print(f"❌ OpenAI API error: {e}")
        # Better fallback responses
        fallback_responses = {
            "happy": "I'm really glad to see you're feeling positive! What's been bringing you joy lately? I'd love to hear more about what's making you happy.",
            "sad": "I hear that you're going through a difficult time. It takes courage to share these feelings. I'm here to listen and support you without judgment.",
            "angry": "It sounds like you're dealing with some strong emotions right now. That's completely understandable. Would you like to talk about what's triggering these feelings?",
            "surprised": "That sounds like it was quite unexpected! How are you processing this surprise? I'm here to help you make sense of it.",
            "neutral": "Thank you for sharing. Sometimes neutral moments can be opportunities for reflection. What's on your mind right now?",
            "fear": "I can sense some anxiety in your words. Remember, you're in a safe space here. Would you like to explore what's causing these worries together?",
            "disgust": "That sounds like a strong reaction. I'm here to listen without judgment if you'd like to share what's causing these feelings."
        }
        return fallback_responses.get(emotion, "Thank you for sharing that with me. I'm here to listen and support you. Could you tell me a bit more about what you're experiencing?")
