import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:system_manage/models/member_model.dart';

import '../models/project_models.dart';

class ProjectService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<void> addProject(
    String systemCode,
    String name,
    String desc,
    String startTime,
    String endTime,
    String status,
    List<MemberModel> members,
    List<String> links,
    List<String> steps,
    double progress,
  ) async {
    final membersMap = members.map((m) => m.toMap()).toList();

    final docRef = firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .collection("projects")
        .doc();

    await docRef.set({
      "id": docRef.id,
      "name": name,
      "description": desc,
      "startDate": startTime,
      "endDate": endTime,
      "status": status,
      "members": membersMap,
      "links": links,
      "progress": progress,
      "steps": steps,
    });
  }

  Future<List<ProjectModel>> getProjects(String systemCode) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("systems")
        .doc(systemCode)
        .collection("projects")
        .get();

    List<ProjectModel> projects = snapshot.docs.map((doc) {
      return ProjectModel.fromMap(doc.data());
    }).toList();

    return projects;
  }

  Future<void> updateProjects({
    required String systemCode,
    required String projectID,
    required String name,
    required String desc,
    required String startTime,
    required String endTime,
    required String status,
    required int progress,
    required List<MemberModel> members,
    required List<String> links,
    required List<String> steps,
  }) async {

    final membersMap = members.map((m) => m.toMap()).toList();

    final projectRef = FirebaseFirestore.instance
        .collection('systems')
        .doc(systemCode)
        .collection('projects')
        .doc(projectID);

    await projectRef.update({
      'id': projectID,
      'name': name,
      'description': desc,
      'startDate': startTime,
      'endDate': endTime,
      'status': status,
      'members': membersMap,
      'links': links,
      'steps': steps,
      'progress': progress,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProjects(String systemCode, String projectID) async {
    await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .collection("projects")
        .doc(projectID)
        .delete();
  }
}
