import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  RxInt engCurrentIndex = 0.obs;
  RxInt cnsltCurrentIndex = 0.obs;
  RxInt contrCurrentIndex = 0.obs;
  RxBool seen = true.obs;
  getSeenStatus() async {
    try {
      final email = await FirebaseAuth.instance.currentUser!.email;
      var query =
      await FirebaseFirestore.instance.collection('users').doc(email).get();

      var status = query.data()!['seen'];
      this.seen.value = status;
      debugPrint('Seen status:------> ${seen.value}');
    } catch (e) {
      debugPrint('Error getting seen status: $e');
    }
  }
}