import 'dart:ui';
import 'package:amir_khan1/pages/profile_page.dart';
import 'package:amir_khan1/pages/users_page.dart';
import 'package:amir_khan1/auth/createaccountscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:amir_khan1/auth/signinscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/splashscreen.dart';
import 'package:amir_khan1/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'auth/auth.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context,) {
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
      home: const SplashScreen(),
      routes: {
        '/profile_page': (context) => const ProfilePage(),
        '/users_page': (context) => const UsersPage(),
        '/auth': (context) => const AuthPage(),

        '/signin': (context) => SigninScreen(
          onTap: () {},
        ),
        '/createaccount': (context) => CreateAccountScreen(
          onTap: () {},
        ),

        // '/taskdetails': (context) => const TaskDetailsScreen(),

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
