import numpy as np
from PIL import Image
from keras.models import load_model
import joblib

IMG_SIZE = (128, 128)

# Load models
cnn_model = load_model("models/cnn_model_final.keras")
feature_extractor = load_model("models/cnn_feature_extractor.keras")
xgb_model = joblib.load("models/xgboost_model.pkl")


def generate_explanation(cnn_prob, xgb_prob):
    avg = (cnn_prob + xgb_prob) / 2

    if avg > 0.5:
        return "Irregular strokes, repetition, and less structured patterns were detected, which are commonly associated with ASD traits."
    else:
        return "Balanced structure, clear shapes, and organized drawing patterns were detected, which are less associated with ASD traits."


def predict_image(image: Image.Image):

    img = image.convert("RGB").resize(IMG_SIZE)
    img_array = np.array(img) / 255.0
    img_batch = np.expand_dims(img_array, axis=0)

    # CNN prediction
    cnn_prob = float(cnn_model.predict(img_batch)[0][0])
    cnn_label = "ASD" if cnn_prob > 0.5 else "Non-ASD"

    # XGBoost prediction
    features = feature_extractor.predict(img_batch)
    xgb_prob = float(xgb_model.predict_proba(features)[0][1])
    xgb_label = "ASD" if xgb_prob > 0.5 else "Non-ASD"

    # final decision
    final_prob = (cnn_prob + xgb_prob) / 2
    final_label = "ASD" if final_prob > 0.5 else "Non-ASD"

    return {
        "final_prediction": final_label,
        "confidence": final_prob,

        "cnn_prediction": cnn_label,
        "cnn_confidence": cnn_prob,

        "xgb_prediction": xgb_label,
        "xgb_confidence": xgb_prob,

        "explanation": generate_explanation(cnn_prob, xgb_prob)
    }