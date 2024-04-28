import 'package:amir_khan1/components/my_drawer.dart';
import 'package:amir_khan1/controllers/navigationController.dart';
import 'package:amir_khan1/notifications/notification_services.dart';
import 'package:amir_khan1/screens/engineer_screens/chatscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/enghomeTab.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/engFinanceHome.dart';
import 'package:amir_khan1/screens/engineer_screens/scheduleScreen/schedulescreen.dart';
import 'package:amir_khan1/screens/engineer_screens/takePicture/takePicture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class EngineerHomePage extends StatefulWidget {
  EngineerHomePage({required bool this.isClient, super.key});
  bool isClient;
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<EngineerHomePage> {
  NotificationServices notificationServices = NotificationServices();
  // Index of the selected tab
  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupToken();
    notificationServices.setupInteractMessage(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    controller.getSeenStatus();
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        drawer: const MyDrawer(),
        body: Obx(() {
          return widget.isClient
              ? controller.engCurrentIndex.value == 1
              ? ChatScreen(isClient: widget.isClient)
              : controller.engCurrentIndex.value == 0
              ? EngineerHomeTab(isClient: widget.isClient)
              : controller.engCurrentIndex.value == 2
              ? ScheduleScreen(isClient: widget.isClient)
              : EngFinanceHome(
            isClient: widget.isClient,
          )
              : controller.engCurrentIndex.value == 1
              ? ChatScreen(isClient: widget.isClient)
              : controller.engCurrentIndex.value == 2
              ? TakePicture()
              : controller.engCurrentIndex.value == 0
              ? EngineerHomeTab(isClient: widget.isClient)
              : controller.engCurrentIndex.value == 3
              ? ScheduleScreen(isClient: widget.isClient)
              : EngFinanceHome(
            isClient: widget.isClient,

          );
        }),
        bottomNavigationBar: Obx(
              () => BottomNavigationBar(
            selectedIconTheme: const IconThemeData(
              color: const Color(0xFF3EED88),
            ),
            unselectedIconTheme: const IconThemeData(color: Colors.black, size: 22.5),
            unselectedLabelStyle: const TextStyle(color: Colors.black),
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color.fromARGB(255, 47, 235, 125),
            unselectedItemColor: Colors.black,
            currentIndex: controller.engCurrentIndex.value,
            onTap: (int index) {
              controller.engCurrentIndex.value = index;
            },
            items: widget.isClient
                ? [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              //--------------------------

              //--------------------------
              BottomNavigationBarItem(
                icon: controller.seen.value
                    ? const Icon(
                  Icons.chat,
                )
                    : const Stack(children: <Widget>[
                  Icon(Icons.chat),
                  Positioned(
                    // draw a red marble
                    top: 0.0,
                    right: 0.0,
                    child: Icon(Icons.brightness_1,
                        size: 12.0, color: Colors.redAccent),
                  ),
                ]),
                label: 'Chat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'Schedule',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.currency_bitcoin),
                label: 'Finanace',
              ),
            ]
                : [
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
                      decoration: BoxDecoration(
                        color:
                        widget.isClient ? Colors.white : Colors.green,
                        borderRadius:
                        const BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: Icon(
                          widget.isClient ? Icons.info : Icons.camera_alt,
                          color: Colors.white,
                          size: 40.0),
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
        ),
      ),
    );
  }
}