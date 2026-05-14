import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../providers/result_provider.dart';
import '../models/result_model.dart';
import 'result_screen.dart';

class UploadScreen extends StatefulWidget {
  final String category;

  const UploadScreen({
    super.key,
    required this.category,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? image;
  final picker = ImagePicker();
  bool loading = false;

  // ───────────────── PICK IMAGE ─────────────────
  Future<void> pick(ImageSource source) async {
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  // ───────────────── ANALYZE IMAGE ──────────────
  Future<void> analyze() async {
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an image first"),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      Map<String, dynamic> res;

      if (widget.category == "face") {
        res = await ApiService.uploadFace(image!);
      } else {
        res = await ApiService.uploadActivity(
          image!,
          widget.category,
        );
      }

      final model = ResultModel.fromJson(
        widget.category,
        res,
      );

      Provider.of<ResultProvider>(
        context,
        listen: false,
      ).addResult(model);

      setState(() => loading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            image: image!,
            result: res,
          ),
        ),
      );
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ───────────────── UI ─────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ───── BACKGROUND IMAGE ─────
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/dashbg.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ───── DARK OVERLAY ─────
          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          // ───── MAIN CONTENT ─────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ───── APP BAR ─────
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${widget.category.toUpperCase()} DETECTION",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ───── IMAGE CARD ─────
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(25),
                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: image == null
                        ? Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.image_outlined,
                                size: 80,
                                color: Color.fromARGB(179, 4, 2, 2),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "No Image Selected",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(25),
                            child: Image.file(
                              image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),

                  const SizedBox(height: 40),

                  // ───── BUTTONS ─────
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        icon: Icons.photo_library_rounded,
                        label: "Gallery",
                        onTap: () =>
                            pick(ImageSource.gallery),
                      ),
                      _buildButton(
                        icon: Icons.camera_alt_rounded,
                        label: "Camera",
                        onTap: () =>
                            pick(ImageSource.camera),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ───── ANALYZE BUTTON ─────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: loading ? null : analyze,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 7, 39, 99),
                        elevation: 10,
                        shadowColor:
                            Colors.blue.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Analyze Image",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── CUSTOM BUTTON ─────────────────
  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 26, 4, 4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}