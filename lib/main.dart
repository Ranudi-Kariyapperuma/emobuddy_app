import 'package:emobuddy_app/games/fruitvegisort.dart';
import 'package:emobuddy_app/games/puzzel.dart';
import 'package:emobuddy_app/games/routing_screen.dart';
import 'package:emobuddy_app/games/wh_game_screen.dart';
import 'package:emobuddy_app/screens/Mild_screen.dart';
import 'package:emobuddy_app/screens/Moderate_screen.dart';
import 'package:emobuddy_app/screens/Severe_screen.dart';
import 'package:emobuddy_app/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';                    // ✅ ADD THIS
import 'package:emobuddy_app/providers/result_provider.dart'; // ✅ ADD THIS
import 'screens/splash_screen.dart';
import 'screens/camera_screen.dart';
import 'games/happy_matching.dart';
import 'games/angry_balloon.dart';
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
    return MultiProvider(                                    // ✅ ADD THIS
      providers: [
        ChangeNotifierProvider(create: (_) => ResultProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EmoBuddy',

        theme: ThemeData(
          primaryColor: AppColors.primary,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
        ),

        home: SplashScreen(),

        routes: {
          '/camera': (context) => CameraScreen(),
          '/happy': (context) => HappyMatchingGame(),
          '/angry': (context) => BalloonLearningGame(),
        },
      ),
    );
  }
}