import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WelcomeEngineer extends StatelessWidget {
  WelcomeEngineer({super.key});
  final _formKey = GlobalKey<FormState>();
  bool isloading = false;
  TextEditingController consultantController = TextEditingController();
  TextEditingController projectController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212832),
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
                      // backgroundImage: AssetImage('assets/images/logo1.png'),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 150,
                        color: Colors.green,
                      ),
                      backgroundColor: Colors.transparent,
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
                              color: Colors.white,
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
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 200),
                    MyButton(
                      text: 'Continue',
                      bgColor: Colors.yellow,
                      textColor: Colors.black,
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const EngineerHomePage();
                        }));
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
