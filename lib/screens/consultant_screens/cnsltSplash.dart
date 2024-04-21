import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/screens/consultant_screens/consultantHome.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConsultantSplash extends StatelessWidget {
  ConsultantSplash({super.key});

  final _formKey = GlobalKey<FormState>();
  bool isloading = false;
  TextEditingController consultantController = TextEditingController();
  TextEditingController projectController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      radius: 90,
                      backgroundImage: AssetImage('assets/images/logo1.png'),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(

                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Construction\n Progress Tracking',
                          style: TextStyle(fontSize: 35.0, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(height: 150),
                    MyButton(
                      text: 'Let\'s Start',
                      bgColor: Colors.green,
                      textColor: Colors.black,
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConsultantHomePage()));
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
