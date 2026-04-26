from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import io

from model_utils import predict_image

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
