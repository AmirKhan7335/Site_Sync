import 'package:amir_khan1/screens/consultant_screens/cnsltSplash.dart';
import 'package:amir_khan1/screens/contractor_screen/contrHome.dart';
import 'package:amir_khan1/screens/engineer_screens/accountDetails.dart';
import 'package:amir_khan1/screens/engineer_screens/engineerHome.dart';
import 'package:amir_khan1/screens/engineer_screens/welcome.dart';
import 'package:amir_khan1/screens/rolescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../components/my_button.dart';
import '../components/mytextfield.dart';
import 'createaccountscreen.dart';

// Google sign in
Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();
    if (googleSignInAccount == null) {
      return null;
    }

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);

    return authResult.user;
  } catch (e) {
    Get.snackbar('Error', '$e');
    return null;
  }
}

// Sending email
Future<void> sendEmailToUser(String userEmail) async {
  const String senderEmail = '7335@cch.edu.pk.com';
  const String senderPassword = 'P@k12t@9.';

  final smtpServer = gmail(senderEmail, senderPassword);

  final message = Message()
    ..from = const Address(senderEmail, 'Amir Khan')
    ..recipients.add(userEmail)
    ..subject = 'Welcome to Your App'
    ..text = 'Thank you for signing in!';

  try {
    final sendReport = await send(message, smtpServer);
    if (kDebugMode) {
      print('Message sent: $sendReport');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error sending email: $e');
    }
  }
}

// Function to check if the user exists in Firestore
Future<bool> isUserExistsInFirestore(String email) async {
  // Replace 'users' with your Firestore collection name
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email)
      .get();

  return querySnapshot.docs.isNotEmpty;
}

// Sign in Screen
class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key, required this.onTap});

  final void Function()? onTap;

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isloading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  signInWithEmailAndPassword() async {
    try {
      setState(() {
        isloading = true;
      });

      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        showErrorDialog('Enter both email and password.');
        setState(() {
          isloading = false;
        });
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Navigate to home page on successful sign-in
      if (context.mounted) {
        try {
          final user = FirebaseAuth.instance.currentUser;

          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user?.email)
              .get();

          String getRole = await userSnapshot['role'];

          if (getRole == 'Engineer') {
            final user = FirebaseAuth.instance.currentUser;

            var activitiesSnapshot = await FirebaseFirestore.instance
                .collection('engineers')
                .doc(user!.email)
                .get();
            if (activitiesSnapshot.exists) {
              if (activitiesSnapshot.data()!.containsKey('reqAccepted')) {
                final requestStatus = await activitiesSnapshot['reqAccepted'];

                if (requestStatus == true) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EngineerHomePage(isClient: false,),
                    ),
                  );
                } else if (requestStatus == false) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WelcomeEngineer(isClient: false,),
                    ),
                  );
                }
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountDetails(),
                  ),
                );
              }
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountDetails(),
                ),
              );
            }
            setState(() {
              isloading = false;
            });
          } else if (getRole == 'Client') {
            final user = FirebaseAuth.instance.currentUser;

            var activitiesSnapshot = await FirebaseFirestore.instance
                .collection('clients')
                .doc(user!.email)
                .get();
            if (activitiesSnapshot.exists) {
              if (activitiesSnapshot.data()!.containsKey('reqAccepted')) {
                final requestStatus = await activitiesSnapshot['reqAccepted'];

                if (requestStatus == true) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EngineerHomePage(isClient: true,),
                    ),
                  );
                } else if (requestStatus == false) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WelcomeEngineer(isClient: true,),
                    ),
                  );
                }
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountDetails(),
                  ),
                );
              }
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountDetails(),
                ),
              );
            }
            setState(() {
              isloading = false;
            });
          }
          else if (getRole == 'Consultant') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ConsultantSplash(),
              ),
            );
            setState(() {
              isloading = false;
            });
          }
          else if (getRole == 'Contractor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ContractorHomePage(),
              ),
            );
            setState(() {
              isloading = false;
            });
          }
          setState(() {
            isloading = false;
          });
        } catch (e) {
          setState(() {
            isloading = false;
          });
          Get.snackbar('Error', e.toString());
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isloading = false;
      });

      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        // Check if the user exists in Firestore
        bool isUserExists = await isUserExistsInFirestore(emailController.text);

        if (isUserExists) {
          // User exists, display "Invalid password" error
          showErrorDialog('Invalid password.');
          if (kDebugMode) {
            print('Wrong password provided for that user.');
          }
        } else {
          // User not found, display "Invalid email" error
          showErrorDialog('Invalid email.');
          if (kDebugMode) {
            print('No user found for that email.');
          }
        }
      } else {
        showErrorDialog('$e');
        if (kDebugMode) {
          print('Error: ${e.message}');
        }
      }
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(context) {
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
                      radius: 80,
                      backgroundImage: AssetImage('assets/images/logo1.png'),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Sign in to continue',
                          style: TextStyle(fontSize: 21.0, color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Email Address',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'Enter your email',
                      obscureText: false,
                      controller: emailController,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 5),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Password',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'Enter your password',
                      obscureText: true,
                      controller: passwordController,
                      icon: Icons.lock,
                      keyboardType: TextInputType.text,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Add your logic for when the "Forgot Password" button is pressed.
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      text: 'Log in',
                      bgColor: Colors.green,
                      textColor: Colors.black,
                      icon: Icons.login,
                      onTap: () {
                        signInWithEmailAndPassword();
                      },
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 376.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 1,
                            color: const Color(0xff8CAAB9),
                          ),
                          const SizedBox(width: 15),
                          const Text(
                            'Or continue with',
                            style: TextStyle(
                              color: Color(0xff8CAAB9),
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Container(
                            width: 80,
                            height: 1,
                            color: const Color(0xff8CAAB9),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    MyButton(
                      text: 'Sign in with Google',
                      bgColor: Colors.blue,
                      textColor: Colors.white,
                      icon: Icons.account_circle,
                      onTap: () async {
                        User? user = await signInWithGoogle();
                        if (user != null) {
                          await sendEmailToUser(user.email!);
                          // Navigate to home page after Google sign-in
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Role(),
                              ),
                            );
                            //isloading = false;
                          }
                          //isloading = false;
                        }
                        //isloading=false;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CreateAccountScreen(
                                onTap: () {},
                              );
                            }));
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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
