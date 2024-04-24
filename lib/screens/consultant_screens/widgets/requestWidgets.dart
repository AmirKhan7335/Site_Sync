import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:amir_khan1/notifications/notificationCases.dart';

class PendingRequest extends StatefulWidget {
  PendingRequest(
      {required this.name,
      required this.projectDataList,
      required this.engEmail,
      required this.selectedValue,
        required this.profilePic,
        required this.role,
      super.key});

  String name;
  String profilePic;
  List projectDataList;
  String engEmail;
  String selectedValue;
  String role;
  @override
  State<PendingRequest> createState() => _PendingRequestState();
}

class _PendingRequestState extends State<PendingRequest> {
  confirmContrReq() async {
    try {
      print('1');
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('contractorReq')
          .where('projectId', isEqualTo: widget.projectDataList[3])
          .get();
      await FirebaseFirestore.instance
          .collection('Projects')
          .doc(widget.projectDataList[3])
          .update({"contractorName": widget.name});
      var list = activitiesSnapshot.docs.map((e) {
        var update = FirebaseFirestore.instance
            .collection('contractorReq')
            .doc(e.id)
            .update({'reqAccepted': true});
        var update1 = FirebaseFirestore.instance
            .collection('contractors')
            .doc(widget.projectDataList[3])
            .update({'reqAccepted': true});

        return update;
      }).toList();

      var updateLongQuery = await FirebaseFirestore.instance
          .collection('contractor')
          .doc(widget.engEmail)
          .collection('projects')
          .where('projectId', isEqualTo: widget.projectDataList[3])
          .get();
      var longList = updateLongQuery.docs.map((e) async {
        var accept_req = await FirebaseFirestore.instance
            .collection('contractor')
            .doc(widget.engEmail)
            .collection('projects')
            .doc(e.id)
            .update({'reqAccepted': true});
        return accept_req;
      }).toList();
      //-----------------Send notification
      NotificationCases()
          .requestAcceptanceorDecline(widget.engEmail, 'Accepted');
    } catch (e) {}
  }

  rejecContrReq() async {
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('contractorReq')
        .where('projectId', isEqualTo: widget.projectDataList[3])
        .get();
    var list = activitiesSnapshot.docs.map((e) async {
      var update = await FirebaseFirestore.instance
          .collection('contractorReq')
          .doc(e.id)
          .delete();
      return update;
    }).toList();
    var updateLongQuery = await FirebaseFirestore.instance
        .collection('contractor')
        .doc(widget.engEmail)
        .collection('projects')
        .where('projectId', isEqualTo: widget.projectDataList[3])
        .get();
    var longList = updateLongQuery.docs.map((e) async {
      var accept_req = await FirebaseFirestore.instance
          .collection('contractor')
          .doc(widget.engEmail)
          .collection('projects')
          .doc(e.id)
          .delete();
      return accept_req;
    }).toList();
    await FirebaseFirestore.instance
        .collection('Projects')
        .doc(widget.projectDataList[3])
        .update({'isContrSelected': false});
    //-----------------Send notification
    NotificationCases().requestAcceptanceorDecline(widget.engEmail, 'Rejected');
  }

  approveclientreq() async {
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
        body: Column(
          children: [
            RequestBody(
              name: widget.name,
              projectDataList: widget.projectDataList,
              engEmail: widget.engEmail,
              role: widget.role,
              profilePic: widget.profilePic,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 80.0, right: 80, bottom: 20),
              child: ElevatedButton(
                onPressed: () async {
                   if (widget.selectedValue == 'Contractor'){
                     var activitiesSnapshot = await confirmContrReq();
                  } else if (widget.selectedValue == 'Engineer'){
                     var activitiesSnapshot = await FirebaseFirestore.instance
                        .collection('engineers')
                        .doc(widget.engEmail)
                        .update({'reqAccepted': true});
                    //-----------------Send notification
                    NotificationCases().requestAcceptanceorDecline(
                        widget.engEmail, 'Accepted');
                  } else {approveclientreq();}
                  Navigator.pop(context);
                  setState(() {});
                  Get.snackbar('Request Accepted',
                      '${widget.selectedValue} has been added to the project');
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF2CF07F)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Frame.png',
                      width: 30, // Adjust width as needed
                      height: 30, // Adjust height as needed
                    ),
                    const SizedBox(width: 10), // Add spacing between image and text
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
                  if (widget.selectedValue == 'Contractor') {
                    rejecContrReq();
                  } else if (widget.selectedValue == 'Engineer') {
                    var activitiesSnapshot = await FirebaseFirestore.instance
                        .collection('engineers')
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
                  } else {
                    var activitiesSnapshot = await FirebaseFirestore.instance
                        .collection('clients')
                        .doc('${widget.engEmail}')
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
                  Get.snackbar('Request Rejected', '');
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF2CF07F)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Vector.png',
                      width: 30, // Adjust width as needed
                      height: 30, // Adjust height as needed
                    ),
                    const SizedBox(width: 10), // Add spacing between image and text
                    const Text(
                      'Reject',
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

class ApprovedRequest extends StatefulWidget {
  ApprovedRequest(
      {required this.name,
      required this.projectDataList,
      required this.engEmail,
      required this.selectedValue,
        required this.profilePic,
        required this.role,
      super.key});

  String name;
  String profilePic;
  List projectDataList;
  String engEmail;
  String selectedValue;
  String role;
  @override
  State<ApprovedRequest> createState() => _ApprovedRequestState();
}

class _ApprovedRequestState extends State<ApprovedRequest> {
  rejecContrReq() async {
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('contractorReq')
        .where('projectId', isEqualTo: widget.projectDataList[3])
        .get();
    var list = activitiesSnapshot.docs.map((e) async {
      var update = await FirebaseFirestore.instance
          .collection('contractorReq')
          .doc(e.id)
          .delete();
      return update;
    }).toList();
    var updateLongQuery = await FirebaseFirestore.instance
        .collection('contractor')
        .doc(widget.engEmail)
        .collection('projects')
        .where('projectId', isEqualTo: widget.projectDataList[3])
        .get();
    var longList = updateLongQuery.docs.map((e) async {
      var accept_req = await FirebaseFirestore.instance
          .collection('contractor')
          .doc(widget.engEmail)
          .collection('projects')
          .doc(e.id)
          .delete();
      return accept_req;
    }).toList();
    await FirebaseFirestore.instance
        .collection('Projects')
        .doc(widget.projectDataList[3])
        .update({'isContrSelected': false});
  }


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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RequestBody(
              name: widget.name,
              projectDataList: widget.projectDataList,
              engEmail: widget.engEmail,
              role: widget.role,
              profilePic: widget.profilePic,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 80.0, right: 80, bottom: 20),
              child: ElevatedButton(
                onPressed: () async {
                  if (widget.selectedValue == 'Contractor') {
                    rejecContrReq();
                  } else if (widget.selectedValue == 'Engineer') {
                    var activitiesSnapshot = await FirebaseFirestore.instance
                        .collection('engineers')
                        .doc(widget.engEmail)
                        .delete();
                    await FirebaseFirestore.instance
                        .collection('Projects')
                        .doc(widget.projectDataList[3])
                        .update({'isSelected': false});
                  } else {
                    var activitiesSnapshot = await FirebaseFirestore.instance
                        .collection('clients')
                        .doc('${widget.engEmail}')
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
                  Get.snackbar('${widget.selectedValue} Deleted', '');
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
      required this.role,
        required this.profilePic,
      super.key});

  String name;
  String profilePic;
  List projectDataList;
  String engEmail;
  String role;

  @override
  State<RequestBody> createState() => _RequestBodyState();
}

class _RequestBodyState extends State<RequestBody> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
