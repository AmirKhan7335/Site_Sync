import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SaveTokens{
  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    final email =await FirebaseAuth.instance.currentUser!.email;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .update({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }
}