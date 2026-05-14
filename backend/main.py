"""
main.py
FastAPI backend — Multimodal ASD Detection System
"""

from __future__ import annotations

import io
from typing import Optional

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from PIL import Image

from model_utils import run_module1
from facial_model_utils import run_module2
from combined_result    import build_combined_result

# ── App ────────────────────────────────────────────────────────────────────────
app = FastAPI(
    title       = "Multimodal ASD Detection API",
    description = (
        "Detects Autism Spectrum Disorder using children's handwriting / "
        "drawing / coloring images and facial photographs."
    ),
    version = "1.0.0",
)

# ── CORS (adjust origins for production) ──────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins     = ["*"],
    allow_credentials = True,
    allow_methods     = ["*"],
    allow_headers     = ["*"],
)


# ── Utility ────────────────────────────────────────────────────────────────────

def _read_image(upload: UploadFile) -> Image.Image:
    """Read an UploadFile and return a PIL Image."""
    content = upload.file.read()
    try:
        return Image.open(io.BytesIO(content)).convert("RGB")
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Invalid image file: {exc}") from exc


# ══════════════════════════════════════════════════════════════════════════════
# ROUTES
# ══════════════════════════════════════════════════════════════════════════════

@app.get("/", tags=["Health"])
def root():
    """Health-check endpoint."""
    return {"status": "ok", "message": "ASD Detection API is running."}


@app.get("/health", tags=["Health"])
def health():
    return {"status": "healthy"}


# ── Module 1: Activity image ASD detection ────────────────────────────────────

@app.post("/predict/activity", tags=["Module 1 – Activity"])
async def predict_activity(
    file:     UploadFile = File(...,  description="Handwriting / Coloring / Drawing image"),
    category: str        = Form(...,  description="Expected category: handwriting | coloring | drawing"),
):
    """
    Upload a single activity image and a category label.

    - Classifies the image category (CNN-based classifier).
    - If category matches the selected tab → runs CNN + XGBoost ASD detection.
    - If mismatch → returns rejection message with the detected category.
    """
    allowed = {"handwriting", "coloring", "drawing"}
    cat = category.lower().strip()
    if cat not in allowed:
        raise HTTPException(
            status_code=422,
            detail=f"Invalid category '{category}'. Must be one of: {allowed}",
        )

    image  = _read_image(file)
    result = run_module1(image, cat)
    return JSONResponse(content=result)


@app.post("/predict/activity/batch", tags=["Module 1 – Activity"])
async def predict_activity_batch(
    handwriting_file: Optional[UploadFile] = File(None, description="Handwriting image (optional)"),
    coloring_file:    Optional[UploadFile] = File(None, description="Coloring image (optional)"),
    drawing_file:     Optional[UploadFile] = File(None, description="Drawing image (optional)"),
):
    """
    Upload up to three activity images (one per category) simultaneously.

    Returns individual Module-1 results for each provided image.
    Mismatch images are flagged but do not block other images.
    """
    uploads = {
        "handwriting": handwriting_file,
        "coloring":    coloring_file,
        "drawing":     drawing_file,
    }

    results = {}
    for cat, upload in uploads.items():
        if upload is None:
            continue
        image        = _read_image(upload)
        results[cat] = run_module1(image, cat)

    if not results:
        raise HTTPException(status_code=422, detail="Please upload at least one activity image.")

    return JSONResponse(content=results)


# ── Module 2: Facial ASD detection ────────────────────────────────────────────

@app.post("/predict/facial", tags=["Module 2 – Facial"])
async def predict_facial(
    file: UploadFile = File(..., description="Child's facial photograph"),
):
    """
    Upload a facial photograph.

    Returns the MobileNetV2-based ASD probability and prediction.
    """
    image  = _read_image(file)
    result = run_module2(image)
    return JSONResponse(content=result)


# ── Combined result ────────────────────────────────────────────────────────────

@app.post("/predict/combined", tags=["Combined Result"])
async def predict_combined(
    handwriting_file: Optional[UploadFile] = File(None, description="Handwriting image"),
    coloring_file:    Optional[UploadFile] = File(None, description="Coloring image"),
    drawing_file:     Optional[UploadFile] = File(None, description="Drawing image"),
    facial_file:      Optional[UploadFile] = File(None, description="Facial photograph"),
):
    """
    Full pipeline: upload any combination of activity images + facial photo.

    1. Each activity image is classified and ASD-scored (Module 1).
    2. Facial image is ASD-scored (Module 2).
    3. Results are combined using a weighted average:
       - Activity score  → 60 %
       - Facial score    → 40 %
    4. Final ASD decision + severity (Mild/Moderate/Severe) + game recommendations returned.

    **At least one image must be provided.**
    """
    # ── Module 1 ──────────────────────────────────────────────────────────────
    activity_uploads = {
        "handwriting": handwriting_file,
        "coloring":    coloring_file,
        "drawing":     drawing_file,
    }

    module1_results: list[dict] = []
    activity_details: dict      = {}

    for cat, upload in activity_uploads.items():
        if upload is None:
            continue
        image  = _read_image(upload)
        result = run_module1(image, cat)
        module1_results.append(result)
        activity_details[cat] = result

    # ── Module 2 ──────────────────────────────────────────────────────────────
    module2_result: dict | None = None
    if facial_file is not None:
        face_image     = _read_image(facial_file)
        module2_result = run_module2(face_image)

    # ── Guard: need at least one successful result ─────────────────────────────
    if not module1_results and module2_result is None:
        raise HTTPException(
            status_code=422,
            detail="Please provide at least one activity image or a facial photograph.",
        )

    # ── Combine ───────────────────────────────────────────────────────────────
    combined = build_combined_result(module1_results, module2_result)

    response = {
        "activity_details": activity_details,
        "facial_details":   module2_result,
        **combined,
    }

    return JSONResponse(content=response)


# ── Standalone category classifier (utility) ──────────────────────────────────

@app.post("/classify/category", tags=["Utilities"])
async def classify_category_only(
    file: UploadFile = File(..., description="Any activity image to classify"),
):
    """
    Classify an image as Handwriting, Coloring, or Drawing **without** running ASD detection.
    Useful for frontend tab auto-selection.
    """
    from model_utils import classify_category
    image  = _read_image(file)
    result = classify_category(image)
    return JSONResponse(content=result)


# ── Games reference ────────────────────────────────────────────────────────────

@app.get("/games", tags=["Utilities"])
def list_all_games():
    """Return the full list of recommended games grouped by ASD severity level."""
    from combined_result import GAMES
    return JSONResponse(content=GAMES)


@app.get("/games/{severity}", tags=["Utilities"])
def get_games_by_severity(severity: str):
    """
    Return recommended games for a specific severity level.

    severity must be one of: Mild | Moderate | Severe  (case-insensitive)
    """
    from combined_result import get_games, GAMES

    sev = severity.strip().capitalize()
    if sev not in GAMES:
        raise HTTPException(
            status_code=404,
            detail=f"Severity '{severity}' not found. Must be Mild, Moderate, or Severe.",
        )
    return JSONResponse(content={"severity": sev, "games": get_games(sev)})


# ── Entry point ────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
