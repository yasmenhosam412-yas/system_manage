import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:system_manage/helpers/cloudinary.dart';
import 'package:system_manage/models/user_model.dart';
import '../models/system_model_selection.dart';

class CreateSystemService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<void> createSystem(
    String systemName,
    List<String> departments,
    String startTime,
    String endTime,
    List<String> workDays,
    String systemImage,
    String systemCode,
  ) async {
    final imgSystem = await saveToCloudinary(systemImage);

    await firebaseFirestore.collection("systems").doc(systemCode).set({
      "ownerId": auth.currentUser?.uid,
      "name": systemName,
      "start_time": startTime,
      "end_time": endTime,
      "workDays": workDays,
      "departments": departments,
      "image": imgSystem,
      "code": systemCode,
      "memberIds": [auth.currentUser?.uid],
      "members": [
        {
          "uid": auth.currentUser?.uid,
          "department": "Admin",
          "avatar": await saveToCloudinary(systemImage),
          "performance": 100,
          "title": "Admin",
          "username": "Admin",
        },
      ],
    });
  }

  Future<List<SystemModelSelection>> getSystem(String uid) async {
    final snapshot = await firebaseFirestore
        .collection("systems")
        .where("memberIds", arrayContains: uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SystemModelSelection(
        systemImage: data['image'] ?? '',
        systemName: data['name'] ?? '',
        systemOwner: data['ownerId'],
        systemCode: data['code'],
      );
    }).toList();
  }

  Future<bool> requestJoinSystem(
    String systemCode,
    String username,
    String image,
    String email,
    String jopTitle,
    int performace,
  ) async {
    final userUid = auth.currentUser?.uid;

    final isSystem = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .get();
    if (isSystem.exists) {
      await firebaseFirestore
          .collection("systems")
          .doc(systemCode)
          .collection('requests')
          .doc(userUid)
          .set({
            'uid': userUid,
            "username": username,
            "avatar": image,
            "email": email,
            "title": jopTitle,
            "performance": performace,
          });
      return true;
    } else {
      return false;
    }
  }

  Future<List<UserModel>> getRequests(String systemCode) async {
    final snapshot = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .collection("requests")
        .get();

    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  Future<void> acceptRequest({
    required String systemCode,
    required UserModel user,
    required String department,
  }) async {
    final systemRef = firebaseFirestore.collection("systems").doc(systemCode);

    await systemRef.update({
      "members": FieldValue.arrayUnion([
        {
          "uid": user.uid,
          "department": department,
          "username": user.username,
          "title": user.title,
          "performance": 0,
          "avatar": user.image,
        },
      ]),
      "memberIds": FieldValue.arrayUnion([user.uid]),
    });

    await systemRef.collection("requests").doc(user.uid).delete();
  }

  Future<void> rejectRequest({
    required String systemCode,
    required String userUid,
  }) async {
    await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .collection("requests")
        .doc(userUid)
        .delete();
  }
}
