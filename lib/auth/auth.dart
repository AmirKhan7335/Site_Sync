import 'package:amir_khan1/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/selectorscreen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context){
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return MyHomePage(title: 'My Home Page',);
          }
          else{
            return const Selector(); // If there is no user logged in, show login page....signup_or_createaccount.dart
          }
        },
      ),
    );
  }
}