
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from model_utils import predict_emotion
from PIL import Image
import io

app = FastAPI()

# Allow your Flutter app to connect
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
        image = Image.open(io.BytesIO(await file.read())).convert("RGB")
        emotion, confidence = predict_emotion(image)
        return {"emotion": emotion, "confidence": confidence}
    except Exception as e:
        return {"error": str(e)}
