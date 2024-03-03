import 'dart:io';
import 'dart:ui';

import 'package:amir_khan1/pages/pageoneofhomescreen.dart';
import 'package:amir_khan1/pages/pagethreeofhomescreen.dart';
import 'package:amir_khan1/pages/pagetwoofhomescreen.dart';
import 'package:amir_khan1/pages/profile_page.dart';
import 'package:amir_khan1/pages/users_page.dart';
import 'package:amir_khan1/screens/engineer_screens/accountDetails.dart';
import 'package:amir_khan1/models/activity.dart';
import 'package:amir_khan1/screens/engineer_screens/chatscreen.dart';
import 'package:amir_khan1/auth/createaccountscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/enghomeTab.dart';
import 'package:amir_khan1/screens/engineer_screens/engineerHome.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/takePicture/takePicture.dart';
import 'package:amir_khan1/screens/rolescreen.dart';
import 'package:amir_khan1/screens/engineer_screens/scheduleScreen/schedulescreen.dart';
import 'package:amir_khan1/auth/signinscreen.dart';
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


