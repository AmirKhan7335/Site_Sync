import 'package:amir_khan1/screens/consultant_screens/widgets/requestWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  @override
  void initState() {
    super.initState();
  }

  String _selectedValue = 'Engineer';

  Future<List<List>> getApprovedClientRequests() async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('clients')
          .where('consultantEmail', isEqualTo: email)
          .where('reqAccepted', isEqualTo: true)
          .get();
      final engineerEmail = activitiesSnapshot.docs.map(
            (doc) {
          return [doc.id, doc['projectId']];
        },
      ).toList();
      final nameEmail = [];
      final project = [];

      for (var i in engineerEmail) {
        nameEmail.add(i[0]);
        project.add(i[1]);
      }
      final getProject = await getProjectDetail(project);
      final getNames = await getEngineerUserName(nameEmail);
      final getProfilePic = await getEngineerProfilePicUrl(nameEmail);
      final getCompanyNames = await getCompanyName(nameEmail);

      return [getProject, getNames, nameEmail, getProfilePic, getCompanyNames];
    } catch (e) {
      Get.snackbar('Error ', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      print("Error: $e");
      return [[]];
    }
  }


  Future<List<List>> getPendingClientRequests() async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('clients')
          .where('consultantEmail', isEqualTo: email)
          .where('reqAccepted', isEqualTo: false)
          .get();

      final engineerEmail = activitiesSnapshot.docs.map(
            (doc) {
          return [doc.id, doc['projectId']];
        },
      ).toList();
      final nameEmail = [];
      final project = [];

      for (var i in engineerEmail) {
        nameEmail.add(i[0]);
        project.add(i[1]);
      }

      final getProject = await getProjectDetail(project);
      final getNames = await getEngineerUserName(nameEmail);
      final getProfilePic = await getEngineerProfilePicUrl(nameEmail);
      final getCompanyNames = await getCompanyName(nameEmail);

      return [getProject, getNames, nameEmail, getProfilePic, getCompanyNames];
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      return [[]];
    }
  }


  Future<List<List>> getPendingContrRequests() async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;

// Contractor Contributions-------------------------------------
      final contrRequest = await FirebaseFirestore.instance
          .collection('contractorReq')
          .where('consultantEmail', isEqualTo: email)
          .where('reqAccepted', isEqualTo: false)
          .get();

      final contrEmail = contrRequest.docs.map(
            (doc) {
          return [doc['contractorEmail'], doc['projectId']];
        },
      ).toList();
//===============================================================
      final nameEmail = [];
      final project = [];

      for (var i in contrEmail) {
        nameEmail.add(i[0]);
        project.add(i[1]);
      }

      final getProject = await getProjectDetail(project);
      final getNames = await getEngineerUserName(nameEmail);
      final getProfilePic = await getEngineerProfilePicUrl(nameEmail);
      final getCompanyNames = await getCompanyName(nameEmail);

      return [getProject, getNames, nameEmail, getProfilePic, getCompanyNames];
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      return [[]];
    }
  }

  Future<List<List>> getApprovedContrRequests() async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;

// Contractor Contributions-------------------------------------
      final contrRequest = await FirebaseFirestore.instance
          .collection('contractorReq')
          .where('consultantEmail', isEqualTo: email)
          .where('reqAccepted', isEqualTo: true)
          .get();

      final contrEmail = contrRequest.docs.map(
            (doc) {
          return [doc['contractorEmail'], doc['projectId']];
        },
      ).toList();
//===============================================================
      final nameEmail = [];
      final project = [];

      for (var i in contrEmail) {
        nameEmail.add(i[0]);
        project.add(i[1]);
      }

      final getProject = await getProjectDetail(project);
      final getNames = await getEngineerUserName(nameEmail);
      final getProfilePic = await getEngineerProfilePicUrl(nameEmail);
      final getCompanyNames = await getCompanyName(nameEmail);

      return [getProject, getNames, nameEmail, getProfilePic, getCompanyNames];
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      return [[]];
    }
  }

  Future<List<List>> getPendingRequests() async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .where('consultantEmail', isEqualTo: email)
          .where('reqAccepted', isEqualTo: false)
          .get();

      final engineerEmail = activitiesSnapshot.docs.map(
            (doc) {
          return [doc.id, doc['projectId']];
        },
      ).toList();
      final nameEmail = [];
      final project = [];

      for (var i in engineerEmail) {
        nameEmail.add(i[0]);
        project.add(i[1]);
      }

      final getProject = await getProjectDetail(project);
      final getNames = await getEngineerUserName(nameEmail);
      final getProfilePic = await getEngineerProfilePicUrl(nameEmail);
      final getCompanyNames = await getCompanyName(nameEmail);

      return [getProject, getNames, nameEmail, getProfilePic, getCompanyNames];
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      return [[]];
    }
  }

  Future<List<List>> getApprovedRequests() async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .where('consultantEmail', isEqualTo: email)
          .where('reqAccepted', isEqualTo: true)
          .get();
      final engineerEmail = activitiesSnapshot.docs.map(
            (doc) {
          return [doc.id, doc['projectId']];
        },
      ).toList();
      final nameEmail = [];
      final project = [];

      for (var i in engineerEmail) {
        nameEmail.add(i[0]);
        project.add(i[1]);
      }
      final getProject = await getProjectDetail(project);
      final getNames = await getEngineerUserName(nameEmail);
      final getProfilePic = await getEngineerProfilePicUrl(nameEmail);
      final getCompanyNames = await getCompanyName(nameEmail);

      return [getProject, getNames, nameEmail, getProfilePic, getCompanyNames];
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      return [[]];
    }
  }

  getEngineerUserName(List emails) async {
    try {
      var activitiesSnapshot =
      await FirebaseFirestore.instance.collection('users');
      final namesList = await Future.wait(emails.map((mail) async {
        final name = await activitiesSnapshot.doc(mail).get();

        return name['username'];
      }).toList());

      return namesList;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }
  getCompanyName(List emails) async {
    try {
      var activitiesSnapshot = await FirebaseFirestore.instance.collection('users');
      final namesList = await Future.wait(emails.map((mail) async {
        final companyNameDoc = await activitiesSnapshot.doc(mail).get();
        // Check if 'companyName' field exists and has a value
        if (companyNameDoc.exists &&
            companyNameDoc.data()!.containsKey('companyName') &&
            companyNameDoc['companyName'] != null) {
          return companyNameDoc['companyName'];
        } else {
          return 'Amir'; // Default value if companyName is missing
        }
      }).toList());
      return namesList;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }
  getEngineerProfilePicUrl(List emails) async {
    try {
      var activitiesSnapshot = await FirebaseFirestore.instance.collection('users');
      final profilepicList = await Future.wait(emails.map((mail) async {
        final profilepicDoc = await activitiesSnapshot.doc(mail).get();
        // Check if the document exists and has the 'profilePic' field
        if (profilepicDoc.exists && profilepicDoc.data()!.containsKey('profilePic')) {
          return profilepicDoc['profilePic'];
        } else {
          return ""; // Return null for missing profilePic
        }
      }).toList());

      return profilepicList;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  getProjectDetail(List projectIds) async {
    try {
      final projects = FirebaseFirestore.instance.collection('Projects');
      final projectDataList = await Future.wait(projectIds.map(
            (Ids) async {
          final doc = await projects.doc(Ids).get();

          if (doc.exists) { // Check if the document exists
            return [doc['title'], doc['startDate'], doc['endDate'], doc.id];
          } else {
            return ["","","",""]; // Or handle the missing document case as needed
          }
        },
      ).toList());

      return projectDataList;
    } catch (e) {
      Get.snackbar('Error ', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
      print("Error: $e");
    }
  }

  getRole(email) async {
    final query =
    await FirebaseFirestore.instance.collection('users').doc(email).get();
    final role = await query.data()!['role'];

    return role;
  }

  bool isPending = true;
  Widget pendingRequests() {
    return FutureBuilder(
        future: _selectedValue == 'Contractor'
            ? getPendingContrRequests()
            : _selectedValue == 'Engineer'
            ? getPendingRequests()
            :
        //      _selectedValue == 'Client'?
        getPendingClientRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final data = snapshot.data;

            return ListView.builder(
                itemCount: data![0].length,
                itemBuilder: (context, index) => ListTile(
                  onTap: () async {
                    final name = await data[1][index];
                    final project = await data[0][index];
                    final email = await data[2][index];
                    final profilePic = await data[3][index];
                    final companyName = await data[4][index];
                    final role = await getRole(email);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PendingRequest(
                                name: name,
                                projectDataList: project,
                                engEmail: email,
                                profilePic: profilePic,
                                companyName: companyName,
                                selectedValue:_selectedValue,
                                role: role // Pass the role
                            )));
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Radius to create a circle
                    child: data[3][index] != null && data[3][index] != ""
                        ? ClipOval(
                      child: Image.network(
                        data[3][index] as String,
                        fit: BoxFit.cover, // Adjust the image fitting as needed
                        width: 60, // Adjust width and height as needed
                        height: 60,
                      ),
                    )
                        : ClipOval(
                      child: Image.asset(
                        'assets/images/Ellipse.png',
                        fit: BoxFit.cover, // Adjust the image fitting as needed
                        width: 60, // Adjust width and height as needed
                        height: 60,
                      ),
                    ),
                  ),
                  title: Text('${data[1][index]}',
                      style: const TextStyle(color: Colors.black)),
                  subtitle: const Text('Hi, please approve my role',
                      style: TextStyle(color: Colors.black)),
                  trailing: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('8 Nov'),
                      Icon(
                        Icons.star,
                        color: Colors.green,
                        size: 10,
                      ),
                    ],
                  ),
                ));
          } else {
            return const Text('No Data');
          }
        });
  }

  Widget approvedRequests() {
    return FutureBuilder(
        future: _selectedValue == 'Contractor'
            ? getApprovedContrRequests()
            : _selectedValue == 'Engineer'
            ? getApprovedRequests()
            :
        //      _selectedValue == 'Client'?
        getApprovedClientRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final data = snapshot.data;
            return ListView.builder(
                itemCount: data![0].length,
                itemBuilder: (context, index) => ListTile(
                  onTap: () async {
                    final role = await getRole(data[2][index]);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ApprovedRequest(
                                  name: data[1][index],
                                  projectDataList: data[0][index],
                                  engEmail: data[2][index],
                                  profilePic: data[3][index],
                                  selectedValue: _selectedValue,
                                  role: role,
                                )));
                  },
                  leading: SizedBox(
                    width: 60,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Radius to create a circle
                      child: data[3][index] != null && data[3][index] != ""
                          ? ClipOval(
                        child: Image.network(
                          data[3][index] as String,
                          fit: BoxFit.cover, // Adjust the image fitting as needed
                          width: 60, // Adjust width and height as needed
                          height: 60,
                        ),
                      )
                          : ClipOval(
                        child: Image.asset(
                          'assets/images/Ellipse.png',
                          fit: BoxFit.cover, // Adjust the image fitting as needed
                          width: 60, // Adjust width and height as needed
                          height: 60,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    '${data[1][index]}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    '${data[0][index][0]}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailing: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        '08/01/2023',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ));
          } else {
            return const Text(
              'No Data',
              style: TextStyle(color: Colors.black),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Requests',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: const Color(0xffFBFBFB),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xffFBFBFB),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 10,
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isPending ? const Color(0xff3EED88) : Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (isPending == false) {
                              setState(() {
                                isPending = true;
                              });
                            }
                          },
                          child: const Center(
                            child: Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Card(
                      elevation: 10,
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          color: !isPending ? const Color(0xff3EED88) : Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (isPending == true) {
                              setState(() {
                                isPending = false;
                              });
                            }
                          },
                          child: const Center(
                            child: Text(
                              'Approved',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Center the radio buttons horizontally
                children: [
                  Radio<String>(
                    activeColor: Colors.green,
        
                    fillColor: MaterialStateProperty.all(Colors.green),
                    value:
                    'Engineer', // Value associated with the Consultant radio button
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
                    'Engineer',
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
                              .black)),
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 60,
                  ),
                  Radio<String>(
                    activeColor: Colors.green,
                    fillColor: MaterialStateProperty.all(Colors.green),
                    value:
                    'Client', // Value associated with the Contractor radio button
                    groupValue: _selectedValue,
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value!;
                      });
                    },
                  ),
                  const Text('Client and Others',
                      style: TextStyle(
                          color: Colors
                              .black)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8, left: 8, bottom: 8),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: isPending ? pendingRequests() : approvedRequests(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
