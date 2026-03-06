import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EmoBuddy',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        fontFamily: 'Poppins',
      ),
      home: SplashScreen(),
    );
  }
}