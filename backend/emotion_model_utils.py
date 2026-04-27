import numpy as np
import json
import os
from PIL import Image
import tensorflow as tf

# ── Paths ────────────────────────────────────────────────────────────────────
BASE_DIR   = os.path.dirname(__file__)
MODEL_PATH = os.path.join(BASE_DIR, "models", "emotion", "final_emotion_model.keras")
LABELS_PATH = os.path.join(BASE_DIR, "models", "emotion", "class_labels.json")

# ── Image config (must match training) ───────────────────────────────────────
IMG_HEIGHT = 48
IMG_WIDTH  = 48

# ── Mood mapping: model output → Flutter route name ──────────────────────────
# Your model classes: ['Natural', 'anger', 'fear', 'joy', 'sadness', 'surprise']
# Your Flutter routes: anger, fear, happy, sad  (Natural & surprise → happy fallback)
MOOD_MAP = {
    "anger":    "anger",
    "fear":     "fear",
    "joy":      "happy",
    "sadness":  "sad",
    "Natural":  "happy",   # calm/neutral → happy activity
    "surprise": "happy",   # surprise → happy activity
}

# ── Load model once at startup ────────────────────────────────────────────────
print("Loading emotion model...")
# pylint: disable=no-member
emotion_model = tf.keras.models.load_model(MODEL_PATH)

with open(LABELS_PATH, "r") as f:
    label_data = json.load(f)
CLASS_LABELS = label_data["class_labels"]  # e.g. ['Natural','anger','fear','joy','sadness','surprise']

print(f"Emotion model loaded. Classes: {CLASS_LABELS}")


def preprocess_image(image: Image.Image) -> np.ndarray:
    """Resize, convert to RGB, normalise → (1, 48, 48, 3)."""
    image = image.convert("RGB")
    image = image.resize((IMG_WIDTH, IMG_HEIGHT))
    arr   = np.array(image, dtype=np.float32) / 255.0
    return np.expand_dims(arr, axis=0)          # shape: (1, 48, 48, 3)


def predict_emotion(image: Image.Image) -> dict:
    """
    Returns:
        {
          "raw_emotion": "joy",          # model's top class
          "flutter_mood": "happy",       # mapped Flutter route key
          "confidence": 0.87,
          "all_scores": {"anger": 0.02, "fear": 0.01, ...}
        }
    """
    arr         = preprocess_image(image)
    predictions = emotion_model.predict(arr, verbose=0)[0]   # shape: (6,)

    top_idx      = int(np.argmax(predictions))
    raw_emotion  = CLASS_LABELS[top_idx]
    confidence   = float(predictions[top_idx])
    flutter_mood = MOOD_MAP.get(raw_emotion, "happy")

    all_scores = {CLASS_LABELS[i]: float(predictions[i]) for i in range(len(CLASS_LABELS))}

    return {
        "raw_emotion":  raw_emotion,
        "flutter_mood": flutter_mood,
        "confidence":   round(confidence, 4),
        "all_scores":   all_scores,
    }
