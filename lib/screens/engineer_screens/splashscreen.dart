import 'package:flutter/material.dart';
import '../../auth/auth.dart';

// splash screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Delay the navigation to the next screen by 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const AuthPage();
      }));
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Image.asset('assets/images/logo1.png'),
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Construction Progress Tracking',
                style: TextStyle(fontSize: 44.0, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}