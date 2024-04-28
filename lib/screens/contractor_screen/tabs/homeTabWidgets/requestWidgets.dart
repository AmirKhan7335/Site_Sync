import 'package:amir_khan1/components/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:amir_khan1/notifications/notificationCases.dart';

class ContrPendingRequest extends StatefulWidget {
  ContrPendingRequest(
      {required this.name,
      required this.projectDataList,
      required this.engEmail,
      required this.selectedValue,
      required this.profilePic,
      required this.role,
      super.key});

  String name;
  List projectDataList;
  String engEmail;
  String selectedValue;
  String role;
  String profilePic;

  @override
  State<ContrPendingRequest> createState() => _PendingRequestState();
}

class _PendingRequestState extends State<ContrPendingRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2CF07F),
          // Set the background color to light green
          elevation: 0,
          title: const Text(
            'Pending Requests',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.black, // Set the color of icons to black
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              RequestBody(
                  name: widget.name,
                  projectDataList: widget.projectDataList,
                  profilePic: widget.profilePic,
                  role: widget.role,
                  selectedValue: widget.role,
                  engEmail: widget.engEmail),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 80.0, right: 80, bottom: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.selectedValue == 'Engineer') {
                      FirebaseFirestore.instance
                          .collection('engineers')
                          .doc(widget.engEmail)
                          .update({'reqAccepted': true});

                      //-----------------Send notification
                      NotificationCases().requestAcceptanceorDecline(
                          widget.engEmail, 'Accepted');
                    } else if (widget.selectedValue == 'Client') {
                      FirebaseFirestore.instance
                          .collection('clients')
                          .doc(widget.engEmail)
                          .update({'reqAccepted': true});
                      await FirebaseFirestore.instance
                          .collection("Projects")
                          .doc(widget.projectDataList[3])
                          .update({"clientName": widget.name});
                      //-----------------Send notification
                      NotificationCases().requestAcceptanceorDecline(
                          widget.engEmail, 'Accepted');
                    }
          
                    Navigator.pop(context);
                    setState(() {});
                    Get.snackbar('Request Accepted',
                        '${widget.selectedValue} has been added to the project', backgroundColor: Colors.white, colorText: Colors.black);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(const Color(0xFF2CF07F)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/Frame.png',
                        width: 30, // Adjust width as needed
                        height: 30, // Adjust height as needed
                      ),
                      const SizedBox(width: 10),
                      // Add spacing between image and text
                      const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 80.0, right: 80, bottom: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.selectedValue == 'Engineer') {
                      var activitiesSnapshot = await FirebaseFirestore
                          .instance
                          .collection('engineers')
                          .doc(widget.engEmail)
                          .delete(
                        //FieldPath(['reqAccepted']): FieldValue.delete(),
                      );
                      await FirebaseFirestore.instance
                          .collection('Projects')
                          .doc(widget.projectDataList[3])
                          .update({'isSelected': false});
                      //-----------------Send notification
                      NotificationCases().requestAcceptanceorDecline(
                          widget.engEmail, 'Rejected');
                    } else if (widget.selectedValue == 'Client') {
                      var activitiesSnapshot = await FirebaseFirestore
                          .instance
                          .collection('clients')
                          .doc(widget.engEmail)
                          .delete(
                        //FieldPath(['reqAccepted']): FieldValue.delete(),
                      );
                      if (widget.role != 'Client') {
                        await FirebaseFirestore.instance
                            .collection('Projects')
                            .doc(widget.projectDataList[3])
                            .update({'isClient': false});
                      }
                      //-----------------Send notification
                      NotificationCases().requestAcceptanceorDecline(
                          widget.engEmail, 'Rejected');
                    }
                    Navigator.pop(context);
                    setState(() {});
                    Get.snackbar('Request Rejected', '', backgroundColor: Colors.white, colorText: Colors.black);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(const Color(0xFF2CF07F)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/Vector.png',
                        width: 30, // Adjust width as needed
                        height: 30, // Adjust height as needed
                      ),
                      const SizedBox(width: 10),
                      // Add spacing between image and text
                      const Text(
                        'Reject',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class ContrApprovedRequest extends StatefulWidget {
  ContrApprovedRequest(
      {required this.name,
      required this.projectDataList,
      required this.engEmail,
      required this.selectedValue,
      required this.profilePic,
      required this.role,
      super.key});

  String name;
  List projectDataList;
  String engEmail;
  String selectedValue;
  String role;
  String profilePic;

  @override
  State<ContrApprovedRequest> createState() => _ApprovedRequestState();
}

class _ApprovedRequestState extends State<ContrApprovedRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2CF07F),
          iconTheme: const IconThemeData(
            color: Colors.black, // Set the color of icons to black
          ),
          elevation: 0,
          title: const Text(
            'Approved Requests',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            RequestBody(
              name: widget.name,
              projectDataList: widget.projectDataList,
              selectedValue: widget.role,
              role: widget.role,
              profilePic: widget.profilePic,
              engEmail: widget.engEmail,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 80.0, right: 80, bottom: 20),
              child: ElevatedButton(
                onPressed: () async {
                  if (widget.selectedValue == 'Engineer') {
                    var activitiesSnapshot = await FirebaseFirestore.instance
                        .collection('engineers')
                        .doc(widget.engEmail)
                        .delete();
                    await FirebaseFirestore.instance
                        .collection('Projects')
                        .doc(widget.projectDataList[3])
                        .update({'isSelected': false});
                  } else if (widget.selectedValue == 'Client') {
                    var activitiesSnapshot = await FirebaseFirestore.instance
                        .collection('clients')
                        .doc(widget.engEmail)
                        .delete();
                    if (widget.role != 'Client') {
                      await FirebaseFirestore.instance
                          .collection('Projects')
                          .doc(widget.projectDataList[3])
                          .update({'isClient': false});
                    }
                  }

                  Navigator.pop(context);
                  setState(() {});
                  Get.snackbar('${widget.selectedValue} Deleted', '', backgroundColor: Colors.white, colorText: Colors.black);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF2CF07F)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Vector1.png',
                      width: 30, // Adjust width as needed
                      height: 30, // Adjust height as needed
                    ),
                    const SizedBox(width: 10), // Add spacing between image and text
                    const Text(
                      'Remove',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class RequestBody extends StatefulWidget {
  RequestBody(
      {required this.name,
      required this.projectDataList,
      required this.engEmail,
      required this.profilePic,
      required this.selectedValue,
        required this.role,
      super.key});

  String name;
  List projectDataList;
  String engEmail;
  String selectedValue;
  String profilePic;
  String role;

  @override
  State<RequestBody> createState() => _RequestBodyState();
}

class _RequestBodyState extends State<RequestBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none, // Allow the CircleAvatar to overflow
            children: [
              Container(
                width: double.infinity,
                color: const Color(0xFF2CF07F),
                height: 90, // Adjust height as needed
              ),
              Positioned(
                top: 20,
                // Position half of the CircleAvatar above the green container
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Radius to create a circle
                  child: widget.profilePic != null && widget.profilePic != ""
                      ? ClipOval(
                    child: Image.network(
                      widget.profilePic ,
                      fit: BoxFit.cover, // Adjust the image fitting as needed
                      width: 120, // Adjust width and height as needed
                      height: 120,
                    ),
                  )
                      : ClipOval(
                    child: Image.asset(
                      'assets/images/Ellipse.png',
                      fit: BoxFit.cover, // Adjust the image fitting as needed
                      width: 120, // Adjust width and height as needed
                      height: 120,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 45),
          Text(
            widget.name,
            style: const TextStyle(
                fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 32, top: 16),
            child: Card(
              elevation: 10,
              child: Container(
                width: 270,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          const Text(
                            'Email:  ',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            widget.engEmail,
                            style: const TextStyle(color: Colors.black),
                            softWrap: true,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          const Text(
                            'Role:  ',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            widget.role,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          const Text(
                            'Project :  ',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            '${widget.projectDataList[0]}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          const Text(
                            'Start Date:  ',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            DateFormat('dd-MM-yyyy')
                                .format(widget.projectDataList[1].toDate()),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          const Text(
                            'End Date:  ',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            DateFormat('dd-MM-yyyy')
                                .format(widget.projectDataList[2].toDate()),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
