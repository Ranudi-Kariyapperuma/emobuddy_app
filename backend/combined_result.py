# =========================
# SEVERITY LEVELS
# =========================


def get_severity(overall_percentage):

    if overall_percentage < 50:
        return "No ASD"

    elif overall_percentage < 70:
        return "Mild"

    elif overall_percentage < 85:
        return "Moderate"

    else:
        return "Severe"

# =========================
# GAME RECOMMENDATIONS
# =========================


def recommend_games(severity):

    games = {
        "Mild": [
            "Balloon Game",
            "Matching Game",

        ],

        "Moderate": [
            "wh Game",
            "Routine Game",

        ],

        "Severe": [
            "Sort Game",
            "Puzzel Game",

        ]
    }

    return games.get(severity, [])


# =========================
# COMBINE RESULTS
# =========================


def combine_results(activity_result, facial_result):

    activity_percentage = activity_result[
        "asd_result"
    ]["overall_percentage"]

    facial_percentage = facial_result[
        "facial_probability"
    ]

    # Weighted Average
    final_percentage = (
        (activity_percentage * 0.6) +
        (facial_percentage * 0.4)
    )

    severity = get_severity(final_percentage)

    games = recommend_games(severity)

    if final_percentage >= 50:
        final_prediction = "ASD Detected"
    else:
        final_prediction = "No ASD"

    return {
        "activity_module": activity_result,
        "facial_module": facial_result,
        "final_percentage": round(final_percentage, 2),
        "final_prediction": final_prediction,
        "severity": severity,
        "recommended_games": games
    }
