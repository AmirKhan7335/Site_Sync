import 'package:flutter/material.dart';

import '../main.dart';

//Role
class Role extends StatefulWidget {
  const Role({Key? key}) : super(key: key);

  @override
  RoleState createState() => RoleState();
}

class RoleState extends State<Role> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select your role')),
      backgroundColor: const Color(0xFF212832),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              // Logo
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/logo1.png'),
                // Make sure you have an image named 'logo.png' in your assets/images directory
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 20),

              // "Create Account" text
              const Text(
                'Select your Role',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  // Specify the action you want to perform on button tap
                  // For example, you can show a dialog or navigate to a new screen.
                  // Replace the below print statement with your desired action.
                  // print("Button tapped");
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.zero, // Remove padding
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 50.0),
                  // Add left padding
                  child: SizedBox(
                    height: 58,
                    width: 316,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Engineer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  // Specify the action you want to perform on button tap
                  // For example, you can show a dialog or navigate to a new screen.
                  // Replace the below print statement with your desired action.
                  // print("Button tapped");
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.zero, // Remove padding
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 50.0),
                  // Add left padding
                  child: SizedBox(
                    height: 58,
                    width: 316,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Client',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  // Specify the action you want to perform on button tap
                  // For example, you can show a dialog or navigate to a new screen.
                  // Replace the below print statement with your desired action.
                  // print("Button tapped");
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.zero, // Remove padding
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 50.0),
                  // Add left padding
                  child: SizedBox(
                    height: 58,
                    width: 316,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Consultant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  // Specify the action you want to perform on button tap
                  // For example, you can show a dialog or navigate to a new screen.
                  // Replace the below print statement with your desired action.
                  // print("Button tapped");
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.zero, // Remove padding
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 50.0),
                  // Add left padding
                  child: SizedBox(
                    height: 58,
                    width: 316,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Contractor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 376.0,
                height: 67.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return const MyHomePage(title: "HOME PAGE");
                        }));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          15.0), // Set the border radius to 15
                    ),
                    backgroundColor: Colors.yellow,
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
