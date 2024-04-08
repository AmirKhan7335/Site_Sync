import 'package:amir_khan1/components/my_drawer.dart';
import 'package:amir_khan1/controllers/navigationController.dart';
import 'package:amir_khan1/screens/contractor_screen/tabs/contrCreateProject.dart';
import 'package:amir_khan1/screens/contractor_screen/tabs/contrHomeTab.dart';
import 'package:amir_khan1/screens/contractor_screen/tabs/contrSchedule/contrSchedule.dart';
import 'package:amir_khan1/screens/engineer_screens/chatscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        
        body: Obx(
          () => controller.contrCurrentIndex.value == 1
              ? const ChatScreen(isClient: false,)
              : controller.contrCurrentIndex.value == 2
                  ? const ContrCreateProject()
                  : controller.contrCurrentIndex.value == 0
                      ? const ContrHomeTab()
                      : controller.contrCurrentIndex.value == 3
                          ? const ContrScheduleProjects()
                          : const NotificationsScreen(),
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            // selectedItemColor:  Color(0xFF3EED88),
            // unselectedItemColor: Colors.black,

            currentIndex: controller.contrCurrentIndex.value,
            onTap: (int index) {
              controller.contrCurrentIndex.value = index;
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
