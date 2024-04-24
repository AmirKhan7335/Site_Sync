import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/controllers/navigationController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amir_khan1/notifications/notificationCases.dart';
import 'cnslt office google maps screen/googlemapsscreen.dart';
import 'cnslt office text field/cnsltofficetxtfield.dart';

class CreateProject extends StatefulWidget {
  const CreateProject({super.key});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final _formKey = GlobalKey<FormState>();
  bool isloading = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController budgetController = TextEditingController();

  TextEditingController fundingController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController retMoneyController = TextEditingController();

  DateTime? selectedDate;
  DateTime? endDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _endDate(BuildContext context) async {
    final DateTime? pick = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pick != null && pick != endDate) {
      setState(() {
        endDate = pick;
      });
    }
  }

  Future<void> uploadProjectToFirebase() async {
    try {
      var email = FirebaseAuth.instance.currentUser!.email;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var projectsCollection = firestore.collection('Projects').doc();
      await projectsCollection.set(
        {
          'title': titleController.text,
          'budget': budgetController.text,
          'startDate': selectedDate,
          'endDate': endDate,
          'funding': fundingController.text,
          'location': locationController.text,
          'email': email,
          'creationDate': DateTime.now(),
          'isSelected': false,
          'retMoney': retMoneyController.text,
          'isContrSelected': false,
          'isClient': false
        },
      );

      final testing = await projectsCollection.collection('testing');
      await testing.doc('Bearing Capacity Test').set({});
      await testing.doc('Standard Penetration Test').set({});
      await testing.doc('Soil Investigation Report').set({});
      await testing.doc('Tensile Strength Test').set({});
      await testing.doc('Brick Strength Test').set({});
      await testing.doc('Compressive Strength Test').set({});


      Get.snackbar('Success', 'Project created Successfully');
      titleController.clear();
      budgetController.clear();
      retMoneyController.clear();
      fundingController.clear();
      locationController.clear();
    } catch (e) {
      Get.snackbar("Error", '${e}');
    }
  }

  void dispose() {
    titleController.dispose();
    budgetController.dispose();
    retMoneyController.dispose();
    fundingController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Container(
      child: Stack(
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
                          'Create New Project',
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
                          'Project Title',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'Construction of ABC',
                      obscureText: false,
                      controller: titleController,
                      icon: Icons.title,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Total Cost',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'Rs 100,000,000',
                      obscureText: false,
                      controller: budgetController,
                      icon: Icons.money,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Retention Money',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'Rs 100,000,000',
                      obscureText: false,
                      controller: retMoneyController,
                      icon: Icons.money,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Start Date',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    //---------------
                    MyDateField(
                        hintText: selectedDate == null
                            ? 'Select a date'
                            : '${selectedDate!.toLocal()}'.split(' ')[0],
                        callback: _selectDate),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'End Date',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    //----------------
                    MyDateField(
                        hintText: endDate == null
                            ? 'Select a date'
                            : '${endDate!.toLocal()}'.split(' ')[0],
                        callback: _endDate),

                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Funding',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'self generated',
                      obscureText: false,
                      controller: fundingController,
                      icon: Icons.man,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Location',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    // MyTextField(
                    //   hintText: 'NUST',
                    //   obscureText: false,
                    //   controller: locationController,
                    //   icon: Icons.location_searching,
                    //   keyboardType: TextInputType.text,
                    // ),
                    MyTextFieldConsultant(
                      hintText: 'NUST',
                      controller: locationController,
                      icon: Icons.location_searching,
                      onTapIcon: () async {
                        final String? selectedLocation =
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GoogleMapsScreen(),
                          ),
                        );
                        if (selectedLocation != null) {
                          locationController.text = selectedLocation;
                        }
                      },
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 50),
                    MyButton(
                      text: 'Confirm',
                      bgColor: Colors.green,
                      textColor: Colors.black,
                      onTap: () {
                        if (titleController.text.isEmpty ||
                            budgetController.text.isEmpty ||
                            retMoneyController.text.isEmpty ||
                            selectedDate == null ||
                            endDate == null ||
                            fundingController.text.isEmpty ||
                            locationController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Please fill all the fields')));
                        } else {
                          setState(() {
                            isloading = true;
                          });

                          uploadProjectToFirebase();
                          titleController.clear;
                          budgetController.clear;
                          fundingController.clear;
                          locationController.clear;
                          setState(() {
                            isloading = false;
                          });
                          controller.cnsltCurrentIndex.value = 0;
                        }
                      },
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
