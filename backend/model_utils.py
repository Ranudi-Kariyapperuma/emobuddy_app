# pylint: disable=no-member
import tensorflow as tf
import numpy as np
import cv2
import pickle
import joblib

IMAGE_SIZE = 224


# =========================
# LOAD MODELS
# =========================

category_model = tf.keras.models.load_model(
    "models/category_classifier.keras"
)

cnn_model = tf.keras.models.load_model(
    "models/cnn_model_final.keras"
)

feature_extractor = tf.keras.models.load_model(
    "models/cnn_feature_extractor.keras"
)

xgb_model = joblib.load(
    "models/xgboost_model.pkl"
)

with open("models/category_label_encoder.pkl", "rb") as f:
    label_encoder = pickle.load(f)


# =========================
# PREPROCESS IMAGE
# =========================


def preprocess_image(image_path):

    image = cv2.imread(image_path)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    image = cv2.resize(image, (IMAGE_SIZE, IMAGE_SIZE))

    image = image / 255.0

    image = np.expand_dims(image, axis=0)

    return image


# =========================
# CATEGORY CLASSIFIER
# =========================


def classify_category(image_path):

    image = preprocess_image(image_path)

    prediction = category_model.predict(image)

    predicted_index = np.argmax(prediction)

    predicted_label = label_encoder.inverse_transform(
        [predicted_index]
    )[0]

    confidence = float(np.max(prediction)) * 100

    return predicted_label, confidence


# =========================
# ASD PREDICTION
# =========================


def predict_asd(image_path):

    image = preprocess_image(image_path)

    # CNN Prediction
    cnn_prediction = cnn_model.predict(image)[0][0]

    cnn_percentage = float(cnn_prediction * 100)

    # Feature Extraction
    features = feature_extractor.predict(image)

    features = features.flatten().reshape(1, -1)

    # XGBoost Prediction
    xgb_prediction = xgb_model.predict_proba(features)[0][1]

    xgb_percentage = float(xgb_prediction * 100)
    
    overall_percentage = (cnn_percentage + xgb_percentage) / 2

    if overall_percentage >= 50:
        label = "ASD Detected"
    else:
        label = "No ASD"

    return {
        "cnn_percentage": round(cnn_percentage, 2),
        "xgb_percentage": round(xgb_percentage, 2),
        "overall_percentage": round(overall_percentage, 2),
        "prediction": label
    }

# =========================
# FULL PIPELINE
# =========================


def process_activity_image(image_path, selected_category):

    predicted_category, confidence = classify_category(image_path)

    if predicted_category.lower() != selected_category.lower():

        return {
            "status": "mismatch",
            "message": f"Uploaded image belongs to {predicted_category}",
            "predicted_category": predicted_category,
            "confidence": round(confidence, 2)
        }
        
        
    asd_result = predict_asd(image_path)

    return {
        "status": "success",
        "selected_category": selected_category,
        "predicted_category": predicted_category,
        "category_confidence": round(confidence, 2),
        "asd_result": asd_result
    }