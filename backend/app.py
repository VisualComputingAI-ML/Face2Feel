from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from model_utils import predict_emotion
from chat_bot import get_counseling_response
from PIL import Image
import io
import uvicorn
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI(title="Face2Feel Emotional Counseling API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"message": "Face2Feel Emotional Counseling API is running"}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        print(f"🎯 Received prediction request for file: {file.filename}")
        
        # Read and validate image
        image_data = await file.read()
        
        if len(image_data) == 0:
            return {"error": "Empty file received"}
            
        image = Image.open(io.BytesIO(image_data)).convert("RGB")
        print(f"🖼️ Image processed: {image.size}")
        
        # Predict emotion
        emotion, confidence = predict_emotion(image)
        
        print(f"✅ Emotion detected: {emotion} (confidence: {confidence})")
        
        return {
            "emotion": emotion, 
            "confidence": confidence,
            "status": "success"
        }
        
    except Exception as e:
        print(f"💥 Error in /predict: {str(e)}")
        return {"error": str(e)}

@app.post("/chat")
async def chat_with_counselor(emotion: str, message: str):
    try:
        print(f"💬 Chat request - Emotion: {emotion}, Message: {message}")
        
        if not emotion or not message:
            raise HTTPException(status_code=400, detail="Emotion and message are required")
        
        # Get counseling response based on emotion
        counselor_response = get_counseling_response(emotion, message)
        
        return {
            "emotion": emotion,
            "user_message": message,
            "counselor_response": counselor_response,
            "status": "success"
        }
        
    except Exception as e:
        print(f"💥 Error in /chat: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    host = os.getenv("SERVER_HOST", "0.0.0.0")
    port = int(os.getenv("SERVER_PORT", 8000))
    uvicorn.run(app, host=host, port=port)