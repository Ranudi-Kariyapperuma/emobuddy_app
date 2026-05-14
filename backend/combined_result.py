"""
combined_result.py
Combines Module-1 (drawing/coloring/handwriting) and Module-2 (facial)
ASD probabilities into a final decision with severity level and game recommendations.
"""

from __future__ import annotations

# ── Weights ────────────────────────────────────────────────────────────────────
# Module-1 (activity images): CNN + XGBoost averaged → weighted 60 %
# Module-2 (facial):                                  → weighted 40 %
WEIGHT_MODULE1 = 0.60
WEIGHT_MODULE2 = 0.40

# ── ASD detection threshold ────────────────────────────────────────────────────
ASD_THRESHOLD = 50.0   # percentage; ≥ 50 % → ASD detected

# ── Severity bands ─────────────────────────────────────────────────────────────
#   50 – 65 %  → Mild
#   65 – 80 %  → Moderate
#   80 – 100 % → Severe
SEVERITY_BANDS = [
    (80.0, 100.0, "Severe"),
    (65.0,  80.0, "Moderate"),
    (50.0,  65.0, "Mild"),
]

# ── Game recommendations per severity ─────────────────────────────────────────
GAMES: dict[str, list[dict]] = {
    "Mild": [
        {
            "name": "Angry Balloon - Learn & Pop",
            "type": "Cognitive / Language / Attention",
            "description": (
                "A balloon popping learning game where children identify letters, "
                "follow targets, and learn alphabetical order through interactive play. "
                "Includes free play, target matching, and A-Z sequencing modes."
            ),
            "skills": [
                "Letter recognition",
                "Attention control",
                "Sequencing (A-Z)",
                "Reaction time",
                "Auditory learning"
            ],
            "file": "angry_balloon.dart"
        },
        {
            "name": "Happy Matching Game (MatchBox)",
            "type": "Cognitive / Visual Association",
            "description": (
                "An interactive image-matching game where children connect related items "
                "(e.g., animal → food) using visual pairing. Reinforces association skills "
                "through progressive levels."
            ),
            "skills": [
                "Visual association",
                "Problem solving",
                "Memory",
                "Pattern recognition",
                "Hand-eye coordination"
            ],
            "file": "happy_matching.dart"
        }
    ],

    "Moderate": [
        {
            "name": "Morning Routine Game (Drag & Drop)",
            "type": "Cognitive / Daily Living Skills / Routine Building",
            "description": (
                "An interactive drag-and-drop daily routine game where children complete "
                "morning activities such as waking up, brushing teeth, washing face, "
                "eating breakfast, and preparing for school. "
                "Includes voice guidance, visual scenes, and positive reinforcement."
            ),
            "skills": [
                "Routine sequencing",
                "Daily living skills",
                "Motor coordination",
                "Attention",
                "Task completion"
            ],
            "file": "routine_screen.dart"
        },

        {
            "name": "WH Question Game (Learning Quiz Adventure)",
            "type": "Cognitive / Language / Communication",
            "description": (
                "A WH-question based learning game where children answer interactive questions "
                "using visual options and animations. Includes voice feedback, star rewards, "
                "and multiple animated backgrounds to improve engagement."
            ),
            "skills": [
                "Language comprehension",
                "Question answering (What/Where/Who)",
                "Decision making",
                "Visual learning",
                "Attention"
            ],
            "file": "wh_game_screen.dart"
        }
    ],
    "Severe": [
        {
            "name": "Fruit & Vegetable Sort Challenge",
            "type": "Cognitive / Classification / Attention",
            "description": (
                "An interactive drag-and-drop sorting game where children classify fruits and vegetables "
                "into correct categories. The game includes multiple levels with increasing item count, "
                "background changes, and real-time voice feedback using TTS."
            ),
            "skills": [
                "Category recognition",
                "Visual discrimination",
                "Attention to detail",
                "Decision making",
                "Auditory processing",
                "Hand-eye coordination"
            ],
            "file": "fruitvegisort.dart"
        },
        {
            "name": "Animal Image Puzzle Builder",
            "type": "Cognitive / Spatial Reasoning / Problem Solving",
            "description": (
                "A drag-and-drop jigsaw puzzle game where players reconstruct animal images by placing "
                "shuffled pieces into correct grid positions. Includes multi-level progression, "
                "animated feedback, and increasing grid complexity for higher difficulty."
            ),
            "skills": [
                "Spatial reasoning",
                "Problem solving",
                "Memory",
                "Visual matching",
                "Fine motor skills",
                "Pattern recognition"
            ],
            "file": "puzzel.dart"
        }
    ],
}


# ── Core functions ─────────────────────────────────────────────────────────────

def compute_overall_probability(
    module1_prob: float | None,
    module2_prob: float | None,
) -> float:
    """
    Compute weighted-average ASD probability.

    Either probability may be None if that module was skipped.
    Weights are re-normalised if one module is absent.
    """
    if module1_prob is None and module2_prob is None:
        raise ValueError("At least one module probability is required.")

    if module1_prob is None:
        return round(float(module2_prob), 2)     # type: ignore[arg-type]

    if module2_prob is None:
        return round(float(module1_prob), 2)

    combined = WEIGHT_MODULE1 * module1_prob + WEIGHT_MODULE2 * module2_prob
    return round(combined, 2)


def determine_severity(overall_prob: float) -> str | None:
    """
    Map overall probability (%) to a severity label.
    Returns None if ASD is not detected (< ASD_THRESHOLD).
    """
    if overall_prob < ASD_THRESHOLD:
        return None

    for low, high, label in SEVERITY_BANDS:
        if low <= overall_prob <= high:
            return label

    return "Severe"   # fallback for 100 %


def get_games(severity: str) -> list[dict]:
    """Return the recommended game list for a given severity level."""
    return GAMES.get(severity, [])


def build_combined_result(
    module1_results: list[dict] | None,
    module2_result:  dict | None,
) -> dict:
    """
    Build the final combined result dictionary.

    Parameters
    ----------
    module1_results : list of result dicts from run_module1()
                      (one per uploaded activity image; may be None / empty)
    module2_result  : result dict from run_module2()  (may be None)

    Returns
    -------
    {
        "module1_probabilities": [...],
        "module1_average":       float | None,
        "module2_probability":   float | None,
        "overall_probability":   float,
        "asd_detected":          bool,
        "severity":              "Mild" | "Moderate" | "Severe" | None,
        "recommended_games":     [...],
        "summary":               str
    }
    """
    # ── Module-1 aggregation ──────────────────────────────────────────────────
    m1_probs: list[float] = []
    if module1_results:
        for r in module1_results:
            # Only include results where category matched and ASD prob present
            prob = r.get("module1_asd_probability")
            if prob is not None:
                m1_probs.append(prob)

    m1_avg = round(sum(m1_probs) / len(m1_probs), 2) if m1_probs else None

    # ── Module-2 probability ──────────────────────────────────────────────────
    m2_prob: float | None = None
    if module2_result:
        m2_prob = module2_result.get("module2_asd_probability")

    # ── Combined probability ──────────────────────────────────────────────────
    overall = compute_overall_probability(m1_avg, m2_prob)

    # ── Decision ──────────────────────────────────────────────────────────────
    asd_detected = overall >= ASD_THRESHOLD
    severity = determine_severity(overall)
    games = get_games(severity) if severity else []

    # ── Human-readable summary ────────────────────────────────────────────────
    if asd_detected:
        summary = (
            f"Based on the combined analysis (overall ASD probability: {overall:.1f}%), "
            f"the child is likely on the autism spectrum with a '{severity}' severity level. "
            f"{len(games)} games have been recommended to support their development."
        )
    else:
        summary = (
            f"Based on the combined analysis (overall ASD probability: {overall:.1f}%), "
            f"no significant indicators of ASD were detected at this time. "
            f"Please consult a qualified clinician for a comprehensive evaluation."
        )

    return {
        "module1_probabilities": m1_probs,
        "module1_average":       m1_avg,
        "module2_probability":   m2_prob,
        "overall_probability":   overall,
        "asd_detected":          asd_detected,
        "severity":              severity,
        "recommended_games":     games,
        "summary":               summary,
    }
