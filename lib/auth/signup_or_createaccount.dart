import 'package:amir_khan1/auth/signinscreen.dart';
import 'package:flutter/material.dart';

import '../screens/engineer_screens/createaccountscreen.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // initially, show login page
  bool showLoginPage = true;

  // toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      // pass togglePages as a void callback function
      return SigninScreen(onTap: () => togglePages());
    } else {
      // pass togglePages as a void callback function
      return CreateAccountScreen(onTap: () => togglePages());
    }
  }
}
