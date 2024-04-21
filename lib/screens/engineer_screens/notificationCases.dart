import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../notifications/sendNotification.dart';

class NotificationCases {
  scheduleNotification(String email,String operation) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var getCnsltEmail =
      await firestore.collection('engineers').doc(email).get();
      var cnsltEmail = getCnsltEmail.data()!['consultantEmail'];

      var cnsltToken =
      await firestore.collection('users').doc(cnsltEmail).get();
      List token = cnsltToken.data()!['tokens'];
      var engName = await firestore.collection('users').doc(email).get();
      var engNameData = engName.data()!['username'];
      SendNotification().sendNotification(
          token[token.length-1], 'Schedule $operation', '$engNameData has $operation in the Schedule');
    } catch (e) {
      if (kDebugMode) {
        print('${e}error in scheduleUpdatedNotification');
      }
    }
  }
}