import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/screens/engineer_screens/welcome.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AccountDetails extends StatelessWidget {
  AccountDetails({super.key});
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
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/logo1.png'),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Accounts Details',
                          style: TextStyle(fontSize: 21.0, color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Consultant',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'consultant',
                      obscureText: false,
                      controller: consultantController,
                      icon: Icons.man, keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Project',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'project',
                      obscureText: false,
                      controller: projectController,
                      icon: Icons.build, keyboardType: TextInputType.text,
                    ),
                    
                    const SizedBox(height: 100),
                    MyButton(
                      text: 'Continue',
                      bgColor: Colors.yellow,
                      textColor: Colors.black,
                      
                      onTap: () {
Navigator.push(context, MaterialPageRoute(builder: (context) =>  WelcomeEngineer()));
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