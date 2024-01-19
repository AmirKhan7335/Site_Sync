import 'package:amir_khan1/main.dart';
import 'package:amir_khan1/screens/rolescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/engineer_screens/selectorscreen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build (BuildContext context){
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return const Role();
          }
          else{
            return const Selector(); // If there is no user logged in, show login page....signup_or_createaccount.dart
          }
        },
      ),
    );
  }
}