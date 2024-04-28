// import 'package:amir_khan1/screens/centralBarScreens/siteCamera/siteCameraScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class Dialogue {
//   TextEditingController rtspController = TextEditingController();
//   inputRtsp(context) {
//     return Get.defaultDialog(
//
//       buttonColor: Colors.green,
//       backgroundColor: Colors.white,
//       title: "Enter RTSP",
//       titleStyle: TextStyle(color: Colors.black),
//       content: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left:16.0,right: 16),
//             child: TextField(
//
//               style: TextStyle(color: Colors.black),
//               controller: rtspController,
//               decoration: InputDecoration(
//
//
//                 hintText: "Enter RTSP Url",
//
//                 hintStyle: TextStyle(
//
//                     color: Colors.grey),
//               ),
//             ),
//           ),
//           SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all(Colors.grey),
//                 ),
//                 onPressed: () {
//                   Get.back();
//                 },
//                 child: Text("Cancel"),
//               ),
//               SizedBox(width: 10),
//               ElevatedButton(
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all(Colors.green),
//                 ),
//                 onPressed: () {
//                   if (rtspController.text.isNotEmpty) {
//                     Get.back();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             SiteCamera(rtspUrl: rtspController.text),
//                       ),
//                     );
//                   } else {
//                     Get.snackbar("Error", "Please enter RTSP Url");
//                   }
//                 },
//                 child: Text("Add RTSP"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
