from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import io

from model_utils import predict_image

app = FastAPI(title="ASD Detection API")

# allow Flutter access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def home():
    return {"message": "ASD Detection API running 🚀"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):

    contents = await file.read()
    image = Image.open(io.BytesIO(contents))

    result = predict_image(image)

    return result