import 'dart:io';
import 'dart:ui';

import 'package:amir_khan1/pages/pageoneofhomescreen.dart';
import 'package:amir_khan1/pages/pagethreeofhomescreen.dart';
import 'package:amir_khan1/pages/pagetwoofhomescreen.dart';
import 'package:amir_khan1/pages/profile_page.dart';
import 'package:amir_khan1/pages/users_page.dart';
import 'package:amir_khan1/screens/engineer_screens/accountDetails.dart';
import 'package:amir_khan1/screens/engineer_screens/activity.dart';
import 'package:amir_khan1/screens/engineer_screens/chatscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/createaccountscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/engineerHome.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/takePicture/takePicture.dart';
import 'package:amir_khan1/screens/rolescreen.dart';
import 'package:amir_khan1/screens/engineer_screens/scheduleScreen/schedulescreen.dart';
import 'package:amir_khan1/screens/engineer_screens/signinscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/splashscreen.dart';
import 'package:amir_khan1/widgets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'auth/auth.dart';
import 'package:get/get.dart';
import 'components/my_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';

// ctrl+alt+l = format code
// signin screen = log in page
// create account screen =  register page
// signup or createaccount = login or register page

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMaterialApp(
       scrollBehavior: const MaterialScrollBehavior()
          .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: appBarColor,
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/profile_page': (context) => const ProfilePage(),
        '/users_page': (context) => const UsersPage(),
        '/auth': (context) => const AuthPage(),
        '/engineer_home': (context) => const EngineerHomePage(),
        '/signin': (context) => SigninScreen(
              onTap: () {},
            ),
        '/createaccount': (context) => CreateAccountScreen(
              onTap: () {},
            ),
        '/role': (context) => const Role(),
        '/chat': (context) => const ChatScreen(),
        // '/taskdetails': (context) => const TaskDetailsScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}

Widget buildIndicator(int index, int currentPage) {
  return Container(
    margin: const EdgeInsets.all(4.0),
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: index == currentPage ? Colors.blue : Colors.grey,
    ),
  );
}

class EngineerHomePage extends StatefulWidget {
  const EngineerHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<EngineerHomePage> {
  
  int currentIndex = 0; // Index of the selected tab

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: const Color(0xFF212832),
      body: currentIndex == 1
          ? ChatScreen()
          : currentIndex == 2
              ? TakePicture()
              : currentIndex == 0
                  ? EngineerHomeTab()
                  : currentIndex == 3
                      ? const ScheduleScreen()
                      : const NotificationsScreen(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 38, 50, 56),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow,
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 60.0,
                  height: 38.0,
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.black, size: 40.0),
                ),
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.currency_bitcoin),
            label: 'Finanace',
          ),
        ],
        iconSize: 20.0,
      ),
    );
  }
}

class UserData {
  final String username;
  final String? profilePicUrl;
  final List<Activity>? activities;

  UserData({required this.username, this.profilePicUrl, this.activities});

  @override
  String toString() {
    return username;
  }
}
