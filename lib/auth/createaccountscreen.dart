import 'package:amir_khan1/screens/client_screen/clientAccountDetail.dart';
import 'package:amir_khan1/screens/consultant_screens/cnsltCompanyInfo.dart';
import 'package:amir_khan1/screens/consultant_screens/cnsltSplash.dart';
import 'package:amir_khan1/screens/contractor_screen/contCompanyInfo.dart';
import 'package:amir_khan1/screens/engineer_screens/accountDetails.dart';
import 'package:amir_khan1/auth/signinscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../components/my_button.dart';
import '../components/mytextfield.dart';
import '../helper/helper_functions.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  CreateAccountScreenState createState() => CreateAccountScreenState();
}

class CreateAccountScreenState extends State<CreateAccountScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isChecked = false;
  bool isloading = false;
  String dropdownValue = 'Choose Your Role\n----------------------------';
  List<String> list = ['Choose Your Role\n----------------------------', 'Engineer', 'Consultant','Contractor','Client'];
  void registerUser() async {
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String role = dropdownValue;
    if (password != confirmPassword) {
      displayMessageToUser("Passwords don't match!", context);
      return;
    }
    if (role == 'Choose Your Role') {
      displayMessageToUser("Choose Role", context);
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await createUserDocument(userCredential, false);
      // displayMessageToUser("Account created successfully!", context.mounted as BuildContext);
      navigateToRoleScreen();

      isloading = false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showErrorDialog('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showErrorDialog('The account already exists for that email.');
      }
      setState(() {
        isloading = false;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> createUserDocument(
      UserCredential userCredential, bool isGoogleSignIn) async {
    try {
      if (userCredential.user != null) {
        String docId = isGoogleSignIn
            ? '${userCredential.user!.email}_google'
            : userCredential.user!.email!;
        await FirebaseFirestore.instance.collection("users").doc(docId).set({
          "password": isGoogleSignIn ? '' : passwordController.text,
          "email": userCredential.user!.email,
          'username': isGoogleSignIn
              ? userCredential.user!.displayName
              : usernameController.text,
          'role': dropdownValue,
        });
        Get.snackbar('Success', 'Loged In');
      } else {
        Get.snackbar('Empty', 'Credentials Empty');
      }
    } catch (e) {
      Get.snackbar('Error', '${e}');
    }
  }

  Future<void> navigateToRoleScreen() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get();

      String getRole = await userSnapshot['role'];

      if (getRole == 'Engineer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AccountDetails(),
          ),
        );
      } else if (getRole == 'Consultant') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CnsltCompanyInfo(),
          ),
        );
      }
      else if (getRole == 'Contractor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ContractorCompanyInfo(),
          ),
        );
      }
      else if (getRole == 'Client') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ClientAccountDetails(),
          ),
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void registerWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
        await createUserDocument(userCredential, true);
        navigateToRoleScreen();
      } else {
        Get.snackbar('Empty', 'Tokens are Empty');
      }
    } on FirebaseAuthException catch (e) {
      showErrorDialog('Failed to sign in with Google: ${e.message}');
    } catch (e) {
      showErrorDialog('An error occurred. ${e}');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF455A64),
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 25.0, right: 25.0),
          child: Column(
            children: <Widget>[
              const CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/images/logo1.png'),
                backgroundColor: Colors.transparent,
              ),

              const Text('Create Account',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 30),
              MyTextField(
                hintText: 'Enter your full name',
                obscureText: false,
                controller: usernameController,
                icon: Icons.contacts,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),
              Container(
                height: 58,
                width: 376,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                  color: const Color(0xFFF3F3F3), // Set the background color
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.person_add,color: Colors.grey,),
                    SizedBox(
                      width: 20,
                    ),
                    DropdownButton<String>(
                      borderRadius: BorderRadius.all(Radius.circular(15)),

                      dropdownColor: Colors.white,
                      iconEnabledColor: Colors.grey,
                      value: dropdownValue,
                      //  icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: TextStyle(
                        fontSize: 16,
                        color: dropdownValue == 'Choose Your Role\n----------------------------'
                            ? Colors.grey // Lighter color for initial label
                            : Colors.black, // Darker color for selected value
                      ),
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValue = value!;
                        });
                      },

                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(

                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              MyTextField(
                hintText: 'Enter your email',
                obscureText: false,
                controller: emailController,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              MyTextField(
                hintText: 'Enter your password',
                obscureText: true,
                controller: passwordController,
                icon: Icons.lock,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),
              MyTextField(
                hintText: 'Confirm your password',
                obscureText: true,
                controller: confirmPasswordController,
                icon: Icons.lock,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 5),
              Theme(
                data: ThemeData(unselectedWidgetColor: Colors.green),
                child: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: "I have read and agreed to ",
                            style: TextStyle(
                                fontSize: 16, color: Color(0xff8CAAB9))),
                        TextSpan(
                            text: "Privacy Policy, Terms and Conditions",
                            style:
                            TextStyle(fontSize: 16, color: Colors.green)),
                      ],
                    ),
                  ),
                  activeColor: Colors.green,
                  value: isChecked,
                  onChanged: (newValue) =>
                      setState(() => isChecked = newValue!),
                  checkColor: Colors.black,
                  tileColor: Colors.transparent,
                ),
              ),
              if (!isChecked)
                const Text("Please check the box to proceed.",
                    style: TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              isloading
                  ? Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
                  : MyButton(
                text: 'Sign Up',
                bgColor: Colors.green,
                textColor: Colors.black,
                onTap: () {
                  if (isChecked) {
                    setState(() {
                      isloading = true;
                    });
                    registerUser();
                  }
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 376.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 80, height: 1, color: const Color(0xff8CAAB9)),
                    const SizedBox(width: 15),
                    const Text('Or continue with',
                        style: TextStyle(
                            color: Color(0xff8CAAB9), fontSize: 14.0)),
                    const SizedBox(width: 15),
                    Container(
                        width: 80, height: 1, color: const Color(0xff8CAAB9)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?",
                      style: TextStyle(color: Color(0xff8CAAB9))),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SigninScreen(
                              onTap: () {},
                            ))),
                    child: const Text('Sign in',
                        style: TextStyle(
                            color: Colors.green,
                            decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
