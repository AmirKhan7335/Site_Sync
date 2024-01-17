// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../common/utils/utils.dart';
// import '../controller/auth_controller.dart';
//
// class UserInformationScreen extends ConsumerStatefulWidget {
//   static const String routeName = '/user-information';
//   const UserInformationScreen({super.key});
//
//   @override
//   ConsumerState<UserInformationScreen> createState() => _UserInformationScreenState();
// }
//
// class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
//   final TextEditingController nameController = TextEditingController();
//   File? image;
//
//
//   @override
//   void dispose() {
//     super.dispose();
//     nameController.dispose();
//   }
//
//   void selectImage() async {
//     final image = await pickImageFromGallery(context);
//     setState(() {});
//   }
//
//   void storeUserData() async {
//     final name = nameController.text.trim();
//     if(name.isNotEmpty){
//       ref.read(authControllerProvider).saveUserDataToFirebase(context, name, image);
//     } else {
//       showSnackBar(context: context, content: "Please enter your name");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//     body: SafeArea(
//       child: Center(
//         child: Column(
//           children: [
//              Stack(
//               children: [
//                 image == null ? const CircleAvatar(
//                   radius: 64,
//                   backgroundImage: NetworkImage('https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png'),
//                 ): CircleAvatar(
//                   radius: 64,
//                   backgroundImage: FileImage(image!),
//                 ),
//                 Positioned(
//                   bottom: -10,
//                   left: 80,
//                   child: IconButton(
//                     onPressed: () {},
//                     icon: const Icon(Icons.add_a_photo),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Container(
//                   width: size.width*0.85,
//                   padding: EdgeInsets.all(20),
//                   child: TextField(
//                     controller: nameController,
//                     decoration: InputDecoration(
//                       hintText: "Enter your name",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: storeUserData,
//                   icon: const Icon(Icons.done),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//     );
//   }
// }
