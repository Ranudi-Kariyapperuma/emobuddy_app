from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import shutil
import os

from model_utils import process_activity_image
from facial_model_utils import process_facial_image
from combined_result import combine_results

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


@app.get("/")
def home():
    return {"message": "ASD Detection Backend Running"}


@app.post("/predict/activity")
async def predict_activity(
    category: str,
    file: UploadFile = File(...)
):

    file_path = os.path.join(UPLOAD_DIR, file.filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    result = process_activity_image(file_path, category)

    return result


@app.post("/predict/facial")
async def predict_facial(file: UploadFile = File(...)):

    file_path = os.path.join(UPLOAD_DIR, file.filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    result = process_facial_image(file_path)

    return result


@app.post("/predict/final")
async def final_prediction(
    category: str,
    activity_file: UploadFile = File(...),
    facial_file: UploadFile = File(...)
):

    activity_path = os.path.join(UPLOAD_DIR, activity_file.filename)
    facial_path = os.path.join(UPLOAD_DIR, facial_file.filename)

    with open(activity_path, "wb") as buffer:
        shutil.copyfileobj(activity_file.file, buffer)

    with open(facial_path, "wb") as buffer:
        shutil.copyfileobj(facial_file.file, buffer)

    activity_result = process_activity_image(activity_path, category)

    if activity_result["status"] == "mismatch":
        return activity_result

    facial_result = process_facial_image(facial_path)

    final_result = combine_results(activity_result, facial_result)

    return final_result
