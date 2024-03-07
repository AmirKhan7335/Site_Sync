import 'dart:io';

import 'package:amir_khan1/controllers/centralTabController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';
import 'package:open_file/open_file.dart';

class CnsltDocumentScreen extends StatefulWidget {
  CnsltDocumentScreen({super.key, required String this.projectId});
  String projectId;
  @override
  State<CnsltDocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<CnsltDocumentScreen> {
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
      final projId = widget.projectId;
      FirebaseFirestore.instance.collection('Projects').doc(projId).update({
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

  getPath() async {
    final Directory? tempDir = await getExternalStorageDirectory();
    final filePath = Directory("${tempDir!.path}/files");
    if (await filePath.exists()) {
      return filePath.path;
    } else {
      await filePath.create(recursive: true);
      return filePath.path;
    }
  }

  Future<void> _checkFileAndOpen(fileUrl, fileName) async {
    try {
      var storePath = await getPath();
      bool isExist = await File('$storePath/$fileName').exists();
      if (isExist) {
        OpenFile.open('$storePath/$fileName');
      } else {
        var filePath = '$storePath/$fileName';
        // setState(() {
        //   dowloading = true;
        //   progress = 0;
        // });

        await Dio().download(
          fileUrl,
          filePath,
          onReceiveProgress: (count, total) {
            // setState(() {
            //   progress = (count / total);
            // });
          },
        );
        OpenFile.open(filePath);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<List> getDocuments() async {
    final projId = widget.projectId;
    final query = await FirebaseFirestore.instance
        .collection('Projects')
        .doc(projId)
        .get();
    return query.data()!['documents'];
  }

  @override
  Widget build(BuildContext context) {
    final control = Get.put(CentralTabController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
iconTheme: IconThemeData(color: Colors.black),
        title: Text('Documents', style: TextStyle(color: Colors.black)),
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
                    child: Text('Error: ${snapshot.error}',style: TextStyle(color: Colors.black)),
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

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.white,
                            elevation: 5,
                            child: ListTile(
                              onTap: () async {
                                try {
                                  //------------------------------------------
                                  // final Uri _url = Uri.parse(getlist[1]);
                                  // if (await canLaunchUrl(_url)) {
                                  //   // print('object');
                                  //   await launchUrl(_url);
                                  // } else {
                                  //   Get.snackbar('Error', 'Unknown Error');
                                  // }
                                  //-------------------------------------------
                                  controller.isDocumentLoading.value = true;
                                  _checkFileAndOpen(getlist[1], getlist[0]);
                                  controller.isDocumentLoading.value = false;
                                } catch (e) {
                                  Get.snackbar('Error', e.toString());
                                }
                              },
                              leading: ClipOval(
                                child: Icon(Icons.file_copy,color: Colors.black,),
                              ),
                              title: Text(getlist[0],style: TextStyle(color: Colors.black)),
                              subtitle: Text('00/00/2000',style: TextStyle(color: Colors.black)),
                            ),
                          ),
                        );
                      }));
                }
              },
            ),
            control.isDocumentLoading.value
                ? Center(
                    child: CircularProgressIndicator(
                    color: Colors.green,
                  ))
                : Center()
          ],
        ),
      ),
    );
  }
}
