import 'dart:io';

import 'package:amir_khan1/models/activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TakePicture extends StatefulWidget {
  TakePicture({super.key});

  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  @override
  void initState() {
    super.initState();
  }

  @override
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _takePicture(mode, context) async {
    final picker = ImagePicker();
    if (mode == 'camera') {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddPic(image: pickedFile.path)));
      }
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddPic(image: pickedFile.path)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Take Picture',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 1.5,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                )),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InkWell(
                      onTap: () {
                        _takePicture('camera', context);
                      },
                      child: Center(
                          child: Icon(Icons.camera_alt_rounded,
                              color: Colors.black, size: 100.0)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InkWell(
                      onTap: () {
                        _takePicture('gallery', context);
                      },
                      child: Center(
                          child: Icon(Icons.file_upload,
                              color: Colors.black, size: 100.0)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPic extends StatefulWidget {
  AddPic({required this.image, super.key});
  String image;
  @override
  State<AddPic> createState() => _AddPicState();
}

class _AddPicState extends State<AddPic> {
  Future<void> addPicture(id, image) async {
    var email = FirebaseAuth.instance.currentUser!.email;
    await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .collection('activities')
        .doc(id)
        .update({'image': image, 'imgApproved': false});
  }

  Future<List<Activity>> fetchActivitiesFromFirebase() async {
    var email = FirebaseAuth.instance.currentUser!.email;
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .collection('activities')
        .orderBy('order') // Sort by order
        .get();

    List<Activity> tempActivities = [];

    for (var doc in activitiesSnapshot.docs) {
      var data = doc.data();

      tempActivities.add(Activity(
          id: data['id'], // Use the Firestore document ID as the activity ID
          name: data['name'],
          startDate: data['startDate'],
          finishDate: data['finishDate'],
          order: data['order'],
          image: data['image']));
    }

    return tempActivities;
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    final storageReference = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

    final uploadTask = storageReference.putFile(imageFile);

    await uploadTask.whenComplete(() => null);

    return storageReference.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                'Choose Activity To Add Pic',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: FutureBuilder<List<Activity>>(
                    future: fetchActivitiesFromFirebase(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return Text('No Activities Found');
                      } else if (snapshot.hasData) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: ((context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      onTap: () async {
                                        try {
                                          final url =
                                              await uploadImageToStorage(
                                                  File(widget.image!));
                                          await addPicture(
                                              snapshot.data?[index].id, url);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content:
                                                      Text('Image Added')));
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content:
                                                      Text('${e.toString()}')));
                                          Navigator.pop(context);
                                        }
                                      },
                                      title: Text(
                                        '${snapshot.data?[index].name}',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                );
                              })),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
