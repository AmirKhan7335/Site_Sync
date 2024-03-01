import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/screens/engineer_screens/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountDetails extends StatefulWidget {
  AccountDetails({super.key});

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  final _formKey = GlobalKey<FormState>();

  bool isloading = false;
  String consultantEmail = '';
  String consultantUserName = '';
  String selectedProjectId = '';
  TextEditingController consultantController = TextEditingController();
  String selectedProject = ''; // Store the selected option
  Future<void> sendRequestToConsultant(projectId) async {
    final email = FirebaseAuth.instance.currentUser!.email;
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .set({
      'consultantEmail': consultantEmail,
      'projectId': projectId,
      'reqAccepted': false,
      'date': DateTime.now()
    });
    var projectSelected = await FirebaseFirestore.instance
        .collection('Projects')
        .doc(projectId)
        .update({'isSelected': true});
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

  Future<List> fetchProjects(email) async {
//..
    final alreaySelectedProjects =
        await FirebaseFirestore.instance.collection('engineers').get();
    final selectedProject =
        await alreaySelectedProjects.docs.map((e) => e['projectId']).toList();
    final collectionData = await FirebaseFirestore.instance
        .collection('Projects')
        .where('email', isEqualTo: email)
        .where('isSelected', isEqualTo: false)
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
            title: Text('Select a Project'),
            content: Container(
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
                      return Text('No Projects ');
                    } else {
                      final projectList = snapshot.data;
                      return ListView.builder(
                          itemCount: projectList!.length,
                          itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Card(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
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
                                      title: Text('${projectList![index][0]}'),
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
            title: Text('Select Company'),
            content: Container(
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
                      return Text('No Consultant');
                    } else {
                      final consultantList = snapshot.data;
                      return ListView.builder(
                          itemCount: consultantList!.length,
                          itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Card(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
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
                                          Text('${consultantList![index][0]}'),
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
                            const Color(0xFF6B8D9F), // Set the background color
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
                                : Colors.white,
                          ),
                          filled: true, // Ensure that the fillColor is applied
                          fillColor: const Color(
                              0xFF6B8D9F), // Set the fillColor to the same background color
                          prefixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white, // Set icon color to white
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
                            const Color(0xFF6B8D9F), // Set the background color
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
                                : Colors.white,
                          ),
                          filled: true, // Ensure that the fillColor is applied
                          fillColor: const Color(
                              0xFF6B8D9F), // Set the fillColor to the same background color
                          prefixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white, // Set icon color to white
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                    MyButton(
                      text: 'Continue',
                      bgColor: Colors.yellow,
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
                                  builder: (context) => WelcomeEngineer()));
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
