// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// // Details screen
// class DetailsScreen extends StatefulWidget {
//   final String mainHeading;
//   final String subHeading;
//   final List image;
//
//   const DetailsScreen({
//     super.key,
//     required this.mainHeading,
//     required this.subHeading,
//     required this.image,
//   });
//
//   @override
//   State<DetailsScreen> createState() => _DetailsScreenState();
// }
//
// class _DetailsScreenState extends State<DetailsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.mainHeading,
//           style: const TextStyle(color: Colors.black),
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//         backgroundColor: Colors.white,
//         centerTitle: true,
//       ),
//       backgroundColor: Colors.white,
//       body: ListView.builder(
//           itemCount: widget.image.length,
//           itemBuilder: (context, index) {
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 InkWell(
//                   onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => Scaffold(
//                               backgroundColor: Colors.white,
//                               body:
//                                   Center(child: Image.network(widget.image[index]))))),
//                   child: SizedBox(
//                       width: Get.width * 1,
//                       height: 350,
//                       child: Image.network(widget.image[index])),
//                 )
//               ],
//             );
//           }),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Details screen
class DetailsScreen extends StatefulWidget {
  final String mainHeading;
  final String subHeading;
  final List image;
  final String activityId; // Add activityId to fetch approved images
  final String? engineerEmail; // Add engineerEmail to fetch approved images

  const DetailsScreen({
    super.key,
    required this.mainHeading,
    required this.subHeading,
    required this.image,
    required this.activityId,
    required this.engineerEmail,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List<String> approvedImages = [];
  bool isLoading = true; // Add isLoading flag


  @override
  void initState() {
    super.initState();
    fetchApprovedImages();
  }

  Future<void> fetchApprovedImages() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(widget.engineerEmail)
          .collection('activities')
          .doc(widget.activityId)
          .get();

      if (docSnapshot.exists) {
        isLoading = false;
        final data = docSnapshot.data()!;
        if (data.containsKey('approvedImage')) {
          final approvedImageData = data['approvedImage'];
          setState(() {
            approvedImages = approvedImageData != null
                ? List<String>.from(approvedImageData)
                : []; // Initialize as empty list if approvedImageData is null
          });
        }else {
          setState(() {
            print("approvedImage key not found, initializing with empty list");
            approvedImages = []; // Initialize with empty list
          });
        }
      }
    } catch (e) {
      print('Error fetching approved images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Combine and deduplicate images
    final allImages = widget.image + approvedImages;
    final uniqueImages = allImages.toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mainHeading,
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue)) // Loading indicator
          : uniqueImages.isEmpty
          ? const Center(child: Text('No images shared yet', style: TextStyle(color: Colors.black, fontSize: 20),)) // Empty state
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Adjust as needed
        ),
        itemCount: uniqueImages.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(child: Image.network(uniqueImages[index])),
                  appBar: AppBar(
                    title: Text(
                      widget.mainHeading,
                      style: const TextStyle(color: Colors.black),
                    ),
                    iconTheme: const IconThemeData(color: Colors.black),
                    backgroundColor: Colors.white,
                    centerTitle: true,
                  ),
                ),
              ),
            ),
            child: Image.network(uniqueImages[index]),
          );
        },
      ),
    );
  }
}