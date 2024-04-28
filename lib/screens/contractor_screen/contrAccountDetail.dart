import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/screens/contractor_screen/contrHome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../notifications/notificationCases.dart';
import '../../notifications/notification_services.dart';

class ContrAccountDetails extends StatefulWidget {
  ContrAccountDetails({super.key});

  @override
  State<ContrAccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<ContrAccountDetails> {
  final _formKey = GlobalKey<FormState>();
  NotificationServices notificationServices = NotificationServices();

  bool isloading = false;
  String consultantEmail = '';
  String consultantUserName = '';
  String selectedProjectId = '';
  TextEditingController consultantController = TextEditingController();
  String selectedProject = ''; // Store the selected option

  // Index of the selected tab
  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupToken();
    notificationServices.setupInteractMessage(context);

  }

  Future<void> sendRequestToConsultant(projectId) async {
    final email = FirebaseAuth.instance.currentUser!.email;
    var requests =
    await FirebaseFirestore.instance.collection('contractorReq').doc().set({
      'consultantEmail': consultantEmail,
      'contractorEmail': email,
      'projectId': projectId,
      'reqAccepted': false,
      'date': DateTime.now()
    });
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('contractor')
        .doc(email)
        .collection('projects')
        .doc()
        .set({
      'consultantEmail': consultantEmail,
      'projectId': projectId,
      'reqAccepted': false,
      'date': DateTime.now()
    });
    var activitiesSnapshot1 = await FirebaseFirestore.instance
        .collection('contractors')
        .doc(projectId)
        .set({
      'consultantEmail': consultantEmail,
      'projectId': projectId,
      'reqAccepted': false,
      'date': DateTime.now()
    });
    var projectSelected = await FirebaseFirestore.instance
        .collection('Projects')
        .doc(projectId)
        .update({'isContrSelected': true});
    //-----------Request Notification to Consultant----------------
    NotificationCases()
        .requestToConsultantNotification('Contractor', consultantEmail, email!);
  }

  Future<List> fetchConsultant() async {
//..
    try {
      final collectionData = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Consultant')
          .get();

      final userData = collectionData.docs
          .map((doc) {
        if (doc.data().containsKey('companyName')) {
          return [doc['companyName'], doc['email']];
        } else {
          return null;
          // Return null for documents without the 'companyName' field
        }
      })
          .where((data) => data != null) // Filter out null values
          .toList();
      return userData;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      return [];
    }
//..
  }

  Future<List> fetchProjects(email) async {
//..
    // final alreaySelectedProjects =
    //     await FirebaseFirestore.instance.collection('engineers').get();
    // final selectedProject =
    //     await alreaySelectedProjects.docs.map((e) => e['projectId']).toList();
    final collectionData = await FirebaseFirestore.instance
        .collection('Projects')
        .where('email', isEqualTo: email)
        .where('isContrSelected', isEqualTo: false)
        .get();

    final userData = collectionData.docs.map(
          (doc) {
        return [doc['title'], doc.id];
      },
    ).toList();
    return userData;
//..
  }

// Function to show the dropdown
  Future<void> showProjects(BuildContext context) async {
    String? selected2 = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
            title: const Text('Select a Project', style: TextStyle(color: Colors.black)),
            content: SizedBox(
              height: 400,
              child: FutureBuilder(
                  future: fetchProjects(consultantEmail),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ));
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return const Text('No Projects ', style: TextStyle(color: Colors.black));
                    } else {
                      final projectList = snapshot.data;
                      return ListView.builder(
                          itemCount: projectList!.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAEAEA),
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      selectedProject =
                                      projectList[index][0];
                                      selectedProjectId =
                                      projectList[index][1];
                                    });
                                    Navigator.pop(context);
                                  },
                                  title: Text('${projectList[index][0]}', style: TextStyle(color: Colors.black)),
                                ),
                              ),
                            ),
                          ));
                    }
                  }),
            ));
      },
    );
  }

  Future<void> showConsultant(BuildContext context) async {
    String? selected1 = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
            title: const Text('Select Company', style: TextStyle(color: Colors.black)),
            content: SizedBox(
              height: 400,
              child: FutureBuilder(
                  future: fetchConsultant(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ));
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return const Text('No Consultant', style: TextStyle(color: Colors.black));
                    } else {
                      final consultantList = snapshot.data;
                      return ListView.builder(
                          itemCount: consultantList!.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAEAEA),
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      consultantUserName =
                                      consultantList[index][0];
                                      consultantEmail =
                                      consultantList[index][1];
                                    });

                                    Navigator.pop(context);
                                  },
                                  title:
                                  Text('${consultantList[index][0]}', style: TextStyle(color: Colors.black)),
                                ),
                              ),
                            ),
                          ));
                    }
                  }),
            ));
      },
    );
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
                          'New Project',
                          style: TextStyle(fontSize: 21.0, color: Colors.black),
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
                          'Company',
                          style:
                          TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      child: Container(
                        height: 58,
                        width: 376,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          color: const Color(0xFFF3F3F3),// Set the background color
                        ),
                        child: TextFormField(
                          readOnly: true,
                          onTap: () {
                            showConsultant(context);
                            setState(() {});
                          },
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: consultantUserName.isEmpty
                                ? 'Select Company'
                                : consultantUserName,
                            hintStyle: TextStyle(
                              color: consultantUserName.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                            filled: true, // Ensure that the fillColor is applied
                            fillColor: const Color(0xFFF3F3F3), // Set the fillColor to the same background color
                            prefixIcon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black, // Set icon color to white
                            ),
                          ),
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
                          'Project',
                          style:
                          TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      child: Container(
                        height: 58,
                        width: 376,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          color:
                          const  Color(0xFFF3F3F3), // Set the background color
                        ),
                        child: TextFormField(
                          readOnly: true,
                          onTap: () {
                            if (consultantEmail != '') {
                              showProjects(context);
                            } else {
                              Get.snackbar("Sorry", 'Select Consultant First', backgroundColor: Colors.white, colorText: Colors.black);
                            }
                          },
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: selectedProject.isEmpty
                                ? 'Select A Project'
                                : selectedProject,
                            hintStyle: TextStyle(
                              color: selectedProject.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                            filled: true, // Ensure that the fillColor is applied
                            fillColor: const Color(0xFFF3F3F3),// Set the fillColor to the same background color
                            prefixIcon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black, // Set icon color to white
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ContractorHomePage()));
                          },
                          style: const ButtonStyle(),
                          child: const Text(
                            'Skip',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    MyButton(
                      text: 'Continue',
                      bgColor: Color(0xFF2CF07F),
                      textColor: Colors.black,
                      onTap: () async {
                        if (consultantEmail == '' || selectedProject == '') {
                          Get.snackbar('Sorry', 'Please Select All Fields', backgroundColor: Colors.white, colorText: Colors.black);
                        } else {
                          setState(() {
                            isloading = true;
                          });
                          await sendRequestToConsultant(selectedProjectId);
                          setState(() {
                            isloading = false;
                          });
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ContractorHomePage()));
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
