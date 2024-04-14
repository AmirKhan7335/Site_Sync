import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/screens/contractor_screen/contrAccountDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContractorCompanyInfo extends StatefulWidget {
  const ContractorCompanyInfo({super.key});

  @override
  State<ContractorCompanyInfo> createState() => _CompanyInfoState();
}

class _CompanyInfoState extends State<ContractorCompanyInfo> {
  final _formKey = GlobalKey<FormState>();
  bool isloading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController ownerController = TextEditingController();
  TextEditingController typeController = TextEditingController();
 // TextEditingController emailController = TextEditingController();
  TextEditingController officeController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    ownerController.dispose();
    typeController.dispose();
   // emailController.dispose();
    officeController.dispose();
    super.dispose();
  }
  addDatatoDatabase() async {
    try {
      final email = await FirebaseAuth.instance.currentUser!.email;
      
      await FirebaseFirestore.instance.collection("users").doc(email).update({
        'companyName': nameController.text,
        'owner': ownerController.text,
        'type': typeController.text,
        'office': officeController.text
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
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
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Company Info',
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
                          'Company Name',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'ARCO',
                      obscureText: false,
                      controller: nameController,
                      icon: Icons.title,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Owner',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'Amir Khan',
                      obscureText: false,
                      controller: ownerController,
                      icon: Icons.person_2,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Type',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'A6',
                      obscureText: false,
                      controller:typeController,
                      icon: Icons.space_bar,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    // const SizedBox(
                    //   height: 25,
                    //   width: double.infinity,
                    //   child: Padding(
                    //     padding: EdgeInsets.only(left: 6.0),
                    //     child: Text(
                    //       'Email',
                    //       style:
                    //           TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                    //       textAlign: TextAlign.left,
                    //     ),
                    //   ),
                    // ),
                    // MyTextField(
                    //   hintText: 'arco@gmail.com',
                    //   obscureText: false,
                    //   controller: emailController,
                    //   icon: Icons.email,
                    //   keyboardType: TextInputType.text,
                    // ),
                    // const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Office',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'F7 Islamabad',
                      obscureText: false,
                      controller: officeController,
                      icon: Icons.location_searching,
                      keyboardType: TextInputType.text,
                    ),
                    
                    
                    const SizedBox(height: 50),
                    MyButton(
                      text: 'Confirm',
                      bgColor: Colors.green,
                      textColor: Colors.black,
                      onTap: () { if (nameController.text.isNotEmpty &&
                            typeController.text.isNotEmpty &&
                            officeController.text.isNotEmpty) {
                          setState(() {
                            isloading = true;
                          });
                          addDatatoDatabase();
                          setState(() {
                            isloading = false;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContrAccountDetails()));
                        } else {
                          Get.snackbar('Sorry', 'Please Fill All the Fields');
                        }},
                    ),
                    const SizedBox(height: 20),
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
