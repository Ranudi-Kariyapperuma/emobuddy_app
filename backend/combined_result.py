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
            "name":        "Emotion Match Cards",
            "type":        "Cognitive / Social",
            "description": "Match facial expression cards to emotion words. "
                           "Builds emotional recognition in a low-pressure setting.",
            "skills":      ["Emotion recognition", "Matching", "Language"],
        },
        {
            "name":        "Turn-Taking Puzzle",
            "type":        "Social / Fine Motor",
            "description": "Two-player jigsaw where each child places one piece per turn. "
                           "Encourages patience and cooperative play.",
            "skills":      ["Turn-taking", "Social interaction", "Fine motor"],
        },
        {
            "name":        "Story Sequencing Game",
            "type":        "Cognitive / Language",
            "description": "Arrange picture cards to form a short story. "
                           "Supports narrative understanding and verbal expression.",
            "skills":      ["Sequencing", "Narrative", "Communication"],
        },
        {
            "name":        "Simple Coding Maze",
            "type":        "STEM / Problem Solving",
            "description": "Use directional arrow cards to guide a character through a maze. "
                           "Introduces logical thinking without a screen.",
            "skills":      ["Logic", "Planning", "Spatial awareness"],
        },
    ],
    "Moderate": [
        {
            "name":        "Sensory Colour Sorting",
            "type":        "Sensory / Fine Motor",
            "description": "Sort textured, brightly coloured objects into matching trays. "
                           "Calming sensory input combined with categorisation practice.",
            "skills":      ["Sensory processing", "Categorisation", "Fine motor"],
        },
        {
            "name":        "Mirror Me Movement Game",
            "type":        "Social / Gross Motor",
            "description": "Caregiver and child take turns mirroring each other's body movements. "
                           "Builds imitation, eye contact, and body awareness.",
            "skills":      ["Imitation", "Eye contact", "Body awareness"],
        },
        {
            "name":        "Visual Schedule Bingo",
            "type":        "Cognitive / Routine",
            "description": "Bingo cards use pictures of daily-routine activities. "
                           "Reinforces schedule understanding in a game format.",
            "skills":      ["Routine", "Visual learning", "Attention"],
        },
        {
            "name":        "Bubble Wrap Pop Counting",
            "type":        "Sensory / Math",
            "description": "Pop numbered bubble-wrap squares to practise counting 1-20. "
                           "Satisfying tactile feedback motivates engagement.",
            "skills":      ["Numeracy", "Sensory regulation", "Focus"],
        },
    ],
    "Severe": [
        {
            "name":        "Cause-and-Effect Toy Play",
            "type":        "Sensory / Cognitive",
            "description": "Press-a-button toys that produce predictable light/sound. "
                           "Teaches basic cause-and-effect with instant reward.",
            "skills":      ["Cause & effect", "Attention", "Sensory stimulation"],
        },
        {
            "name":        "Tactile Sensory Bin",
            "type":        "Sensory / Exploration",
            "description": "Explore bins filled with sand, rice, or water beads. "
                           "Supports sensory desensitisation and hand exploration.",
            "skills":      ["Sensory tolerance", "Exploration", "Calm regulation"],
        },
        {
            "name":        "Simple AAC Symbol Matching",
            "type":        "Communication / Cognitive",
            "description": "Match AAC (Augmentative & Alternative Communication) picture symbols "
                           "to real objects. Lays groundwork for functional communication.",
            "skills":      ["Communication", "Symbol recognition", "Matching"],
        },
        {
            "name":        "Rhythm & Music Clapping",
            "type":        "Sensory / Social",
            "description": "Clap or tap simple beat patterns together with a caregiver. "
                           "Encourages joint attention and auditory processing.",
            "skills":      ["Joint attention", "Auditory processing", "Rhythm"],
        },
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
    severity     = determine_severity(overall)
    games        = get_games(severity) if severity else []

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
