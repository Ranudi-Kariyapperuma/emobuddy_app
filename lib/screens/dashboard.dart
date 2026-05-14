import 'package:flutter/material.dart';
import 'upload_screen.dart';
import 'summary_screen.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Stack(
        children: [
          // 🌄 FULL BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset("assets/images/dashbg.jpg", fit: BoxFit.cover),
          ),

          // 🌑 DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 62, 51, 51).withOpacity(0.55),
            ),
          ),

          // 📱 CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔥 ASD TITLE
                  const Text(
                    "ASD DETECTION DASHBOARD",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 50, 8, 12),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // HEADER CARD
                  _buildHeaderCard(),

                  const SizedBox(height: 45),

                  Expanded(child: _buildGrid(context)),

                  const SizedBox(height: 3),

                  _buildSummaryButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(255, 52, 4, 131),
        border: Border.all(color: const Color.fromARGB(60, 0, 0, 0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // 🌈 MULTIMODAL TEXT WITH COLOR
          Text(
            "Multimodal ASD Detection",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "Upload drawings, handwriting, coloring, or face scan for analysis",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ================= GRID =================
  Widget _buildGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 16,
      children: [
        _buildCard(
          context,
          title: "Coloring",
          image: "assets/images/colorimg.jpg",
          color: Colors.purple,
          type: "coloring",
        ),
        _buildCard(
          context,
          title: "Drawing",
          image: "assets/images/drawimg.jpg",
          color: Colors.orange,
          type: "drawing",
        ),
        _buildCard(
          context,
          title: "Handwriting",
          image: "assets/images/handimg.jpg",
          color: Colors.green,
          type: "handwriting",
        ),
        _buildCard(
          context,
          title: "Face Scan",
          image: "assets/images/faceimg.jpg",
          color: Colors.blue,
          type: "face",
        ),
      ],
    );
  }

  // ================= CARD =================
  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String image,
    required Color color,
    required String type,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UploadScreen(category: type)),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.65)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 LARGE ROUND ICON AREA
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ClipOval(child: Image.asset(image, fit: BoxFit.cover)),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Tap to start",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _buildSummaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.analytics, size: 24),
        label: const Text(
          "View Final Summary",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 31, 4, 4),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white24),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SummaryScreen()),
          );
        },
      ),
    );
  }
}
