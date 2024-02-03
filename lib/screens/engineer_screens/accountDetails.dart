import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/screens/engineer_screens/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AccountDetails extends StatefulWidget {
  AccountDetails({super.key});

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  final _formKey = GlobalKey<FormState>();

  bool isloading = false;

  TextEditingController consultantController = TextEditingController();
  String selectedOption = ''; // Store the selected option

  Future<List> fetchProjects() async {
//..
    final collectionData =
        await FirebaseFirestore.instance.collection('Projects').get();
    final userData = collectionData.docs.map(
      (doc) {
        return [
          doc['title'],
        ];
      },
    ).toList();
    return userData;
//..
  }

// Function to show the dropdown
  Future<void> showDropdown(BuildContext context) async {
    String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Select a Project'),
            content: Container(
              height: 400,
              child: FutureBuilder(
                  future: fetchProjects(),
                  builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Colors.blue,
                      ));
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    else if (!snapshot.hasData) {
                      return Text('No Projects ');
                    }
                    
                     else {
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
                                          selectedOption =
                                              projectList[index][0];
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
                      icon: Icons.man,
                      keyboardType: TextInputType.emailAddress,
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
                        onTap: () => showDropdown(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: selectedOption.isEmpty
                              ? 'Select A Project'
                              : selectedOption,
                          hintStyle: TextStyle(
                            color: selectedOption.isEmpty
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
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WelcomeEngineer()));
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
