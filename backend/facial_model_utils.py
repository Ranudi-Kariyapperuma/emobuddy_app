# pylint: disable=no-member
import tensorflow as tf
import numpy as np
import cv2

IMAGE_SIZE = 224


# =========================
# LOAD MODEL
# =========================

facial_model = tf.keras.models.load_model(
    "models/facial_asd_final.keras"
)

# =========================
# PREPROCESS
# =========================


def preprocess_face(image_path):

    image = cv2.imread(image_path)

    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    image = cv2.resize(image, (IMAGE_SIZE, IMAGE_SIZE))

    image = image / 255.0

    image = np.expand_dims(image, axis=0)

    return image


# =========================
# PREDICT ASD
# =========================


def process_facial_image(image_path):

    image = preprocess_face(image_path)

    prediction = facial_model.predict(image)[0][0]

    probability = float(prediction * 100)

    if probability >= 50:
        label = "ASD Detected"
    else:
        label = "No ASD"

    return {
        "facial_probability": round(probability, 2),
        "prediction": label
    }