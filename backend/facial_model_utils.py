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

# ── paths ──────────────────────────────────────────────────────────────────────
BASE = Path(__file__).parent / "models"

FACIAL_MODEL_PATH     = BASE / "facial_asd_final.keras"
FACIAL_METADATA_PATH  = BASE / "facial_asd_metadata.pkl"

# ── image settings ─────────────────────────────────────────────────────────────
IMG_SIZE = (224, 224)          # MobileNetV2 input size

# ── lazy-loaded model cache ────────────────────────────────────────────────────
_cache: dict = {}


def _load_models() -> None:
    """Load facial model and metadata into _cache (called once on first use)."""
    if _cache:
        return

    print("[facial_model_utils] Loading facial ASD model …")
    _cache["facial_model"] = tf.keras.models.load_model(FACIAL_MODEL_PATH)

    print("[facial_model_utils] Loading facial metadata …")
    with open(FACIAL_METADATA_PATH, "rb") as f:
        _cache["metadata"] = pickle.load(f)

    # Best threshold stored in metadata, default 0.5
    _cache["threshold"] = _cache["metadata"].get("best_threshold", 0.5)

    print(f"[facial_model_utils] Facial model loaded ✓  (threshold={_cache['threshold']})")


# ── helpers ────────────────────────────────────────────────────────────────────

def preprocess_face(image: Image.Image) -> np.ndarray:
    """
    Resize to IMG_SIZE, convert to RGB, normalise to [0, 1].
    Returns shape (1, H, W, 3).
    """
    image = image.convert("RGB").resize(IMG_SIZE)
    arr   = np.array(image, dtype=np.float32) / 255.0
    return np.expand_dims(arr, axis=0)          # (1, 224, 224, 3)


# ── public API ─────────────────────────────────────────────────────────────────

def detect_asd_facial(image: Image.Image) -> dict:
    """
    Run the facial ASD model on a PIL face image.

    Returns
    -------
    {
        "asd_probability":  float (0-100),
        "prediction":       "ASD" | "Non-ASD",
        "threshold_used":   float,
        "confidence_label": str   e.g. "High confidence – ASD detected"
    }
    """
    _load_models()

    img       = preprocess_face(image)
    raw_prob  = float(_cache["facial_model"].predict(img, verbose=0)[0][0])
    threshold = _cache["threshold"]

    asd_prob   = round(raw_prob * 100, 2)
    prediction = "ASD" if raw_prob >= threshold else "Non-ASD"

    # Human-readable confidence label
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
    """
    Full Module-2 pipeline (single entry-point used by main.py).

    Returns the same dict as detect_asd_facial() with an extra key
    'module2_asd_probability' for the combiner.
    """
    result = detect_asd_facial(image)
    result["module2_asd_probability"] = result["asd_probability"]
    return result
