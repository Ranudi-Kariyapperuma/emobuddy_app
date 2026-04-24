import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

        /// 🌈 Gradient Background
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
                    )
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
                          "Welcome! Track your child's progress and emotions 💙",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25),

                /// 🎯 GRID FEATURES
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [

                      dashboardCard("Mood History", Icons.insert_chart, Colors.purple),
                      dashboardCard("Child Progress", Icons.show_chart, Colors.green),
                      dashboardCard("Activities", Icons.extension, Colors.orange),
                      dashboardCard("Settings", Icons.settings, Colors.blue),

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

  /// 🎴 CARD WIDGET
  Widget dashboardCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.6),
          ],
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
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}