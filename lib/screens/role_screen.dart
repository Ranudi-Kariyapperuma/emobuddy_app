import 'package:emobuddy_app/screens/home_dashboard.dart';
import 'package:emobuddy_app/screens/parent_login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? selectedRole;

  void selectRole(String role) {
    setState(() {
      selectedRole = role;
    });
  }

  Widget buildCard({
    required String title,
    required String asset,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(asset, height: 120, repeat: true),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void continueNext() {
    if (selectedRole != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Selected: $selectedRole")));
      // Navigate to next screen here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 254, 221, 170),
              Color.fromARGB(255, 236, 173, 212),
              Color.fromARGB(255, 166, 234, 250),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// ================= HEADER =================
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(),
                          child: Image.asset("assets/emologo.png", height: 55),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          "EmoBuddy",
                          style: GoogleFonts.fredoka(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: const Color.fromARGB(255, 68, 30, 12),
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// ================= TITLE =================
              const Text(
                "Choose Your Role",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Are you a Parent or a Child?",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 60),

              /// ================= CARDS =================
              Column(
                children: [
                  Transform.scale(
                    scale: 1.3,
                    child: buildCard(
                      title: "Parent",
                      asset: "assets/lottie/parent.json",
                      isSelected: selectedRole == "Parent",
                      onTap: () {
                        selectRole("Parent");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParentLoginScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 85),

                  Transform.scale(
                    scale: 1.3,
                    child: buildCard(
                      title: "Child",
                      asset: "assets/lottie/child.json",
                      isSelected: selectedRole == "Child",
                      onTap: () {
                        selectRole("Child");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeDashboard(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
