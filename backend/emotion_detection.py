import cv2
import numpy as np
from skimage.feature import hog
from skimage import data, exposure
from sklearn import svm
import os
os.environ["QT_QPA_PLATFORM"] = "xcb"

print(os.path.dirname(__file__))
face_detection_weights_path = os.path.join(os.path.dirname(__file__), "face_config/haarcascade_frontalface_default.xml")
eye_detection_weights_path = os.path.join(os.path.dirname(__file__), "face_config/haarcascade_eye_tree_eyeglasses.xml")

face_cascade = cv2.CascadeClassifier(face_detection_weights_path)
eye_cascade = cv2.CascadeClassifier(eye_detection_weights_path)


cap = cv2.VideoCapture(0)
while cap.isOpened():
    ret, frame = cap.read()

    flipped = cv2.flip(frame, 1)

    flipped_gray = cv2.cvtColor(flipped, cv2.COLOR_BGR2GRAY)


    # Viola-Jones Face Detection
    faces = face_cascade.detectMultiScale(flipped_gray, scaleFactor=1.1, 
                                          minNeighbors=5, minSize=(60, 60),
                                          flags=cv2.CASCADE_SCALE_IMAGE)
        

    for (x,y,w,h) in faces:
        cv2.rectangle(flipped, (x,y), (x+w, y+h), (0,255,0), 2)
        eyes = eye_cascade.detectMultiScale(flipped[y:y+h, x:x+w])
        for (x2,y2,w2,h2) in eyes:
            eye_center = (x + x2 + w2 // 2, y + y2 + h2 // 2)
            radius = int(round((w2 + h2) * 0.25))
            frame = cv2.circle(flipped, eye_center, radius, (255, 0, 0), 4)
            
    
    combined = flipped.copy()
    for (x,y,w,h) in faces:
        # HOG Feature Creation
        cropped = flipped_gray[y:y+h, x:x+w]
        fd, hog_image = hog(cropped, orientations=8, pixels_per_cell=(10,10),
                            cells_per_block=(1,1), visualize=True)
        hog_image_rescaled = exposure.rescale_intensity(hog_image, in_range=(0,10))

        # Overlay HOG on the face region
        addon = np.stack((hog_image_rescaled,)*3, axis=-1)
        addon = (addon*255).astype(np.uint8)
        addon_padded = np.zeros_like(flipped)
        addon_padded[y:y+h, x:x+w] = addon
        combined = cv2.add(combined, addon_padded)

    cv2.imshow("Processed Video", combined)
    if cv2.waitKey(10) & 0xFF == ord('q'):
        break
    
cap.release()
cv2.destroyAllWindows()