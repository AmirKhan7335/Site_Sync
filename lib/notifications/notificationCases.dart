import 'package:amir_khan1/notifications/sendNotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificationCases {
  scheduleNotification(String email, String operation) async {
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
          token[token.length - 1],
          'Schedule ${operation}',
          '${engNameData} has ${operation} in the Schedule');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString() + 'error in scheduleUpdatedNotification');
      }
    }
  }

  requestToConsultantNotification(
      String role, String cnsltEmail, String email) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var cnsltToken =
      await firestore.collection('users').doc(cnsltEmail).get();
      List token = cnsltToken.data()!['tokens'];
      var engName = await firestore.collection('users').doc(email).get();
      var engNameData = engName.data()!['username'];
      SendNotification().sendNotification(token[token.length - 1],
          '${role} Request', '${engNameData} wants to join Your Project');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString() + 'error in scheduleUpdatedNotification');
      }
    }
  }

  requestAcceptanceorDecline(String engEmail, String status) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var cnsltToken = await firestore.collection('users').doc(engEmail).get();
      List token = cnsltToken.data()!['tokens'];

      SendNotification().sendNotification(token[token.length - 1],
          'Request ${status}', 'Your Request has been ${status}');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString() + 'error in scheduleUpdatedNotification');
      }
    }
  }

  docUploadedByEngineerNotification(String operation) async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // var role =await firestore.collection('users').doc(email).get();
      // var getRole=role.data()!['role'];
      var getCnsltEmail =
      await firestore.collection('engineers').doc(email).get();
      var cnsltEmail = getCnsltEmail.data()!['consultantEmail'];

      var cnsltToken =
      await firestore.collection('users').doc(cnsltEmail).get();
      List token = cnsltToken.data()!['tokens'];
      var engName = await firestore.collection('users').doc(email).get();
      var engNameData = engName.data()!['username'];
      SendNotification().sendNotification(
          token[token.length - 1],
          '${operation} Uploaded',
          '${engNameData} has Uploaded a New ${operation}');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString() + 'error in scheduleUpdatedNotification');
      }
    }
  }

  docUploadedByConsultantNotification(String operation, String projId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var getEngEmail = await firestore
          .collection('engineers')
          .where('projectId', isEqualTo: projId)
          .get();
      var engEmail = getEngEmail.docs[0].id;

      var cnsltToken = await firestore.collection('users').doc(engEmail).get();
      List token = cnsltToken.data()!['tokens'];
      SendNotification().sendNotification(
          token[token.length - 1],
          '${operation} Uploaded',
          'A New Document has been Uploaded ');
      var getclientEmail = await firestore
          .collection('clients')
          .where('projectId', isEqualTo: projId)
          .get();
      var clientEmail = getEngEmail.docs[0].id;
      if(clientEmail.isNotEmpty){

        var cnsltToken = await firestore.collection('users').doc(clientEmail).get();
        List token = cnsltToken.data()!['tokens'];
        SendNotification().sendNotification(
            token[token.length - 1],
            '${operation} Uploaded',
            'A New Document has been Uploaded');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString() + 'error in scheduleUpdatedNotification');
      }
    }
  }

  testUploadedNotification(String projId) async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var role = await firestore.collection('users').doc(email).get();
      var getRole = role.data()!['role'];
      if (getRole == 'Engineer') {
        var getCnsltEmail =
        await firestore.collection('engineers').doc(email).get();
        var cnsltEmail = getCnsltEmail.data()!['consultantEmail'];

        var cnsltToken =
        await firestore.collection('users').doc(cnsltEmail).get();
        List token = cnsltToken.data()!['tokens'];
        var engName = await firestore.collection('users').doc(email).get();
        var engNameData = engName.data()!['username'];
        SendNotification().sendNotification(token[token.length - 1],
            'Test Uploaded', '${engNameData} has Uploaded a New Test');
      } else if (getRole == 'Contractor') {
        var getEngEmail = await firestore
            .collection('engineers')
            .where('projectId', isEqualTo: projId)
            .get();
        var engEmail = getEngEmail.docs[0].id;

        var cnsltToken =
        await firestore.collection('users').doc(engEmail).get();
        List token = cnsltToken.data()!['tokens'];
        SendNotification().sendNotification(token[token.length - 1],
            'Test Uploaded', 'A New Test has been Uploaded by Consultant');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString() + 'error in scheduleUpdatedNotification');
      }
    }
  }


  textMessageNotification(String senderId, String receiverId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var receiverToken =
      await firestore.collection('users').doc(receiverId).get();
      List token = receiverToken.data()!['tokens'];
      var senderName = await firestore.collection('users').doc(senderId).get();
      var senderNameData = senderName.data()!['username'];
      SendNotification().sendNotification(
          token[token.length - 1],
          'Message Received',
          '${senderNameData} has Sent You a Message');
      await firestore.collection('users').doc(receiverId).update({
        'seen':false
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString() + 'error in textMessageNotification');
      }
    }
  }

}