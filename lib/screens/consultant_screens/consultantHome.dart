import 'package:amir_khan1/components/my_drawer.dart';
import 'package:amir_khan1/controllers/navigationController.dart';
import 'package:amir_khan1/main.dart';
import 'package:amir_khan1/pages/pageoneofhomescreen.dart';
import 'package:amir_khan1/pages/pagethreeofhomescreen.dart';
import 'package:amir_khan1/pages/pagetwoofhomescreen.dart';
import 'package:amir_khan1/screens/consultant_screens/cnsltSchedule.dart';
import 'package:amir_khan1/screens/consultant_screens/addProjectScreen.dart';
import 'package:amir_khan1/screens/consultant_screens/homeTab.dart';
import 'package:amir_khan1/screens/consultant_screens/progressPage.dart';
import 'package:amir_khan1/screens/consultant_screens/requestPage.dart';
import 'package:amir_khan1/screens/consultant_screens/scheduledProjects.dart';
import 'package:amir_khan1/screens/consultant_screens/widgets/statusContainer.dart';
import 'package:amir_khan1/models/activity.dart';
import 'package:amir_khan1/screens/engineer_screens/chatscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/scheduleScreen/schedulescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ConsultantHomePage extends StatefulWidget {
  const ConsultantHomePage({super.key});

  @override
  ConsultantHomePageState createState() => ConsultantHomePageState();
}

class ConsultantHomePageState extends State<ConsultantHomePage> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
        drawer: const MyDrawer(),
        backgroundColor: Colors.white,
        body: Obx(
          () => controller.cnsltCurrentIndex.value == 1
              ? ChatScreen()
              : controller.cnsltCurrentIndex.value == 2
                  ? CreateProject()
                  : controller.cnsltCurrentIndex.value == 0
                      ? ConsultantHomeTab()
                      : controller.cnsltCurrentIndex.value == 3
                          ? const ScheduleProjects()
                          : const NotificationsScreen(),
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            // selectedItemColor:  Color(0xFF3EED88),
            // unselectedItemColor: Colors.black,
            
            currentIndex: controller.cnsltCurrentIndex.value,
            onTap: (int index) {
              controller.cnsltCurrentIndex.value = index;
            },
            
            selectedIconTheme: IconThemeData(color:  Color(0xFF3EED88),size: 30),
            showUnselectedLabels: false,
            unselectedLabelStyle: TextStyle(color: Colors.black),
            showSelectedLabels: false,
            unselectedIconTheme: IconThemeData(color: Colors.black,size: 22.5),
            selectedFontSize: 0,
            unselectedFontSize: 0,
            items: [
              const BottomNavigationBarItem(
                
                icon: Icon(Icons.home,),
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
                      width: 46.0,
                      height: 36.0,
                      decoration: const BoxDecoration(
                        color:  Color.fromARGB(255, 47, 235, 125),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: const Icon(Icons.add_box_outlined,
                          color: Colors.white, size: 30.0),
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
                icon: Icon(Icons.notifications),
                label: 'Notifications',
              ),
            ],
            iconSize: 20.0,
          ),
        ));
  }
}

class ConsultantUserData {
  final String username;
  final String? profilePicUrl;

  ConsultantUserData({
    required this.username,
    this.profilePicUrl,
  });

  @override
  String toString() {
    return username;
  }
}
