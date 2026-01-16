import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:system_manage/models/user_model.dart';

class UserDataService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<UserModel> getUserData(String uid) async {
    final docData = await firebaseFirestore.collection("users").doc(uid).get();

    if (docData.exists && docData.data() != null) {
      return UserModel.fromJson(docData.data()!);
    } else {
      return UserModel(
        username: "username",
        email: "email",
        uid: "uid",
        title: "", performance: 0,
      );
    }
  }
}
