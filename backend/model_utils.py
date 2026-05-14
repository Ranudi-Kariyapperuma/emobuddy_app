"""
model_utils.py
Module 1: Category Classifier (Coloring / Drawing / Handwriting)
             + CNN ASD detector
             + XGBoost ASD detector
"""

import numpy as np
import joblib
import pickle
from pathlib import Path
from PIL import Image
# pylint: disable=no-member
import tensorflow as tf

# ── paths ──────────────────────────────────────────────────────────────────────
BASE = Path(__file__).parent / "models"

CATEGORY_CLASSIFIER_PATH  = BASE / "category_classifier.keras"
CATEGORY_LABEL_ENC_PATH   = BASE / "category_label_encoder.pkl"
CNN_MODEL_PATH             = BASE / "cnn_model_final.keras"
CNN_FEATURE_EXTRACTOR_PATH = BASE / "cnn_feature_extractor.keras"
XGBOOST_MODEL_PATH         = BASE / "xgboost_model.pkl"

# ── image settings ─────────────────────────────────────────────────────────────
IMG_SIZE = (224, 224)   # matches MobileNetV2 input

# ── lazy-loaded model cache ────────────────────────────────────────────────────
_cache: dict = {}


def _load_models() -> None:
    """Load all Module-1 models into _cache (called once on first use)."""
    if _cache:
        return

    print("[model_utils] Loading category classifier …")
    _cache["category_model"] = tf.keras.models.load_model(CATEGORY_CLASSIFIER_PATH)

    print("[model_utils] Loading category label encoder …")
    with open(CATEGORY_LABEL_ENC_PATH, "rb") as f:
        import joblib
        _cache["label_encoder"] = joblib.load(f)

    print("[model_utils] Loading CNN ASD model …")
    _cache["cnn_model"] = tf.keras.models.load_model(CNN_MODEL_PATH)

    print("[model_utils] Loading CNN feature extractor …")
    _cache["cnn_feature_extractor"] = tf.keras.models.load_model(CNN_FEATURE_EXTRACTOR_PATH)

    print("[model_utils] Loading XGBoost model …")
    _cache["xgboost_model"] = joblib.load(XGBOOST_MODEL_PATH)

    print("[model_utils] All Module-1 models loaded ✓")


# ── helpers ────────────────────────────────────────────────────────────────────

def preprocess_image(image: Image.Image) -> np.ndarray:
    """
    Resize to IMG_SIZE, convert to RGB, normalise to [0, 1].
    Returns shape (1, H, W, 3).
    """
    image = image.convert("RGB").resize(IMG_SIZE)
    arr   = np.array(image, dtype=np.float32) / 255.0
    return np.expand_dims(arr, axis=0)          # (1, 224, 224, 3)


# ── public API ─────────────────────────────────────────────────────────────────

def classify_category(image: Image.Image) -> dict:
    """
    Run the category classifier on a PIL image.

    Returns
    -------
    {
        "predicted_label": "coloring" | "drawing" | "handwriting",
        "confidence":      float (0-100),
        "all_scores":      {"coloring": float, "drawing": float, "handwriting": float}
    }
    """
    _load_models()

    img    = preprocess_image(image)
    probs  = _cache["category_model"].predict(img, verbose=0)[0]          # shape (3,)
    le     = _cache["label_encoder"]
    labels = list(le.classes_)                                             # ordered class names

    idx             = int(np.argmax(probs))
    predicted_label = labels[idx].lower()
    confidence      = float(probs[idx]) * 100

    all_scores = {labels[i].lower(): round(float(probs[i]) * 100, 2) for i in range(len(labels))}

    return {
        "predicted_label": predicted_label,
        "confidence":      round(confidence, 2),
        "all_scores":      all_scores,
    }


def detect_asd_cnn(image: Image.Image) -> dict:
    """
    Run the CNN ASD detector.

    Returns
    -------
    {
        "asd_probability": float (0-100),
        "prediction":      "ASD" | "Non-ASD"
    }
    """
    _load_models()

    img       = preprocess_image(image)
    raw_prob  = float(_cache["cnn_model"].predict(img, verbose=0)[0][0])
    asd_prob  = round(raw_prob * 100, 2)

    return {
        "asd_probability": asd_prob,
        "prediction":      "ASD" if raw_prob >= 0.5 else "Non-ASD",
    }


def detect_asd_xgboost(image: Image.Image) -> dict:
    """
    Extract CNN features then run XGBoost ASD detector.

    Returns
    -------
    {
        "asd_probability": float (0-100),
        "prediction":      "ASD" | "Non-ASD"
    }
    """
    _load_models()

    img      = preprocess_image(image)
    features = _cache["cnn_feature_extractor"].predict(img, verbose=0)    # (1, feature_dim)
    proba    = _cache["xgboost_model"].predict_proba(features)[0]         # [P(Non-ASD), P(ASD)]

    # XGBoost classes are [0, 1]  →  index 1 = ASD
    asd_prob = round(float(proba[1]) * 100, 2)

    return {
        "asd_probability": asd_prob,
        "prediction":      "ASD" if proba[1] >= 0.5 else "Non-ASD",
    }


def run_module1(image: Image.Image, expected_category: str) -> dict:
    """
    Full Module-1 pipeline.

    Parameters
    ----------
    image             : PIL Image uploaded by the user
    expected_category : tab the user selected ("coloring"|"drawing"|"handwriting")

    Returns
    -------
    {
        "category_match":   bool,
        "expected":         str,
        "detected":         str,
        "category_confidence": float,
        "cnn":              {"asd_probability": float, "prediction": str},
        "xgboost":          {"asd_probability": float, "prediction": str},
        "module1_asd_probability": float   ← average of CNN & XGBoost
    }
    If category mismatch, only category fields are populated.
    """
    cat_result = classify_category(image)
    detected   = cat_result["predicted_label"]
    expected   = expected_category.lower().strip()
    match      = detected == expected

    base = {
        "category_match":      match,
        "expected":            expected,
        "detected":            detected,
        "category_confidence": cat_result["confidence"],
        "all_category_scores": cat_result["all_scores"],
    }

    if not match:
        base["message"] = (
            f"Image mismatch: you selected '{expected}' but the image appears to be '{detected}'. "
            f"Please upload the correct image type."
        )
        return base

    # Run ASD detectors
    cnn_result  = detect_asd_cnn(image)
    xgb_result  = detect_asd_xgboost(image)

    avg_prob = round((cnn_result["asd_probability"] + xgb_result["asd_probability"]) / 2, 2)

    base.update({
        "cnn":                     cnn_result,
        "xgboost":                 xgb_result,
        "module1_asd_probability": avg_prob,
    })
    return base
