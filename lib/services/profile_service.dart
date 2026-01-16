import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_manage/helpers/cloudinary.dart';

import '../models/system_model.dart';

class ProfileService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> updatePass(String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;

    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);

    await user.updatePassword(newPassword);
  }

  Future<void> updateUsername(String username) async {
    final uid = firebaseAuth.currentUser!.uid;
    await firebaseFirestore.collection("users").doc(uid).update({
      "username": username,
    });
  }

  Future<void> updateImage(String image) async {
    final uid = firebaseAuth.currentUser!.uid;
    final userImage = await saveToCloudinary(image);
    await firebaseFirestore.collection("users").doc(uid).update({
      "avatar": userImage,
    });
  }

  Future<SystemModel> getSystem(String systemCode) async {
    final snapshot = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .get();

    return SystemModel.fromMap(snapshot.data()!);
  }

  Future<SystemModel> updateSystem(
    String systemCode,
    SystemModel systemModel,
  ) async {
    await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .update(systemModel.toMap());

    final snapshot = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .get();

    return SystemModel.fromMap(snapshot.data()!);
  }
}
