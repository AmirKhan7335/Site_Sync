import 'package:amir_khan1/components/my_button.dart';
// import 'package:amir_khan1/components/mytextfield.dart';
// import 'package:amir_khan1/main.dart';
import 'package:amir_khan1/screens/engineer_screens/engineerHome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeEngineer extends StatefulWidget {
  const WelcomeEngineer({super.key});

  @override
  State<WelcomeEngineer> createState() => _WelcomeEngineerState();
}

class _WelcomeEngineerState extends State<WelcomeEngineer> {
  Future<bool> checkRequestStatus() async {
    final email = FirebaseAuth.instance.currentUser!.email;
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .get();
    bool requestStatus = await activitiesSnapshot['reqAccepted'];
    return requestStatus;
  }

  final _formKey = GlobalKey<FormState>();

  bool isloading = false;

  TextEditingController consultantController = TextEditingController();

  TextEditingController projectController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/auth', (route) => false);
                } catch (e) {
                  if (kDebugMode) {
                    print('Error during logout: $e');
                  }
                }
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ))
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF3F3F3),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 25.0,
                top: 25.0,
                right: 25.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.transparent,
                      // backgroundImage: AssetImage('assets/images/logo1.png'),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 150,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Welcome',
                          style: TextStyle(
                              fontSize: 21.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Request has been sent to the \n client for approval',
                          style: TextStyle(fontSize: 18.0, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 150),
                    MyButton(
                      text: 'Continue',
                      bgColor: Colors.green,
                      textColor: Colors.black,
                      onTap: () async {
                        bool status = await checkRequestStatus();
                        if (status == true) {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return const EngineerHomePage();
                          }));
                        } else {
                          Get.snackbar('Sorry',
                              'Request is not Accepted by Consultant Yet!!');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: isloading,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
