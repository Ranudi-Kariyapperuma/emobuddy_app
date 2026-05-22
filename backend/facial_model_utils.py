"""
facial_model_utils.py
Module 2: Facial ASD Detection using MobileNetV2
"""

import numpy as np
import pickle
from pathlib import Path
from PIL import Image
# pylint: disable=no-member
import tensorflow as tf
from keras.applications.mobilenet_v2 import preprocess_input

# ── paths ──────────────────────────────────────────────────────────────────────
BASE = Path(__file__).parent / "models"

FACIAL_MODEL_PATH     = BASE / "facial_asd_final.keras"
FACIAL_METADATA_PATH  = BASE / "facial_asd_metadata.pkl"

# ── image settings ─────────────────────────────────────────────────────────────
IMG_SIZE = (224, 224)

# ── lazy-loaded model cache ────────────────────────────────────────────────────
_cache: dict = {}


def _load_models() -> None:
    if _cache:
        return

    print("[facial_model_utils] Loading facial ASD model …")
    _cache["facial_model"] = tf.keras.models.load_model(FACIAL_MODEL_PATH)

    print("[facial_model_utils] Loading facial metadata …")
    with open(FACIAL_METADATA_PATH, "rb") as f:
        _cache["metadata"] = pickle.load(f)

    _cache["threshold"] = _cache["metadata"].get("threshold", 0.65)
    print(f"[facial_model_utils] Facial model loaded ✓  (threshold={_cache['threshold']})")


def preprocess_face(image: Image.Image) -> np.ndarray:
    image = image.convert("RGB").resize(IMG_SIZE)
    arr   = np.array(image, dtype=np.float32)
    arr   = preprocess_input(arr)          # ✅ scales to [-1, 1] like training
    return np.expand_dims(arr, axis=0)


def detect_asd_facial(image: Image.Image) -> dict:
    _load_models()

    img       = preprocess_face(image)
    raw_prob  = float(_cache["facial_model"].predict(img, verbose=0)[0][0])
    threshold = _cache["threshold"]

    # raw_prob = P(non_autistic) because non_autistic=1
    # so flip it to get P(autistic)
    asd_prob   = round((1 - raw_prob) * 100, 2)
    prediction = "ASD" if raw_prob < threshold else "Non-ASD"

    print(f"[DEBUG] raw_prob={raw_prob:.4f}  asd_prob={asd_prob}%  prediction={prediction}")

    if prediction == "ASD":
        if asd_prob >= 80:
            label = "High confidence – ASD detected"
        elif asd_prob >= 65:
            label = "Moderate confidence – ASD likely"
        else:
            label = "Low confidence – possible ASD"
    else:
        non_asd_pct = round(100 - asd_prob, 2)
        if non_asd_pct >= 80:
            label = "High confidence – No ASD detected"
        elif non_asd_pct >= 65:
            label = "Moderate confidence – ASD unlikely"
        else:
            label = "Low confidence – borderline result"

    return {
        "asd_probability":  asd_prob,
        "prediction":       prediction,
        "threshold_used":   threshold,
        "confidence_label": label,
    }


def run_module2(image: Image.Image) -> dict:
    result = detect_asd_facial(image)
    result["module2_asd_probability"] = result["asd_probability"]
    return result