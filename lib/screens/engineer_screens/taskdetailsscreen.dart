// import 'package:flutter/material.dart';
//
// import '../components/arcpainter.dart';
// import '../main.dart';
//
//
// //Task details screen
// class TaskDetailsScreen extends StatefulWidget {
//   const TaskDetailsScreen({Key? key}) : super(key: key);
//
//   @override
//   State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
// }
//
// class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
//   bool isChecked1 = false;
//   bool isChecked2 = false;
//   bool isChecked3 = false;
//   bool isChecked4 = false;
//   bool isChecked5 = false;
//
//   // To maintain the state of the checkbox
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF212832),
//       appBar: AppBar(
//         title: const Text('Task Details'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 370,
//                 height: 50,
//                 color: const Color(0xFF455A64),
//                 child: const Center(
//                   child: Text(
//                     'Task Details',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Row(
//                 children: [
//                   Container(
//                     width: 35,
//                     height: 35,
//                     decoration: const BoxDecoration(
//                       color: Colors.yellow,
//                     ),
//                     child: const Icon(Icons.calendar_today,
//                         color: Colors.black, size: 24),
//                   ),
//                   const SizedBox(width: 8),
//                   const Text('Due Date:\nSeptember 30, 2023',
//                       style: TextStyle(fontSize: 16)),
//                   const SizedBox(width: 25),
//                   Container(
//                     width: 35,
//                     height: 35,
//                     decoration: const BoxDecoration(
//                       color: Colors.yellow,
//                     ),
//                     child:
//                     const Icon(Icons.group, color: Colors.black, size: 24),
//                   ),
//                   const SizedBox(width: 8),
//                   const Text('Project\nTeam', style: TextStyle(fontSize: 16)),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 width: 370,
//                 height: 43,
//                 color: const Color(0xFF455A64),
//                 child: const Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Text(
//                     'Project Details',
//                     style: TextStyle(
//                       fontSize: 22,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 6),
//               const Text(
//                 'Task Description goes here. This is a longer description of the task that provides more details about what needs to be done.',
//                 style: TextStyle(
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Container(
//                 width: 370,
//                 height: 70,
//                 color: const Color(0xFF455A64),
//                 child: Padding(
//                   padding:
//                   const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
//                   child: Row(
//                     children: [
//                       const Text(
//                         'Project Progress',
//                         style: TextStyle(
//                           fontSize: 24,
//                         ),
//                       ),
//                       const SizedBox(width: 58),
//                       Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           // Outer Ellipse with a thin border
//                           Container(
//                             height: 68,
//                             width: 68,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.transparent,
//                               border: Border.all(
//                                 color: Colors.grey,
//                                 width: 1.5,
//                               ),
//                             ),
//                           ),
//                           // Inner Ellipse with custom paint
//                           SizedBox(
//                             height: 58,
//                             width: 58,
//                             child: CustomPaint(
//                               painter: ArcPainter(),
//                             ),
//                           ),
//                           const Positioned(
//                             top: 0,
//                             bottom: 0,
//                             left: 0,
//                             right: 0,
//                             child: Center(
//                               child:
//                               Text("75%", style: TextStyle(fontSize: 22)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 6),
//               const Text(
//                 'All Tasks',
//                 style: TextStyle(
//                   fontSize: 24,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Container(
//                 width: 370,
//                 height: 58,
//                 color: const Color(0xFF455A64),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       const Text('Site Preparation',
//                           style: TextStyle(fontSize: 16)),
//                       const SizedBox(width: 150),
//                       Container(
//                         width: 40,
//                         height: 40,
//                         color: Colors.yellow, // Yellow background color
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Container(
//                               width: 24, // Adjust this value
//                               height: 24, // Adjust this value
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.black,
//                                   width: 2,
//                                 ),
//                               ),
//                             ),
//                             Theme(
//                               data: ThemeData(
//                                 unselectedWidgetColor:
//                                 Colors.transparent, // Make it transparent
//                               ),
//                               child: Checkbox(
//                                 value: isChecked1,
//                                 onChanged: (bool? newValue) {
//                                   setState(() {
//                                     isChecked1 = newValue ?? false;
//                                   });
//                                 },
//                                 checkColor: Colors.black,
//                                 // Color of the tick mark
//                                 fillColor:
//                                 MaterialStateProperty.resolveWith<Color?>(
//                                         (states) {
//                                       if (states.contains(MaterialState.selected)) {
//                                         return Colors.transparent;
//                                       }
//                                       return null; // Use the default (null means transparent here)
//                                     }),
//                                 activeColor:
//                                 Colors.transparent, // Make it transparent
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 width: 370,
//                 height: 58,
//                 color: const Color(0xFF455A64),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       const Text('Foundation', style: TextStyle(fontSize: 16)),
//                       const SizedBox(width: 183),
//                       Container(
//                         width: 40,
//                         height: 40,
//                         color: Colors.yellow, // Yellow background color
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Container(
//                               width: 24, // Adjust this value
//                               height: 24, // Adjust this value
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.black,
//                                   width: 2,
//                                 ),
//                               ),
//                             ),
//                             Theme(
//                               data: ThemeData(
//                                 unselectedWidgetColor:
//                                 Colors.transparent, // Make it transparent
//                               ),
//                               child: Checkbox(
//                                 value: isChecked2,
//                                 onChanged: (bool? newValue) {
//                                   setState(() {
//                                     isChecked2 = newValue ?? false;
//                                   });
//                                 },
//                                 checkColor: Colors.black,
//                                 // Color of the tick mark
//                                 fillColor:
//                                 MaterialStateProperty.resolveWith<Color?>(
//                                         (states) {
//                                       if (states.contains(MaterialState.selected)) {
//                                         return Colors.transparent;
//                                       }
//                                       return null; // Use the default (null means transparent here)
//                                     }),
//                                 activeColor:
//                                 Colors.transparent, // Make it transparent
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 width: 370,
//                 height: 58,
//                 color: const Color(0xFF455A64),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       const Text('Framework', style: TextStyle(fontSize: 16)),
//                       const SizedBox(width: 184),
//                       Container(
//                         width: 40,
//                         height: 40,
//                         color: Colors.yellow, // Yellow background color
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Container(
//                               width: 24, // Adjust this value
//                               height: 24, // Adjust this value
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.black,
//                                   width: 2,
//                                 ),
//                               ),
//                             ),
//                             Theme(
//                               data: ThemeData(
//                                 unselectedWidgetColor:
//                                 Colors.transparent, // Make it transparent
//                               ),
//                               child: Checkbox(
//                                 value: isChecked3,
//                                 onChanged: (bool? newValue) {
//                                   setState(() {
//                                     isChecked3 = newValue ?? false;
//                                   });
//                                 },
//                                 checkColor: Colors.black,
//                                 // Color of the tick mark
//                                 fillColor:
//                                 MaterialStateProperty.resolveWith<Color?>(
//                                         (states) {
//                                       if (states.contains(MaterialState.selected)) {
//                                         return Colors.transparent;
//                                       }
//                                       return null; // Use the default (null means transparent here)
//                                     }),
//                                 activeColor:
//                                 Colors.transparent, // Make it transparent
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 width: 370,
//                 height: 58,
//                 color: const Color(0xFF455A64),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       const Text('Roofing', style: TextStyle(fontSize: 16)),
//                       const SizedBox(width: 209),
//                       Container(
//                         width: 40,
//                         height: 40,
//                         color: Colors.yellow, // Yellow background color
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Container(
//                               width: 24, // Adjust this value
//                               height: 24, // Adjust this value
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.black,
//                                   width: 2,
//                                 ),
//                               ),
//                             ),
//                             Theme(
//                               data: ThemeData(
//                                 unselectedWidgetColor:
//                                 Colors.transparent, // Make it transparent
//                               ),
//                               child: Checkbox(
//                                 value: isChecked4,
//                                 onChanged: (bool? newValue) {
//                                   setState(() {
//                                     isChecked4 = newValue ?? false;
//                                   });
//                                 },
//                                 checkColor: Colors.black,
//                                 // Color of the tick mark
//                                 fillColor:
//                                 MaterialStateProperty.resolveWith<Color?>(
//                                         (states) {
//                                       if (states.contains(MaterialState.selected)) {
//                                         return Colors.transparent;
//                                       }
//                                       return null; // Use the default (null means transparent here)
//                                     }),
//                                 activeColor:
//                                 Colors.transparent, // Make it transparent
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 width: 370,
//                 height: 58,
//                 color: const Color(0xFF455A64),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       const Text('Interior', style: TextStyle(fontSize: 16)),
//                       const SizedBox(width: 213),
//                       Container(
//                         width: 40,
//                         height: 40,
//                         color: Colors.yellow, // Yellow background color
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Container(
//                               width: 24, // Adjust this value
//                               height: 24, // Adjust this value
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.black,
//                                   width: 2,
//                                 ),
//                               ),
//                             ),
//                             Theme(
//                               data: ThemeData(
//                                 unselectedWidgetColor:
//                                 Colors.transparent, // Make it transparent
//                               ),
//                               child: Checkbox(
//                                 value: isChecked5,
//                                 onChanged: (bool? newValue) {
//                                   setState(() {
//                                     isChecked5 = newValue ?? false;
//                                   });
//                                 },
//                                 checkColor: Colors.black,
//                                 // Color of the tick mark
//                                 fillColor:
//                                 MaterialStateProperty.resolveWith<Color?>(
//                                         (states) {
//                                       if (states.contains(MaterialState.selected)) {
//                                         return Colors.transparent;
//                                       }
//                                       return null; // Use the default (null means transparent here)
//                                     }),
//                                 activeColor:
//                                 Colors.transparent, // Make it transparent
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: 376.0,
//                 height: 60.0,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) {
//                           return const MyHomePage(title: "HOME PAGE");
//                         }));
//                   },
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(0.0),
//                     ),
//                     backgroundColor: Colors.yellow,
//                   ),
//                   child: const Text(
//                     "Add Task",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.0,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
