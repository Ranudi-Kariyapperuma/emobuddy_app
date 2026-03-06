import 'package:emobuddy_app/screens/home_dashboard.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

   
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeDashboard()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 254, 221, 170), // Ivory
              Color.fromARGB(255, 236, 173, 212), // Nude
              Color.fromARGB(255, 166, 234, 250), // Rose
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Soft glowing icon
                  Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Image.asset(
                      'assets/emologo.png',
                      width: 250,
                      height: 250,
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    "Welcome To EmoBuddy",
                    style: GoogleFonts.fredoka(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 68, 30, 12),
                      letterSpacing: 1.2,
                    ),
                  ),

                  SizedBox(height: 10),
                  Text(
                    "Your Safe Space Buddy ",
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      color: Color.fromARGB(255, 57, 22, 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
