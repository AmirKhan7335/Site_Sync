import 'package:flutter/material.dart';
import '../../components/my_button.dart';

//Selector Screen
class Selector extends StatelessWidget {
  const Selector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset('assets/images/logo1.png'),
                ),
                const Text(
                  "Construction Progress Tracking",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  "Track like a pro",
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
                const SizedBox(
                  height: 180,
                ),
                MyButton(
                  text: "Log in",
                  bgColor: Colors.green,
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.pushNamed(context, "/signin");
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                MyButton(
                  text: "Sign Up",
                  bgColor: Colors.blue,
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.pushNamed(context, "/createaccount");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}