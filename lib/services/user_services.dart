import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:system_manage/models/member_model.dart';
import 'package:system_manage/models/project_models.dart';

class UserService {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<List<ProjectModel>> getUserProjects(String code, String uid) async {
    final result = await firebaseFirestore
        .collection("systems")
        .doc(code)
        .collection("projects")
        .get();

    final List<ProjectModel> userProjects = [];

    for (var doc in result.docs) {
      final data = doc.data();

      final members = (data['members'] as List? ?? [])
          .map((e) => MemberModel.fromMap(e))
          .toList();

      final isMember = members.any((mem) => mem.uid == uid);
      if (!isMember) continue;

      final tasksSnapshot = await firebaseFirestore
          .collection("systems")
          .doc(code)
          .collection("projects")
          .doc(doc.id)
          .collection("tasks")
          .get();

      final totalTasks = tasksSnapshot.docs.length;
      final finishedTasks = tasksSnapshot.docs
          .where((task) => task['status'] == 'done')
          .length;

      final progress = totalTasks == 0
          ? 0.0
          : (finishedTasks / totalTasks) * 100;

      userProjects.add(
        ProjectModel(
          projectId: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          startDate: data['startDate'] ?? '',
          endDate: data['endDate'] ?? '',
          status: data['status'] ?? '',
          members: members,
          links: data['links'] != null ? List<String>.from(data['links']) : [],
          steps: data['steps'] != null ? List<String>.from(data['steps']) : [],
          progress: progress,
        ),
      );
    }

    return userProjects;
  }

  Future<void> assignAttendanceToday(
    String code,
    String uid,
    String status,
  ) async {
    final today = DateTime.now();
    final docId = "${today.year}-${today.month}-${today.day}";

    final attendanceRecord = {'uid': uid, 'status': status, 'date': docId};

    final docRef = firebaseFirestore
        .collection("systems")
        .doc(code)
        .collection('attendance')
        .doc(uid);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      List attendance = data?['attendance'] ?? [];

      final index = attendance.indexWhere((a) => a['date'] == docId);

      if (index >= 0) {
        attendance[index] = attendanceRecord;
      } else {
        attendance.add(attendanceRecord);
      }

      await docRef.set({'attendance': attendance}, SetOptions(merge: true));
    } else {
      await docRef.set({
        'attendance': [attendanceRecord],
      });
    }
  }

  Future<List<Map<String, dynamic>>> getUserAttendance(
    String code,
    String uid,
  ) async {
    final docSnapshot = await firebaseFirestore
        .collection("systems")
        .doc(code)
        .collection("attendance")
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['attendance'] != null) {
        return List<Map<String, dynamic>>.from(data['attendance']);
      }
    }
    return [];
  }

  Future<void> updateUserPerformance(
      String uid, {
        required int present,
        required int remote,
        required int onLeave,
        required int completedTasks,
        required int allTasks,
      }) async {
    int totalAttendance = present + remote + onLeave;
    double attendanceScore = totalAttendance == 0
        ? 0
        : (present + 0.5 * remote) / totalAttendance * 100;
    double taskScore = allTasks == 0 ? 0 : completedTasks / allTasks * 100;
    double performanceScore = (attendanceScore * 0.6 + taskScore * 0.4);

    await firebaseFirestore.collection("users").doc(uid).update({
      "performance": performanceScore.toDouble(),
    });
  }


  Future<void> updateMemberPerformance(
      String systemCode,
      String memberUid, {
        required int present,
        required int remote,
        required int onLeave,
        required int completedTasks,
        required int allTasks,
      }) async {
    double attendanceScore = (present + 0.5 * remote) / (present + remote + onLeave) * 100;
    double taskScore = allTasks == 0 ? 0 : completedTasks / allTasks * 100;
    double performanceScore = (attendanceScore * 0.6 + taskScore * 0.4);

    final systemDocRef = firebaseFirestore.collection("systems").doc(systemCode);
    final docSnapshot = await systemDocRef.get();

    if (!docSnapshot.exists) return;

    final data = docSnapshot.data();
    if (data == null || !data.containsKey("members")) return;

    List members = List.from(data["members"]);

    final index = members.indexWhere((m) => m['uid'] == memberUid);
    if (index >= 0) {
      members[index]['performance'] = performanceScore.toDouble();
      await systemDocRef.update({"members": members});
    }
  }

}
