import 'package:attendify/presentation/pages/auth/login_page.dart';
import 'package:attendify/presentation/pages/home/home_page.dart';
import 'package:attendify/data/local/preferences.dart';
import 'package:attendify/presentation/widgets/copy_right.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay
    final loggedIn = await Preferences.isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/attendify_black.png',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 24),
            CopyrightText(),
          ],
        ),
      ),
    );
  }
}
