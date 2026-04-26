import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/camera_screen.dart';
import 'games/happy_matching.dart';
import 'games/sad_numbergame.dart';
import 'games/angry_balloon.dart';
import 'games/fear_puzzle.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        scaffoldBackgroundColor: Colors.white,
      ),

      // 🚀 START SCREEN
      home: SplashScreen(),

      // 🔥 ROUTES (VERY IMPORTANT)
      routes: {
        '/camera': (context) => CameraScreen(),

        '/happy': (context) => HappyMatchingGame(),
        '/sad': (context) => SadNumberGame(),
        '/angry': (context) => BalloonLearningGame(),
        '/fear': (context) => fearpuzzelgame(),
      },
    );
  }
}