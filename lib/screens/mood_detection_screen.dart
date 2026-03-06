import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MoodDetectionScreen extends StatefulWidget {
  @override
  _MoodDetectionScreenState createState() => _MoodDetectionScreenState();
}

class _MoodDetectionScreenState extends State<MoodDetectionScreen> {

  String detectedMood = "No mood detected";

  void detectMood(String mood) {
    setState(() {
      detectedMood = mood;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mood Detection"),
        backgroundColor: AppColors.primary,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Camera Icon
            Icon(
              Icons.camera_alt,
              size: 100,
              color: AppColors.primary,
            ),

            SizedBox(height: 20),

            Text(
              "Tap a mood after taking picture",
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 30),

            // Mood Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                moodButton("Happy 😊"),
                moodButton("Sad 😢"),

              ],
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                moodButton("Angry 😠"),
                moodButton("Surprised 😲"),

              ],
            ),

            SizedBox(height: 40),

            Text(
              "Detected Mood:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              detectedMood,
              style: TextStyle(
                fontSize: 22,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget moodButton(String mood) {
    return ElevatedButton(
      onPressed: () {
        detectMood(mood);
      },
      child: Text(mood),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}