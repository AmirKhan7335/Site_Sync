import 'package:amir_khan1/components/my_drawer.dart';
import 'package:amir_khan1/controllers/navigationController.dart';
import 'package:amir_khan1/screens/consultant_screens/addProjectScreen.dart';
import 'package:amir_khan1/screens/consultant_screens/homeTab.dart';
import 'package:amir_khan1/screens/consultant_screens/scheduledProjects.dart';
import 'package:amir_khan1/screens/engineer_screens/chatscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

        body: Obx(
          () => controller.cnsltCurrentIndex.value == 1
              ? const ChatScreen(isClient: false,)
              : controller.cnsltCurrentIndex.value == 2
                  ? const CreateProject()
                  : controller.cnsltCurrentIndex.value == 0
                      ? const ConsultantHomeTab()
                      : controller.cnsltCurrentIndex.value == 3
                          ? const ScheduleProjects()
                          : const NotificationsScreen(),
        ),
        bottomNavigationBar: Obx(
          () => 
          BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            // selectedItemColor:  Color(0xFF3EED88),
            // unselectedItemColor: Colors.black,

            currentIndex: controller.cnsltCurrentIndex.value,
            onTap: (int index) {
              controller.cnsltCurrentIndex.value = index;
            },

            selectedIconTheme:
                const IconThemeData(color: Color(0xFF3EED88), size: 30),
            showUnselectedLabels: false,
            unselectedLabelStyle: const TextStyle(color: Colors.black),
            showSelectedLabels: false,
            unselectedIconTheme: const IconThemeData(color: Colors.black, size: 22.5),
            selectedFontSize: 0,
            unselectedFontSize: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                ),
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
                        color: Color.fromARGB(255, 47, 235, 125),
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
        )
        );
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
