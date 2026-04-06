import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/mock_mood_service.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? image;
  final picker = ImagePicker();
  bool loading = false;

  // 📷 Capture from camera
  Future<void> captureImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        setImage(File(picked.path));
      }
    } catch (e) {
      print("Camera error: $e");
    }
  }

  // 🖼️ Pick from gallery
  Future<void> pickFromGallery() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setImage(File(picked.path));
      }
    } catch (e) {
      print("Gallery error: $e");
    }
  }

  void setImage(File img) {
    setState(() {
      image = img;
    });
  }

  // 🧠 Detect mood (mock for now)
  Future<void> detectMood() async {
    if (image == null) return;

    setState(() {
      loading = true;
    });

    String mood = await MockMoodService().detectMood();

    setState(() {
      loading = false;
    });

    navigateToGame(mood);
  }

  void navigateToGame(String mood) {
    Navigator.pushNamed(context, '/$mood');
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> backgroundColors = [
      Color.fromARGB(255, 254, 221, 170), // Ivory
      Color.fromARGB(255, 236, 173, 212), // Nude
      Color.fromARGB(255, 166, 234, 250), // Light Blue
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detect Mood 📷'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: loading
              ? CircularProgressIndicator(color: Colors.white)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 📸 Image Preview / Icon
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(image!, fit: BoxFit.cover),
                            )
                          : Icon(Icons.camera_alt, size: 80, color: Colors.white),
                    ),

                    SizedBox(height: 30),

                    // 📷 Camera Button
                    buildCuteButton(
                      text: "Use Camera",
                      icon: Icons.camera_alt,
                      color: Colors.orange,
                      onPressed: captureImage,
                    ),

                    SizedBox(height: 15),

                    // 🖼️ Gallery Button
                    buildCuteButton(
                      text: "Pick from Gallery",
                      icon: Icons.photo,
                      color: Colors.pinkAccent,
                      onPressed: pickFromGallery,
                    ),

                    SizedBox(height: 25),

                    // 🧠 Detect Mood Button
                    buildCuteButton(
                      text: "Detect Mood",
                      icon: Icons.psychology,
                      color: Colors.green,
                      onPressed: detectMood,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // 🎨 Cute Button Widget
  Widget buildCuteButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}