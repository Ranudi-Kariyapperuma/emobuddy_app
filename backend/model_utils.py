import numpy as np
from PIL import Image
from keras.models import load_model
import joblib

IMG_SIZE = (128, 128)

# ── Load all models ────────────────────────────────────────────────────────────
cnn_model         = load_model("models/cnn_model_final.keras")
feature_extractor = load_model("models/cnn_feature_extractor.keras")
xgb_model         = joblib.load("models/xgboost_model.pkl")

category_model    = load_model("models/category_classifier.keras")
category_le       = joblib.load("models/category_label_encoder.pkl")
# category_le.classes_ → e.g. ['Coloring', 'Drawing', 'Handwriting']


# ── Helpers ────────────────────────────────────────────────────────────────────
def preprocess(image: Image.Image):
    """Convert a PIL image to a normalised (1, H, W, 3) numpy batch."""
    img = image.convert("RGB").resize(IMG_SIZE)
    return np.expand_dims(np.array(img) / 255.0, axis=0).astype(np.float32)


def generate_explanation(cnn_prob: float, xgb_prob: float) -> str:
    avg = (cnn_prob + xgb_prob) / 2
    if avg > 0.5:
        return (
            "Irregular strokes, repetition, and less structured patterns were "
            "detected, which are commonly associated with ASD traits."
        )
    return (
        "Balanced structure, clear shapes, and organised drawing patterns were "
        "detected, which are less associated with ASD traits."
    )


# ── Main prediction function ───────────────────────────────────────────────────
def predict_image(image: Image.Image, selected_tab: str):
    """
    Two-stage pipeline:
      Stage 1 → Category Classifier (gate)
      Stage 2 → ASD Detection (only if category matches selected_tab)

    selected_tab: one of 'Coloring', 'Drawing', 'Handwriting'
                  (case-insensitive match)
    """
    img_batch = preprocess(image)

    # ── STAGE 1: Category Classifier ──────────────────────────────────────────
    cat_probs      = category_model.predict(img_batch, verbose=0)[0]   # shape (3,)
    cat_pred_idx   = int(np.argmax(cat_probs))
    cat_pred_label = category_le.inverse_transform([cat_pred_idx])[0]  # e.g. 'Drawing'
    cat_confidence = float(cat_probs[cat_pred_idx])

    # Build a per-class confidence dict for the frontend
    category_scores = {
        label: round(float(cat_probs[i]) * 100, 1)
        for i, label in enumerate(category_le.classes_)
    }

    # ── Gate check ─────────────────────────────────────────────────────────────
    if cat_pred_label.lower() != selected_tab.lower():
        return {
            "status": "rejected",
            "reason": "category_mismatch",
            "selected_tab": selected_tab,
            "predicted_category": cat_pred_label,
            "category_confidence": round(cat_confidence * 100, 1),
            "category_scores": category_scores,
            "message": (
                f"This image looks like a '{cat_pred_label}', "
                f"but you selected the '{selected_tab}' tab. "
                f"Please upload a {selected_tab} image."
            ),
            # ASD fields are null — frontend should show the rejection message
            "final_prediction": None,
            "confidence": None,
            "cnn_prediction": None,
            "cnn_confidence": None,
            "xgb_prediction": None,
            "xgb_confidence": None,
            "explanation": None,
        }

    # ── STAGE 2: ASD Detection ─────────────────────────────────────────────────
    cnn_prob  = float(cnn_model.predict(img_batch, verbose=0)[0][0])
    cnn_label = "ASD" if cnn_prob > 0.5 else "Non-ASD"

    features  = feature_extractor.predict(img_batch, verbose=0)
    xgb_prob  = float(xgb_model.predict_proba(features)[0][1])
    xgb_label = "ASD" if xgb_prob > 0.5 else "Non-ASD"

    final_prob  = (cnn_prob + xgb_prob) / 2
    final_label = "ASD" if final_prob > 0.5 else "Non-ASD"

    return {
        "status": "accepted",
        "selected_tab": selected_tab,
        "predicted_category": cat_pred_label,
        "category_confidence": round(cat_confidence * 100, 1),
        "category_scores": category_scores,
        "message": "ASD detection complete.",

        "final_prediction": final_label,
        "confidence": round(final_prob * 100, 1),

        "cnn_prediction": cnn_label,
        "cnn_confidence": round(cnn_prob * 100, 1),

        "xgb_prediction": xgb_label,
        "xgb_confidence": round(xgb_prob * 100, 1),

        "explanation": generate_explanation(cnn_prob, xgb_prob),
    }
