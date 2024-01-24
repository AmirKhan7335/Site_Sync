import 'dart:io';

import 'package:amir_khan1/screens/engineer_screens/activity.dart';
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
  List<Activity> loadedActivities = [];

  
  @override
  void initState()  {
    super.initState();
   fetchActivitiesFromFirebase();
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    File _image;

    if (pickedFile != null) {
      _image = File(pickedFile.path);
    }
  }

  Future<void> addPicture(Activity updatedActivity) async {
    var email = FirebaseAuth.instance.currentUser!.email;
    await FirebaseFirestore.instance
        .collection('schedules')
        .doc(email)
        .collection('activities')
        .doc(updatedActivity.id)
        .update({'images': updatedActivity.images});
  }

  Future<void> fetchActivitiesFromFirebase() async {
    var email = FirebaseAuth.instance.currentUser!.email;
    var activitiesSnapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .doc(email)
        .collection('activities')
        .orderBy('order') // Sort by order
        .get();

    List<Activity> tempActivities = [];
    for (var doc in activitiesSnapshot.docs) {
      var data = doc.data();
      tempActivities.add(Activity(
          id: doc.id, // Use the Firestore document ID as the activity ID
          name: data['name'],
          startDate: data['startDate'],
          finishDate: data['finishDate'],
          order: data['order'],
          images: data['images']));
    }

    setState(() {
      loadedActivities = tempActivities;
    });
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
    return
        // Scaffold(
        //   appBar: AppBar(
        //     title: Text('Choose Activity To Add Pic'),
        //   ),
        //   body:
        Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: ListView.builder(
                itemCount: loadedActivities.length,
                itemBuilder: ((context, index) {
                  return ListTile(
                    title: Text('${loadedActivities[index].name}'),
                  );
                })),
          )
        ],
      ),
    );
    //,
    // );
  }
}
