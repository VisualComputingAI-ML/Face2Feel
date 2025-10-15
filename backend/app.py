# app.py - Add better error handling
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from model_utils import predict_emotion
from PIL import Image
import io
import uvicorn

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"message": "Face2Feel Emotion Detection API is running"}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        print(f"🎯 Received prediction request")
        print(f"📁 File: {file.filename}, Type: {file.content_type}")
        print(f"📊 Headers: {file.headers}")
        
        # Read the image file
        image_data = await file.read()
        print(f"📦 Image data size: {len(image_data)} bytes")
        
        if len(image_data) == 0:
            return {"error": "Empty file received"}
            
        image = Image.open(io.BytesIO(image_data)).convert("RGB")
        print(f"🖼️ Image opened successfully. Size: {image.size}, Mode: {image.mode}")
        
        # Predict emotion
        print("🤖 Calling predict_emotion...")
        emotion, confidence = predict_emotion(image)
        
        print(f"✅ Prediction complete: {emotion} (confidence: {confidence})")
        
        return {
            "emotion": emotion, 
            "confidence": confidence,
            "image_size": f"{image.size[0]}x{image.size[1]}"
        }
        
    except Exception as e:
        print(f"💥 Error in /predict: {str(e)}")
        import traceback
        print(f"🔍 Stack trace: {traceback.format_exc()}")
        return {"error": str(e)}
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)