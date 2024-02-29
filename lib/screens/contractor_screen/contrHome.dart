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
import 'package:amir_khan1/screens/contractor_screen/tabs/contrCreateProject.dart';
import 'package:amir_khan1/screens/contractor_screen/tabs/contrHomeTab.dart';
import 'package:amir_khan1/screens/contractor_screen/tabs/contrSchedule/contrSchedule.dart';
import 'package:amir_khan1/screens/engineer_screens/chatscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/scheduleScreen/schedulescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ContractorHomePage extends StatefulWidget {
  const ContractorHomePage({super.key});

  @override
  ConsultantHomePageState createState() => ConsultantHomePageState();
}

class ConsultantHomePageState extends State<ContractorHomePage> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
        drawer: const MyDrawer(),
        backgroundColor: const Color(0xFF212832),
        body: Obx(
          () => controller.contrCurrentIndex.value == 1
              ? ChatScreen()
              : controller.contrCurrentIndex.value == 2
                  ? ContrCreateProject()
                  : controller.contrCurrentIndex.value == 0
                      ? ContrHomeTab()
                      : controller.contrCurrentIndex.value == 3
                          ? const ContrScheduleProjects()
                          : const NotificationsScreen(),
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            backgroundColor: const Color.fromARGB(255, 38, 50, 56),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.yellow,
            currentIndex: controller.contrCurrentIndex.value,
            onTap: (int index) {
              controller.contrCurrentIndex.value = index;
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
                      width: 56.0,
                      height: 36.0,
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: const Icon(Icons.add_box_outlined,
                          color: Colors.black, size: 30.0),
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

class ContractorUserData {
  final String username;
  final String? profilePicUrl;

  ContractorUserData({
    required this.username,
    this.profilePicUrl,
  });

  @override
  String toString() {
    return username;
  }
}
