class MemberModel {
  final String uid;
  final String department;
  final String username;
  final String image;
  final dynamic performance;
  final String title;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'department': department,
      "avatar": image,
      "performance": performance,
      "title": title,
      "username" : username
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      uid: map['uid'],
      department: map['department'],
      image: map['avatar'],
      performance: map['performance'],
      title: map['title'],
      username: map['username'],
    );
  }

  MemberModel({
    required this.uid,
    required this.department,
    required this.username,
    required this.image,
    required this.performance,
    required this.title,
  });
}
