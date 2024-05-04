import 'package:amir_khan1/components/arcpainter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProjectDetail extends StatefulWidget {
  ProjectDetail({required this.projectDataList, required this.engineerName,super.key,});

  List projectDataList;
  String engineerName;
  @override
  State<ProjectDetail> createState() => _RequestBodyState();
}

class _RequestBodyState extends State<ProjectDetail> {
  late double progress; // Define progress variable
  String clientName = '';
  String contractorName = '';

  @override
  void initState() {
    super.initState();
    progress = 0.0; // Initialize progress
    fetchProgress();
    fetchClientandContractorName();// Call fetchProgress when the widget initializes
  } // Define progress variable

  Future<void> fetchClientandContractorName() async {
    try {
      final projectName = widget.projectDataList[0]; // Project name

      // Fetch projects collection
      final projectsSnapshot = await FirebaseFirestore.instance.collection('Projects').where('title', isEqualTo: projectName).get();

      // Check if project exists
      if (projectsSnapshot.docs.isEmpty) {
        throw Exception('Project not found');
      }


      // Assume only one project matches the project name
      final projectDoc = projectsSnapshot.docs.first;
      final projectData = projectDoc.data();

      // Retrieve the client name from the project document, or set it to empty string if not found
      final clientName = projectData.containsKey('clientName') ? projectData['clientName'] : 'No client Enrolled yet';

      // Retrieve the contractor name from the project document, or set it to empty string if not found
      final contractorName = projectData.containsKey('companyName') ? projectData['companyName'] : 'No contractor Enrolled yet';

      setState(() {
        this.clientName = clientName;
        this.contractorName = contractorName;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  Future<void> fetchProgress() async {
    try {
      final projectName = widget.projectDataList[0]; // Project name

      // Fetch projects collection
      final projectsSnapshot = await FirebaseFirestore.instance.collection('Projects').where('title', isEqualTo: projectName).get();

      // Check if project exists
      if (projectsSnapshot.docs.isEmpty) {
        throw Exception('Project not found');
      }

      // Assume only one project matches the project name
      final projectDoc = projectsSnapshot.docs.first;
      final projectData = projectDoc.data();

      // Retrieve the overall percent value from the project document, or set it to zero if not found
      final overallPercent = projectData.containsKey('overallPercent') ? (projectData['overallPercent'] as num).toDouble() : 0.0;

      setState(() {
        progress = overallPercent;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Project Detail',style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.projectDataList[0]}',
                    style: const TextStyle(fontSize: 20, color: Colors.black,fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 32, left: 32),
              child: Container(
                height: 1.5,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 5.0, left: 32.0, right: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(fontSize: 24, color: Colors.black,fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 90,
                    width: 90,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Outer Ellipse with a thin border
                        Container(
                          height: 89,
                          width: 89,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.grey,
                              width: 5,
                            ),
                          ),
                        ),
                        // Inner Ellipse with custom paint
                        SizedBox(
                          height: 126,
                          width: 127,
                          child: CustomPaint(
        
                            painter: ArcPainter(
        
                              progress: progress
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              "$progress %",
                              style: const TextStyle(fontSize: 20,color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 25,
                            ),
                            const Text(
                              'Client:  ', style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              clientName, style: TextStyle(color: Colors.black),
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
                              width: 25,
                            ),
                            const Text(
                              'Contractor:  ', style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              contractorName, style: TextStyle(color: Colors.black),
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
                              width: 25,
                            ),
                            const Text(
                              'Total Cost:  ', style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              widget.projectDataList[3], style: TextStyle(color: Colors.black),
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
                              width: 25,
                            ),
                            const Text(
                              'Engineer :  ', style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              widget.engineerName, style: TextStyle(color: Colors.black),
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
                              width: 25,
                            ),
                            const Text(
                              'Retention Money :  ', style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              '${widget.projectDataList[4]}', style: TextStyle(color: Colors.black),
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
                              width: 25,
                            ),
                            const Text(
                              'Funding :  ', style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              '${widget.projectDataList[5]}', style: TextStyle(color: Colors.black),
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
                              width: 25,
                            ),
                            const Text(
                              'Location :  ', style: TextStyle(color: Colors.black),
                            ),
                            Expanded(
                              child: Text(
                                '${widget.projectDataList[6]}',
                                style: const TextStyle(
                                  height: 1.0, color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                            // Text(
                            //   '${widget.projectDataList[6]}',
                            // ),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 25,
                            ),
                            const Text(
                              'Start Date:  ', style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              DateFormat('dd-MM-yyyy').format(widget.projectDataList[1].toDate()), style: TextStyle(color: Colors.black),
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
                              width: 25,
                            ),
                            const Text(
                              'End Date:  ', style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              DateFormat('dd-MM-yyyy').format(widget.projectDataList[2].toDate()), style: TextStyle(color: Colors.black),
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
      ),
    );
  }
}
