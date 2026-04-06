import 'package:emobuddy_app/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mood_detection_screen.dart';
import 'camera_screen.dart';

class HomeDashboard extends StatelessWidget {

  final List<Color> backgroundColors = [
    Color.fromARGB(255, 254, 221, 170), // Ivory
    Color.fromARGB(255, 236, 173, 212), // Nude
    Color.fromARGB(255, 166, 234, 250), // Rose
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

        /// Background Gradient
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
              children: [

                /// Logo + App Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/emologo.png",
                      height: 65,
                    ),
                    SizedBox(width: 10),
                    Text(
                    "EmoBuddy",
                    style: GoogleFonts.fredoka(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 68, 30, 12),
                      letterSpacing: 1.2,
                    ),
                  ),
                  ],
                ),

                SizedBox(height: 30),

                /// Title
                Text(
                  "Choose an Activity 🎮",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 25),

                /// Grid Cards
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    children: [

                      dashboardCard(
                        context,
                        "Mood Check",
                        Icons.camera_alt,
                        Colors.orange,
                       
                      ),

                      dashboardCard(
                        context,
                        "Puzzle Game",
                        Icons.extension,
                        Colors.purple,
                      ),

                      dashboardCard(
                        context,
                        "Story Time",
                        Icons.menu_book,
                        Colors.green,
                      ),

                      dashboardCard(
                        context,
                        "Drawing",
                        Icons.brush,
                        Colors.blue,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Dashboard Card Widget
  Widget dashboardCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      ) {
    return GestureDetector(
      onTap: () {

        if (title == "Mood Check") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CameraScreen(),
            ),
          );
        }

      },

      child: Container(
        decoration: BoxDecoration(

          /// Colorful Gradient Cards
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.6)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          borderRadius: BorderRadius.circular(30),

          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 5),
            )
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// Icon
            Icon(
              icon,
              size: 60,
              color: Colors.white,
            ),

            SizedBox(height: 15),

            /// Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}