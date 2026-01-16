class UserModel {
  final String username;
  final String email;
  final String? image;
  final String uid;
  final String title;
  final dynamic performance;

  UserModel({
    required this.username,
    required this.email,
    this.image,
    required this.uid,
    required this.title,
    required this.performance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      email: json['email'],
      image: json['avatar'] ?? "",
      uid: json['uid'],
      title: json['title'],
      performance: json['performance'],
    );
  }
}
