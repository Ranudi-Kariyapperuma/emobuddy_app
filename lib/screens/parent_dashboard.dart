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
                /// Each card passes its own tab name — this is the key change.
                /// "Art Scan" is removed because the backend only accepts
                /// Coloring / Drawing / Handwriting.
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _card(context, "Coloring",     Icons.color_lens,  Colors.pink),
                      _card(context, "Drawing",      Icons.brush,       Colors.orange),
                      _card(context, "Handwriting",  Icons.edit,        Colors.blue),
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

  /// 🎴 CARD — now receives [tabName] and passes it all the way to the API
  Widget _card(BuildContext context, String tabName, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _pickImage(context, tabName),   // ← tabName flows in here
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              tabName,
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

  /// 📷 PICK IMAGE — now carries [selectedTab] forward
  Future<void> _pickImage(BuildContext context, String selectedTab) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      _uploadImage(context, File(file.path), selectedTab);
    }
  }

  /// 🚀 UPLOAD — sends both the image file AND selected_tab to the backend
  Future<void> _uploadImage(BuildContext context, File image, String selectedTab) async {
    // Show a loading indicator while waiting for the API
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      var request = http.MultipartRequest(
        "POST",
       Uri.parse("http://192.168.1.8:8000/predict"),
      );

      // ── The two fields the backend now expects ──────────────────────────────
      request.fields['selected_tab'] = selectedTab;          // NEW
      request.files.add(
        await http.MultipartFile.fromPath("file", image.path),
      );

      var response = await request.send();

      // Dismiss loading
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final res  = await response.stream.bytesToString();
        final data = jsonDecode(res) as Map<String, dynamic>;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultPage(
              data: {...data, "image_path": image.path},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed (${response.statusCode}). Try again.")),
        );
      }
    } catch (e) {
      Navigator.pop(context); // dismiss loading if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
