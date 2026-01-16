import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_manage/helpers/error_helper.dart';

import '../helpers/cloudinary.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<Either<String, String>> signup(
    String email,
    String password,
    String title,
    String? imagePath,
  ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return Left("Failed to create user.");
      }

      await user.updateDisplayName(user.email?.split("@").first);
      await user.reload();

      final result = await saveUserData(user, title, imagePath);
      return result.fold(
        (failure) => Left(failure),
        (success) => Right("Welcome ${user.email?.split("@").first ?? ''}"),
      );
    } catch (e) {
      return Left(ErrorHelper.format(e.toString()));
    }
  }

  Future<Either<String, bool>> saveUserData(
    User user,
    String userTitle,
    String? imagePath,
  ) async {
    try {
      String? avatarUrl;
      if (imagePath != null) {
        avatarUrl = await saveToCloudinary(imagePath);
      }

      await firebaseFirestore.collection("users").doc(user.uid).set({
        "username": user.displayName ?? user.email?.split("@").first,
        "email": user.email,
        "uid": user.uid,
        "title": userTitle,
        "avatar": avatarUrl,
        "performance": 0,
      });

      return Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return Right("Welcome !!");
    } on FirebaseAuthException catch (e) {
      return Left(ErrorHelper.format(e.toString()));
    }
  }

  Future<Either<String, bool>> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return Right(true);
    } on FirebaseAuthException catch (e) {
      return Left(ErrorHelper.format(e.message.toString()));
    }
  }
}
