from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import io

from model_utils import predict_image                    # ASD model

from emotion_model_utils import predict_emotion          # emotion model


app = FastAPI(title="ASD Detection API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

VALID_TABS = {"Coloring", "Drawing", "Handwriting"}


@app.get("/")
def home():
    return {"message": "ASD Detection API running 🚀"}

# ASD endpoint 
@app.post("/predict")
async def predict(
    file: UploadFile = File(...),
    selected_tab: str = Form(...),   # "Coloring" | "Drawing" | "Handwriting"
):
    # Validate tab value
    if selected_tab not in VALID_TABS:
        raise HTTPException(
            status_code=422,
            detail=f"selected_tab must be one of {sorted(VALID_TABS)}. Got '{selected_tab}'.",
        )

    contents = await file.read()
    image = Image.open(io.BytesIO(contents))

    result = predict_image(image, selected_tab)
    return result

# ── NEW Emotion endpoint 

@app.post("/predict-emotion")
async def predict_emotion_route(
    file: UploadFile = File(...),
):
    """
    Accepts a face image and returns the detected mood.

    Response JSON:
    {
        "raw_emotion":  "joy",      // model class name
        "flutter_mood": "happy",    // Flutter route key
        "confidence":   0.87,
        "all_scores":   { "anger": 0.02, "fear": 0.01, ... }
    }
    """


    contents = await file.read()
    try:
        image = Image.open(io.BytesIO(contents))
    except Exception:
        raise HTTPException(status_code=400, detail="Could not read image file.")

    result = predict_emotion(image)
    return result
