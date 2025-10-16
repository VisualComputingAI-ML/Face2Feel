import numpy as np
from PIL import Image
import random
import cv2
import threading
import tensorflow as tf
import time

import os
os.environ["QT_QPA_PLATFORM"] = "xcb"

# Enhanced emotion list for better counseling
EMOTIONS = ["happy", "sad", "angry", "surprised", "neutral", "fear", "disgust"]

face_detection_weights_path = os.path.join(os.path.dirname(__file__), "data", "haarcascade_frontalface_default.xml")
face_cascade = cv2.CascadeClassifier(face_detection_weights_path)

model_path = os.path.join(os.path.dirname(__file__), "data", "model_fer.keras")
emotion_model = tf.keras.models.load_model(model_path)
emotion_model.summary()

def preprocess_image(image: Image.Image):
    """Preprocess image for emotion detection"""
    image = image.resize((96, 96))
    gray = image.convert("L")
    arr = np.array(gray) / 255.0
    arr = arr.reshape(1, 96, 96, 1)
    return arr

def predict_emotion(image: Image.Image):
    """Predict emotion from image (currently mock implementation)"""
    arr = preprocess_image(image)
    emotion = random.choice(EMOTIONS)
    confidence = round(random.uniform(0.6, 0.99), 2)
    print(f"Emotion Detected: {emotion}")    
    return emotion, confidence

cap = cv2.VideoCapture(0)
while cap.isOpened():

    ret, frame = cap.read()
    frame = cv2.flip(frame, 1)

    grayscale = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    faces = face_cascade.detectMultiScale(grayscale, scaleFactor=1.1, 
                                          minNeighbors=5, minSize=(60, 60),
                                          flags=cv2.CASCADE_SCALE_IMAGE)

    face = np.ones((96, 96, 1))
    for (x,y,w,h) in faces:
        cv2.rectangle(frame, (x,y), (x+w, y+h), (0,255,0), 2)
        face = grayscale[y:y+h, x:x+w]
    
    face_img = Image.fromarray(face)
    thread = threading.Thread(target=predict_emotion, args=(face_img,))
    thread.start()
    time.sleep(3)

    cv2.imshow("MediaPipe Feed", frame)
    if cv2.waitKey(10) & 0xFF == ord('q'):
        break
    
cap.release()
cv2.destroyAllWindows()