
import 'package:amir_khan1/models/activity.dart';

class UserData {
  final String username;
  final String? profilePicUrl;
  final List<Activity>? activities;

  UserData({required this.username, this.profilePicUrl, this.activities});

  @override
  String toString() {
    return username;
  }
}