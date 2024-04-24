import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/screens/engineer_screens/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amir_khan1/notifications/notificationCases.dart';
import 'package:amir_khan1/notifications/notification_services.dart';

class ClientAccountDetails extends StatefulWidget {
  ClientAccountDetails({required bool this.otherRole, super.key});
  bool otherRole;
  @override
  State<ClientAccountDetails> createState() => _ClientAccountDetailsState();
}

class _ClientAccountDetailsState extends State<ClientAccountDetails> {
  final _formKey = GlobalKey<FormState>();
  String _selectedValue = 'Consultant';
  bool isloading = false;
  String consultantEmail = '';
  String consultantUserName = '';
  String selectedProjectId = '';
  TextEditingController consultantController = TextEditingController();
  String selectedProject = ''; // Store the selected option
  NotificationServices notificationServices = NotificationServices();

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
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('clients')
        .doc(email)
        .set({
      'consultantEmail': consultantEmail,
      'projectId': projectId,
      'reqAccepted': false,
      'date': DateTime.now()
    });
    if (widget.otherRole == false) {
      var projectSelected = await FirebaseFirestore.instance
          .collection('Projects')
          .doc(projectId)
          .update({'isClient': true});
    }
    NotificationCases().requestToConsultantNotification(widget.otherRole ? 'A New Role' : 'Client', consultantEmail, email!);
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
          return null; // Return null for documents without the 'companyName' field
        }
      })
          .where((data) => data != null) // Filter out null values
          .toList();
      return userData;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
//..
  }
  Future<List> fetchContractor() async {
//..
    try {
      final collectionData = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Contractor')
          .get();

      final userData = collectionData.docs
          .map((doc) {
        if (doc.data().containsKey('companyName')) {
          return [doc['companyName'], doc['email']];
        } else {
          return null; // Return null for documents without the 'companyName' field
        }
      })
          .where((data) => data != null) // Filter out null values
          .toList();
      return userData;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
//..
  }

  Future<List> fetchProjects(email) async {
//..
    final alreaySelectedProjects =
    await FirebaseFirestore.instance.collection('engineers').get();
    final selectedProject =
    await alreaySelectedProjects.docs.map((e) => e['projectId']).toList();
    final collectionData = widget.otherRole
        ? await FirebaseFirestore.instance
        .collection('Projects')
        .where('email', isEqualTo: email)
        .get()
        : await FirebaseFirestore.instance
        .collection('Projects')
        .where('email', isEqualTo: email)
        .where('isClient', isEqualTo: false)
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
                      return const Text('No Projects ');
                    } else {
                      final projectList = snapshot.data;
                      return ListView.builder(
                          itemCount: projectList!.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: Colors.grey,
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
                                  title: Text('${projectList![index][0]}', style: const TextStyle(color: Colors.white)),
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
                  future: _selectedValue=='Consultant'? fetchConsultant():fetchContractor(),
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
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: Colors.grey,
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
                                  Text('${consultantList![index][0]}', style: const TextStyle(color: Colors.white)),
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 25.0,
                top: 0.0,
                right: 25.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: const AssetImage('assets/images/logo1.png'),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Select Project',
                          style: TextStyle(fontSize: 21.0, color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center the radio buttons horizontally
                      children: [
                        Radio<String>(
                          activeColor: Colors.green,

                          fillColor: MaterialStateProperty.all(Colors.green),
                          value:
                          'Consultant', // Value associated with the Consultant radio button
                          groupValue:
                          _selectedValue, // This variable should hold the currently selected value
                          onChanged: (value) {
                            setState(() {
                              // Update the state when the radio button is selected
                              _selectedValue = value!;
                            });
                          },
                        ),
                        const Text(
                          'Consultant',
                          style: TextStyle(color: Colors.black),
                        ), // Label for the Consultant radio button
                        const SizedBox(
                            width:
                            20), // Add some spacing between radio button and label
                        Radio<String>(
                          activeColor: Colors.green,
                          fillColor: MaterialStateProperty.all(Colors.green),
                          value:
                          'Contractor', // Value associated with the Contractor radio button
                          groupValue: _selectedValue,
                          onChanged: (value) {
                            setState(() {
                              _selectedValue = value!;
                            });
                          },
                        ),
                        const Text('Contractor',
                            style: TextStyle(
                                color: Colors
                                    .black)), // Label for the Contractor radio button
                      ],
                    ),
                    const SizedBox(height: 20),
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
                    Container(
                      height: 58,
                      width: 376,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        color:
                        const Color(0xFFF3F3F3), // Set the background color
                      ),
                      child: TextFormField(
                        readOnly: true,
                        onTap: () {
                          showConsultant(context);
                          setState(() {});
                        },
                        style: const TextStyle(
                          color: Colors.white,
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
                          filled: false, // Ensure that the fillColor is applied
                          fillColor: const Color(
                              0xFF6B8D9F), // Set the fillColor to the same background color
                          prefixIcon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey, // Set icon color to white
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
                    Container(
                      height: 58,
                      width: 376,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        color:
                        const Color(0xFFF3F3F3), // Set the background color
                      ),
                      child: TextFormField(
                        readOnly: true,
                        onTap: () {
                          if (consultantEmail != '') {
                            showProjects(context);
                          } else {
                            Get.snackbar("Sorry", 'Select Company First');
                          }
                        },
                        style: const TextStyle(
                          color: Colors.white,
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
                          filled: false, // Ensure that the fillColor is applied
                          fillColor: const Color(
                              0xFF6B8D9F), // Set the fillColor to the same background color
                          prefixIcon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey, // Set icon color to white
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                    MyButton(
                      text: 'Continue',
                      bgColor: Colors.green,
                      textColor: Colors.black,
                      onTap: () async {
                        if (consultantEmail == '' || selectedProject == '') {
                          Get.snackbar('Sorry', 'Please Select All Fields');
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
                                  builder: (context) => WelcomeEngineer(isClient:true)));
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
