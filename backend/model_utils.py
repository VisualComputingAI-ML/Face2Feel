import numpy as np
from PIL import Image
import random

# Enhanced emotion list for better counseling
EMOTIONS = ["happy", "sad", "angry", "surprised", "neutral", "fear", "disgust"]

def preprocess_image(image: Image.Image):
    """Preprocess image for emotion detection"""
    image = image.resize((48, 48))
    gray = image.convert("L")
    arr = np.array(gray) / 255.0
    arr = arr.reshape(1, 48, 48, 1)
    return arr

def predict_emotion(image: Image.Image):
    """Predict emotion from image (currently mock implementation)"""
    arr = preprocess_image(image)
    emotion = random.choice(EMOTIONS)
    confidence = round(random.uniform(0.6, 0.99), 2)
    return emotion, confidence