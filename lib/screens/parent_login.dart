import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'parent_dashboard.dart';

class ParentLoginScreen extends StatefulWidget {
  @override
  _ParentLoginScreenState createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final parentNameController = TextEditingController();
  final childNameController = TextEditingController();
  final childAgeController = TextEditingController();

  bool isLogin = true;

  final List<Color> backgroundColors = [
    Color.fromARGB(255, 254, 221, 170),
    Color.fromARGB(255, 236, 173, 212),
    Color.fromARGB(255, 166, 234, 250),
  ];

  /// LOGIN
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ParentDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Login Failed");
    }
  }

  /// SIGNUP
  Future<void> signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 👉 Later you can store extra data in Firestore
      print("Parent: ${parentNameController.text}");
      print("Child: ${childNameController.text}");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ParentDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Signup Failed");
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget inputField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
  height: MediaQuery.of(context).size.height, 
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: 20),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    /// BACK BUTTON
    IconButton(
      icon: const Icon(Icons.arrow_back_ios_new),
      onPressed: () {
        Navigator.pop(context);
      },
    ),

    /// CENTER CONTENT (Logo + Text)
    Row(
      children: [
        Image.asset("assets/emologo.png", height: 65),
        const SizedBox(width: 10),
        Text(
          "EmoBuddy",
          style: GoogleFonts.fredoka(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 68, 30, 12),
            letterSpacing: 1.2,
          ),
        ),
      ],
    ),

    /// RIGHT SIDE SPACER (to balance layout)
    const SizedBox(width: 40),
  ],
),

    SizedBox(height: 30),

                /// TITLE
                Text(
                  isLogin ? "Welcome Back 👋" : "Create Parent Account 💙",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 25),

                /// EXTRA FIELDS FOR SIGNUP
                if (!isLogin) ...[
                  inputField(parentNameController, "Parent Name"),
                  inputField(childNameController, "Child Name"),
                  inputField(childAgeController, "Child Age"),
                ],

                /// COMMON FIELDS
                inputField(emailController, "Email"),
                inputField(passwordController, "Password", obscure: true),

                SizedBox(height: 20),

                /// BUTTON
                ElevatedButton(
                  onPressed: isLogin ? login : signup,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor:
                        isLogin ? Colors.orange : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    isLogin ? "Login" : "Sign Up",
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                SizedBox(height: 15),

                /// TOGGLE
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Login",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}