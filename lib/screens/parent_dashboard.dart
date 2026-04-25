import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'result_page.dart';

class ParentDashboard extends StatelessWidget {
  final List<Color> backgroundColors = [
    Color.fromARGB(255, 254, 221, 170),
    Color.fromARGB(255, 236, 173, 212),
    Color.fromARGB(255, 166, 234, 250),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔝 TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Parent Dashboard 👨‍👩‍👧",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),

                SizedBox(height: 20),

                /// 👋 WELCOME CARD
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.pink, size: 40),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "Welcome! Upload your child's work and get AI feedback 💙",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25),

                /// 🎯 GRID CARDS
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      card(context, "Coloring", Icons.color_lens, Colors.pink),
                      card(context, "Drawing", Icons.brush, Colors.orange),
                      card(context, "Handwriting", Icons.edit, Colors.blue),
                      card(
                        context,
                        "Art Scan",
                        Icons.camera_alt,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎴 CARD UI
  Widget card(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => pickImage(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 5),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📷 PICK IMAGE
  Future<void> pickImage(BuildContext context) async {
    final picker = ImagePicker();

    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      File image = File(file.path);
      uploadImage(context, image);
    }
  }

  /// 🚀 UPLOAD IMAGE TO BACKEND
  Future<void> uploadImage(BuildContext context, File image) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("http://10.0.2.2:8000/predict"), // change this
    );

    request.files.add(await http.MultipartFile.fromPath("file", image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final data = jsonDecode(res);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultPage(data: {...data, "image_path": image.path}),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed. Try again")));
    }
  }
}
