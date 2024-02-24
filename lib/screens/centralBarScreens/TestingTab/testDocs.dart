import 'dart:io';

import 'package:amir_khan1/controllers/centralTabController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TestDocumentScreen extends StatefulWidget {
  TestDocumentScreen(
      {super.key, required String this.docName, required String this.projId});
  String docName;
  String projId;
  @override
  State<TestDocumentScreen> createState() => _TestDocumentScreenState();
}

class _TestDocumentScreenState extends State<TestDocumentScreen> {
  final controller = Get.put(CentralTabController());
  uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'pdf', 'mpp'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      // Upload the file to Firebase Storage
      try {
        await uploadFileToFirebase(file);

        controller.isDocumentLoading.value = false;
        Get.snackbar('Success', 'File Uploaded');
      } catch (e) {
        Get.snackbar('Error', e.toString());
      }
    }
  }

  Future<void> uploadFileToFirebase(File file) async {
    try {
      controller.isDocumentLoading.value = true;
      String fileName = file.path.split('/').last;

      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() => null);
      String downloadUrl = await ref.getDownloadURL();

      FirebaseFirestore.instance
          .collection('Projects')
          .doc(widget.projId)
          .collection('testing')
          .doc(widget.docName)
          .update({
        'documents': FieldValue.arrayUnion([
          [
            fileName,
            downloadUrl,
          ].toString()
        ]),
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    // Use downloadUrl as needed, e.g., save to Firestore database
    // print('File uploaded to: $downloadUrl');
  }

  Future<List> getDocuments() async {
    final query = await FirebaseFirestore.instance
        .collection('Projects')
        .doc(widget.projId)
        .collection('testing')
        .doc(widget.docName)
        .get();
    return query.data()!['documents'];
  }

  @override
  Widget build(BuildContext context) {
    final control = Get.put(CentralTabController());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docName),
        actions: [
          IconButton(
            onPressed: () {
              uploadFile();
              control.isDocumentLoading.value = false;
            },
            icon: Icon(Icons.upload_file),
          ),
        ],
      ),
      body: Obx(
        () => Stack(
          children: [
            FutureBuilder(
              future: getDocuments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center();
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final List data = snapshot.data!;
                  return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: ((context, index) {
                        final listString = data[index];
                        final list =
                            listString.substring(1, listString.length - 1);
                        final getlist =
                            list.split(',').map((e) => e.trim()).toList();

                        return ListTile(
                          onTap: () async {
                            try {
                              final Uri _url = Uri.parse(getlist[1]);
                              if (await canLaunchUrl(_url)) {
                                // print('object');
                                await launchUrl(_url);
                              } else {
                                Get.snackbar('Error', 'Unknown Error');
                              }
                            } catch (e) {
                              Get.snackbar('Error', e.toString());
                            }
                          },
                          leading: ClipOval(
                            child: Icon(Icons.file_copy),
                          ),
                          title: Text(getlist[0]),
                          subtitle: Text('00/00/2000'),
                        );
                      }));
                }
              },
            ),
            control.isDocumentLoading.value
                ? Center(
                    child: CircularProgressIndicator(
                    color: Colors.yellow,
                  ))
                : Center()
          ],
        ),
      ),
    );
  }
}
