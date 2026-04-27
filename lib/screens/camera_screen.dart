import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/mood_service.dart';   // ← real service, not mock

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  final _picker      = ImagePicker();
  final _moodService = MoodService();

  bool   _loading      = false;
  String _statusText   = '';   // shows feedback to user

  // ── Image capture ───────────────────────────────────────────────────────────
  Future<void> _captureFromCamera() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked != null) _setImage(File(picked.path));
    } catch (e) {
      _showError('Camera error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) _setImage(File(picked.path));
    } catch (e) {
      _showError('Gallery error: $e');
    }
  }

  void _setImage(File img) {
    setState(() {
      _image      = img;
      _statusText = 'Image ready! Tap "Detect Mood" 🎯';
    });
  }

  // ── Detect mood via FastAPI ─────────────────────────────────────────────────
  Future<void> _detectMood() async {
    if (_image == null) {
      _showError('Please pick or capture an image first.');
      return;
    }

    setState(() {
      _loading    = true;
      _statusText = 'Analysing mood... 🧠';
    });

    try {
      final mood = await _moodService.detectMood(_image!);
      setState(() => _loading = false);
      _navigateToActivity(mood);
    } catch (e) {
      setState(() {
        _loading    = false;
        _statusText = '';
      });
      _showError(e.toString());
    }
  }

  void _navigateToActivity(String mood) {
    // Routes: /anger  /fear  /happy  /sad
    Navigator.pushNamed(context, '/$mood');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── UI ──────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detect Mood 📷'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFEDDAA),  // Ivory
              Color(0xFFECADD4),  // Nude pink
              Color(0xFFA6EAFA),  // Light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _loading
                ? _buildLoadingView()
                : _buildMainView(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 20),
        Text(
          _statusText,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // ── Image preview box ──────────────────────────────────────────────
          Container(
            height: 220,
            width: 220,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white54, width: 2),
            ),
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(_image!, fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 70, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'No image yet',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 12),

          // ── Status text ────────────────────────────────────────────────────
          if (_statusText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const SizedBox(height: 28),

          // ── Camera button ──────────────────────────────────────────────────
          _buildButton(
            text: 'Use Camera',
            icon: Icons.camera_alt,
            color: Colors.orange,
            onPressed: _captureFromCamera,
          ),
          const SizedBox(height: 14),

          // ── Gallery button ─────────────────────────────────────────────────
          _buildButton(
            text: 'Pick from Gallery',
            icon: Icons.photo,
            color: Colors.pinkAccent,
            onPressed: _pickFromGallery,
          ),
          const SizedBox(height: 28),

          // ── Detect mood button ─────────────────────────────────────────────
          _buildButton(
            text: 'Detect Mood',
            icon: Icons.psychology,
            color: _image != null ? Colors.green : Colors.grey,
            onPressed: _image != null ? _detectMood : null,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: Colors.grey.shade400,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
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
