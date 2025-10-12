import numpy as np
from PIL import Image
import random

# Mock emotions for testing
EMOTIONS = ["happy", "sad", "angry", "surprised", "neutral"]

def preprocess_image(image: Image.Image):
    image = image.resize((48, 48))  # Typical emotion input size
    gray = image.convert("L")  # Convert to grayscale
    arr = np.array(gray) / 255.0
    arr = arr.reshape(1, 48, 48, 1)
    return arr

def predict_emotion(image: Image.Image):
    # Placeholder random prediction for testing
    arr = preprocess_image(image)
    emotion = random.choice(EMOTIONS)
    confidence = round(random.uniform(0.6, 0.99), 2)
    return emotion, confidence
