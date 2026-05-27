<div align="center">

<img src="https://github.com/user-attachments/assets/693cfbae-e5e2-4127-827d-310bbf19f4e3" width="100%" />

<br>

# Multimodal AI-Assisted Adaptive Learning Companion for Children with Autism

<div align="center">

## EMO BUDDY APP

</div>

<img src="https://github.com/user-attachments/assets/36e3eca8-0d36-40dc-a1dc-1dc812cd7e73" width="90%" />


<br><br>

<!-- TECH STACK -->
<img src="https://img.shields.io/badge/Python-3.x-3776AB?style=for-the-badge&logo=python&logoColor=white" />
<img src="https://img.shields.io/badge/TensorFlow-Deep_Learning-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white" />
<img src="https://img.shields.io/badge/XGBoost-ML_Model-EC1C24?style=for-the-badge&logo=lightgbm&logoColor=white" />
<img src="https://img.shields.io/badge/Flutter-Mobile_App-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/FastAPI-Backend-009688?style=for-the-badge&logo=fastapi&logoColor=white" />
<img src="https://img.shields.io/badge/TFLite-Edge_AI-7B1FA2?style=for-the-badge&logo=tensorflow&logoColor=white" />

<br><br>

<!-- FEATURE MODULES (DIFFERENT STYLE + COLORS + ICON LOGIC) -->
<img src="https://img.shields.io/badge/✍️_Handwriting_Recognition-Pen_Stroke_AI-4A90E2?style=for-the-badge&logo=google-docs&logoColor=white" />
<img src="https://img.shields.io/badge/🎨_Coloring_Analysis-Emotion_Insight-2ECC71?style=for-the-badge&logo=adobe-photoshop&logoColor=white" />
<img src="https://img.shields.io/badge/🧠_Drawing_Intelligence-Creative_Pattern_AI-F39C12?style=for-the-badge&logo=figma&logoColor=white" />
<img src="https://img.shields.io/badge/👁️_Facial_ASD_Detection-Vision_AI-8E44AD?style=for-the-badge&logo=opencv&logoColor=white" />

<br><br>

## Demo Video

https://github.com/user-attachments/assets/f586c2c0-8875-40d4-82f4-d07a02700f82

</div>

---

# Overview

This project presents a **Multimodal AI-Assisted Adaptive Learning Companion** designed for children with **Autism Spectrum Disorder (ASD)**.

The system combines:

- Handwriting Analysis
- Coloring Analysis
- Drawing Analysis
- Facial Recognition
- CNN + XGBoost + MobileNetV2
- Adaptive Learning Games

to provide intelligent ASD prediction and personalized learning support.

---

# Key Features

- Multimodal ASD Detection
- CNN + XGBoost Hybrid Pipeline
- MobileNetV2 Facial Recognition
- Image Mismatch Detection
- Severity Classification
- Adaptive Learning Games
- TFLite Mobile Deployment
- Flutter Mobile Application
- FastAPI Backend Integration

---

# System Workflow

```text
User Uploads Image
        ↓
Category Classifier
        ↓
 ┌─────────────────────┐
 │ Match Detected      │
 └─────────┬───────────┘
           ↓
 ASD Detection Pipeline
           ↓
CNN + XGBoost + Facial Model
           ↓
Combined ASD Percentage
           ↓
Severity Detection
           ↓
Adaptive Game Recommendation
```

---

# Module 01 — Activity-Based ASD Detection

Dataset 1 – Thesis Dataset (Activity-Based Dataset)

This module analyzes user-uploaded activity-based images, including:

Handwriting
Coloring
Drawing

Dataset Link:
https://www.kaggle.com/datasets/imranliaqat32/autism-spectrum-disorder-in-childrenhandgestures

The dataset is used to support activity-based ASD feature analysis and model training.

---

# Stage 01 — Category Classification

The category classifier identifies uploaded images as:

| Classes |
|---|
| Coloring |
| Drawing |
| Handwriting |

---

# Category Classifier Results

| Metric | Result |
|---|---|
| Accuracy | **98.44%** |

---

# Stage 02 — ASD Detection

After validation:

- CNN model runs
- XGBoost model runs
- Final ASD percentage is generated

---

# ASD Detection Results

## CNN

| Metric | Result |
|---|---|
| Accuracy | **96.00%** |
| AUC | **0.9906** |

---

## XGBoost

| Metric | Result |
|---|---|
| Accuracy | **96.80%** |
| AUC | **0.9920** |

---

# Image Mismatch Detection

If a user uploads the wrong image type, the system automatically detects the mismatch.

### Example

```bash
"This image appears to be Coloring, not Handwriting"
```

---

# Dataset 01 — Activity Dataset

## Severity Levels

- Mild
- Moderate
- Severe

---

## Age Groups

- 3–6 Years
- 6–9 Years
- 9–12 Years

---

## Activities

- Coloring
- Drawing
- Handwriting

---

# Module 02 — Facial ASD Detection

This module uses facial recognition to identify ASD-related facial characteristics in children.
The dataset was created by merging two publicly available Kaggle datasets:

https://www.kaggle.com/datasets/prayashdas/autistic-children-facial-image-dataset
https://www.kaggle.com/datasets/meimeizhong/facial-dataset-of-autistic-children

After merging, the dataset was cleaned and organized to ensure consistency and class balance.

---

# Facial Recognition Dataset Structure

```bash
train/
valid/
test/
```

Each folder contains:

```bash
autistic/
non_autistic/
```

---

# Facial Dataset Summary

| Split | Images |
|---|---|
| Train | 4075 |
| Validation | 872 |
| Test | 876 |
| Total Images | 5823 |

---

# Facial Model Architecture

## MobileNetV2 Transfer Learning

```text
Input Image
      ↓
MobileNetV2 Backbone
      ↓
Global Average Pooling
      ↓
Dense(256)
      ↓
Batch Normalization
      ↓
Dropout(0.4)
      ↓
Dense(128)
      ↓
Sigmoid Output
```

---

# Facial ASD Detection Results

| Metric | Result |
|---|---|
| Accuracy | **77.05%** |
| AUC | **0.9136** |
| Precision | **70.95%** |
| Recall | **91.80%** |
| F1 Score | **80.04%** |

---

# Final Combined Detection

The final system combines outputs from:

- Handwriting
- Coloring
- Drawing
- Facial Recognition

using a weighted average fusion mechanism.

---

# Final Outputs

- Overall ASD Percentage
- ASD Presence Detection
- Severity Classification

---

# Severity Levels

| Level | Description |
|---|---|
| Mild | Low ASD indicators |
| Moderate | Medium ASD indicators |
| Severe | High ASD indicators |

---

# Adaptive Learning Games

| Severity | Recommended Games |
|---|---|
| Mild | Balloon Game, Match Game |
| Moderate | WH Questions, Routine Games |
| Severe | Sorting Game, Puzzle Games |

---

# Technologies Used

<img width="1920" height="1080" alt="Image" src="https://github.com/user-attachments/assets/5e57ae4f-1117-466c-8aa7-348295042d01" />

---

# Saved Models

```bash
models/category_classifier.keras
models/category_classifier.tflite
models/cnn_model_final.keras
models/xgboost_model.pkl
models/facial_asd_model.keras
models/facial_asd_model.tflite
```

---


<div align="center">

## Empowering Children with Autism Through AI & Adaptive Learning

</div>
