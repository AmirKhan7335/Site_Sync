
class UserModel {
  final String name;
  final String profilePic;
  final bool isOnline;
  final String email;
  final List <String> groupId;


  UserModel({
    required this.name,
    required this.profilePic,
    required this.email,
    required this.isOnline,
    required this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': name,
      'isOnline': isOnline,
      'profilePic': profilePic,
      'email': email,
      'groupId': groupId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      isOnline: map['isOnline'] ?? false,
      profilePic: map['profilePic'] ?? '',
      email: map['email'] ?? '',
      groupId: List<String>.from(map['groupId']),
    );
  }
}
