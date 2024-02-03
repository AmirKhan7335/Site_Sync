import 'package:amir_khan1/main.dart';
import 'package:amir_khan1/screens/consultant_screens/consultantSplash.dart';
import 'package:amir_khan1/screens/engineer_screens/accountDetails.dart';
import 'package:amir_khan1/screens/engineer_screens/engineerHome.dart';
import 'package:amir_khan1/screens/rolescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/engineer_screens/selectorscreen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final user = FirebaseAuth.instance.currentUser;
  getRole() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.email)
        .get();
    if (userSnapshot.exists) {
      return userSnapshot['role'];
    } else {
      return 'No User'; // Default username for guests
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
                future: getRole(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == 'Engineer') {
                      return AccountDetails();
                    } else if (snapshot.data == 'Consultant') {
                      return ConsultantSplash();
                    } else {
                      return Center(child: Text('Unknown Error'));
                    }
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    return Text('Unknown Error');
                  }
                });
          } else {
            return const Selector(); // If there is no user logged in, show login page....signup_or_createaccount.dart
          }
        },
      ),
    );
  }
}
