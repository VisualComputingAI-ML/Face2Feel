"""
Real-time Emotion Recognition Testing Script
Uses trained model for webcam-based emotion detection with face alignment
"""

import os
os.environ["QT_QPA_PLATFORM"] = "xcb"
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"

import cv2
import numpy as np
import torch
import timm
import torch.nn.functional as F
from torchvision import transforms
from PIL import Image
import mediapipe as mp

# ============================================================================
# CONFIGURATION
# ============================================================================

IMG_SIZE = 128
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
# MODEL_PATH = os.path.join(SCRIPT_DIR, 'outputs', 'run_20251114_194342',"best_model.pth")
MODEL_PATH = os.path.join(SCRIPT_DIR, "bestest_vit_fer.pth")  


# Emotion labels (must match training order)
EMOTION_LABELS = ['Anger', 'Disgust', 'Fear', 'Happy', 'Neutral', 'Sad', 'Surprise']

# ============================================================================
# CHECK REQUIRED FILES
# ============================================================================

if not os.path.exists(MODEL_PATH):
    print(f"❌ Missing model file: {MODEL_PATH}")
    print("Please update MODEL_PATH to point to your trained model (e.g., best_model.pth)")
    exit(1)

print("Model file found")

# ============================================================================
# INITIALIZE MEDIAPIPE
# ============================================================================

print("Initializing MediaPipe...")

mp_face_detection = mp.solutions.face_detection
face_detection = mp_face_detection.FaceDetection(
    model_selection=0,
    min_detection_confidence=0.5
)

mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(
    static_image_mode=False,
    max_num_faces=1,
    refine_landmarks=True,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5
)

print("✓ MediaPipe Face Detection + Face Mesh initialized")

# ============================================================================
# FACE ALIGNMENT FUNCTION
# ============================================================================

def align_face_mediapipe(img):
    """
    Face alignment using MediaPipe landmarks
    - Rotates face to align eyes horizontally
    - Crops face region based on landmarks
    - Resizes to model input size
    """
    # Convert to RGB if needed
    if len(img.shape) == 3:
        rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    else:
        rgb = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)
    
    # Detect face landmarks
    results = face_mesh.process(rgb)
    
    if not results.multi_face_landmarks:
        return None
    
    h, w = img.shape[:2]
    landmarks = results.multi_face_landmarks[0]
    
    # Convert normalized landmarks to pixel coordinates
    points = np.array([[lm.x * w, lm.y * h] for lm in landmarks.landmark])
    
    # Get eye centers (using MediaPipe landmark indices)
    left_eye_indices = [33, 133, 145, 153, 154, 155, 157, 158, 159, 160, 161, 163]
    right_eye_indices = [263, 362, 373, 380, 381, 382, 384, 385, 386, 387, 388, 390]
    
    left_eye = points[left_eye_indices].mean(axis=0)
    right_eye = points[right_eye_indices].mean(axis=0)
    
    # Calculate rotation angle to align eyes horizontally
    dY = right_eye[1] - left_eye[1]
    dX = right_eye[0] - left_eye[0]
    angle = np.degrees(np.arctan2(dY, dX))
    
    # Calculate eye center for rotation
    eye_center = (float((left_eye[0] + right_eye[0]) / 2), 
                  float((left_eye[1] + right_eye[1]) / 2))
    
    # Get rotation matrix
    M = cv2.getRotationMatrix2D(eye_center, angle, 1.0)
    
    # Rotate image
    rotated = cv2.warpAffine(img, M, (w, h), flags=cv2.INTER_CUBIC)
    
    # Rotate landmarks
    ones = np.ones(shape=(len(points), 1))
    points_ones = np.hstack([points, ones])
    rotated_points = M.dot(points_ones.T).T
    
    # Get face boundaries using key landmarks
    left_face = int(rotated_points[234][0])    # Left side of face
    right_face = int(rotated_points[454][0])   # Right side of face
    chin = int(rotated_points[152][1])         # Bottom (chin)
    
    # Calculate top boundary based on eye position
    eye_center_rotated = M.dot([eye_center[0], eye_center[1], 1])
    face_height = chin - eye_center_rotated[1]
    top = int(eye_center_rotated[1] - face_height * 0.5)
    
    # Ensure boundaries are within image
    top = max(0, top)
    left_face = max(0, left_face)
    chin = min(h, chin)
    right_face = min(w, right_face)
    
    # Crop face region
    if right_face > left_face and chin > top:
        cropped = rotated[top:chin, left_face:right_face]
        # Resize to model input size
        aligned = cv2.resize(cropped, (IMG_SIZE, IMG_SIZE))
        return aligned
    
    return None

# ============================================================================
# CLAHE ENHANCEMENT
# ============================================================================

def enhance_low_light(face_img):
    """Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)"""
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    return clahe.apply(face_img)

# ============================================================================
# LOAD MODEL
# ============================================================================

print("\nLoading emotion recognition model...")

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {device}")

# Create model architecture (must match training)
model = timm.create_model(
    "vit_small_patch16_224",
    pretrained=False,
    img_size=IMG_SIZE,
    in_chans=1,  # Grayscale input
    num_classes=len(EMOTION_LABELS)
)

# Load trained weights
model.load_state_dict(torch.load(MODEL_PATH, map_location=device))
model.eval().to(device)
print("Model loaded successfully")

# ============================================================================
# IMAGE PREPROCESSING
# ============================================================================

# Transforms must match training preprocessing
transform = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.5], std=[0.5])  # Match training normalization
])

# ============================================================================
# MAIN INFERENCE LOOP
# ============================================================================

print("\n" + "="*70)
print("STARTING REAL-TIME EMOTION RECOGNITION")
print("="*70)
print("Press 'q' to quit")
print("="*70 + "\n")

# Start webcam capture
cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("Error: Could not open webcam")
    exit(1)

print("Webcam started successfully")

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        print("❌ Failed to capture frame")
        break

    # Flip frame horizontally for mirror effect
    flipped = cv2.flip(frame, 1)
    
    # Convert to RGB for MediaPipe
    rgb_frame = cv2.cvtColor(flipped, cv2.COLOR_BGR2RGB)
    
    # Detect faces
    results = face_detection.process(rgb_frame)

    # Placeholder for aligned face display
    aligned_face_display = np.ones((IMG_SIZE, IMG_SIZE, 3), dtype=np.uint8) * 255  # White
    
    # Process detections
    if results.detections:
        height, width, _ = flipped.shape
        
        for detection in results.detections:
            # Get bounding box
            bboxC = detection.location_data.relative_bounding_box
            x = int(bboxC.xmin * width)
            y = int(bboxC.ymin * height)
            w = int(bboxC.width * width)
            h = int(bboxC.height * height)
            
            # Ensure box is within frame
            x, y = max(0, x), max(0, y)
            w, h = min(w, width - x), min(h, height - y)

            if w > 0 and h > 0:
                # Extract face ROI
                face_roi = flipped[y:y + h, x:x + w]
                
                # Align face
                aligned_color = align_face_mediapipe(face_roi)
                
                if aligned_color is not None:
                    # Update display
                    aligned_face_display = aligned_color
                    
                    # Convert to grayscale for model
                    aligned_gray = cv2.cvtColor(aligned_color, cv2.COLOR_BGR2GRAY)
                    
                    # Apply CLAHE enhancement
                    aligned_gray_enhanced = enhance_low_light(aligned_gray)
                    
                    # Prepare tensor for model
                    face_pil = Image.fromarray(aligned_gray_enhanced)
                    face_tensor = transform(face_pil).unsqueeze(0).to(device)
                    
                    # ========================================================
                    # EMOTION PREDICTION
                    # ========================================================
                    
                    with torch.no_grad():
                        outputs = model(face_tensor)
                        probs = F.softmax(outputs, dim=1)
                        confidence_scores, pred = torch.max(probs, 1)
                        
                        emotion = EMOTION_LABELS[pred.item()]
                        confidence = confidence_scores.item() * 100
                    
                    # ========================================================
                    # DISPLAY RESULTS
                    # ========================================================
                    
                    # Draw bounding box
                    cv2.rectangle(flipped, (x, y), (x + w, y + h), (0, 255, 0), 2)
                    
                    # Display emotion label
                    label = f"{emotion} ({confidence:.1f}%)"
                    cv2.putText(flipped, label, (x, y - 10),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
                    
                    # Display all emotion probabilities (optional)
                    y_offset = y + h + 20
                    for i, (label_name, prob) in enumerate(zip(EMOTION_LABELS, probs[0])):
                        prob_percent = prob.item() * 100
                        text = f"{label_name}: {prob_percent:.1f}%"
                        cv2.putText(flipped, text, (x, y_offset + i * 20),
                                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
                else:
                    # Alignment failed
                    aligned_face_display = np.ones((IMG_SIZE, IMG_SIZE, 3), dtype=np.uint8) * 255
                    cv2.rectangle(flipped, (x, y), (x + w, y + h), (0, 0, 255), 2)
                    cv2.putText(flipped, "Alignment Failed", (x, y - 10),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2)
    
    # ========================================================================
    # COMBINED DISPLAY
    # ========================================================================
    
    # Resize aligned face for display
    aligned_resized = cv2.resize(aligned_face_display, (height, height))
    
    # Combine webcam feed and aligned face side-by-side
    combined = np.hstack((flipped, aligned_resized))
    
    # Add title
    cv2.putText(combined, "Webcam Feed | Aligned Face", (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
    
    # Display
    cv2.imshow("Emotion Recognition + Aligned Face", combined)
    
    # Check for quit key
    if cv2.waitKey(10) & 0xFF == ord('q'):
        print("\nQuitting...")
        break

# ============================================================================
# CLEANUP
# ============================================================================

face_detection.close()
face_mesh.close()
cap.release()
cv2.destroyAllWindows()