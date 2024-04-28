import 'dart:io';
import 'package:amir_khan1/notifications/notificationCases.dart';
import 'package:amir_khan1/controllers/takePictureController.dart';
import 'package:amir_khan1/models/activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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

  bool isloading = false;
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
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Take Picture',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.black)),
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
                Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xff2CF07F),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: InkWell(
                        onTap: () {
                          _takePicture('camera', context);
                        },
                        child: const Center(
                            child: Icon(Icons.camera_alt_rounded,
                                color: Colors.black, size: 100.0)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Camera',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                          color: const Color(0xff2CF07F),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: InkWell(
                        onTap: () {
                          _takePicture('gallery', context);
                        },
                        child: const Center(
                            child: Icon(Icons.file_upload,
                                color: Colors.black, size: 100.0)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Upload',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        .update({'image': FieldValue.arrayUnion([image]), 'imgApproved': false});
    //-----------------Send notification
    NotificationCases().scheduleNotification(email!, 'Uploaded the Picture');
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
          startDate: DateFormat('dd/MM/yyyy').format(data['startDate'].toDate()),
          finishDate: DateFormat('dd/MM/yyyy').format(data['finishDate'].toDate()),
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
    final controller = Get.put(TakePictureController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Choose Activity To Add Pic',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<Activity>>(
                future: fetchActivitiesFromFirebase(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blue));
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const Text('No Activities Found');
                  } else if (snapshot.hasData) {
                    return Obx(()
                    => Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: ((context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Card(
                                      elevation: 10,
                                      color: Colors.white,
                                      child: ListTile(
                                        onTap: () async {
                                          try {
                                            controller.isloading.value = true;

                                            final url =
                                            await uploadImageToStorage(
                                                File(widget.image));
                                            await addPicture(
                                                snapshot.data?[index].id,
                                                url);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                content:
                                                Text('Image Added')));
                                            controller.isloading.value= false;
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                content: Text(
                                                    '${e.toString()}')));
                                            Navigator.pop(context);
                                            controller.isloading.value= false;
                                          }
                                        },
                                        title: Text(
                                          '${snapshot.data?[index].name}',
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })),
                        ),
                        controller.isloading.value
                            ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 300,),
                              CircularProgressIndicator(
                                  color: Colors.blue),

                            ],
                          ),
                        )
                            : const SizedBox()
                      ],
                    ),
                    );
                  } else {
                    return const CircularProgressIndicator(color: Colors.blue);
                  }
                }),
          )
        ],
      ),
    );
  }
}
