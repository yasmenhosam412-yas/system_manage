import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/anncounce_model.dart';
import '../models/member_model.dart';
import '../models/task_model.dart';

class SystemService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<List<MemberModel>> getSystemMembers(String systemCode) async {
    final docSnapshot = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .get();

    if (!docSnapshot.exists) return [];

    final data = docSnapshot.data();
    if (data == null || !data.containsKey("members")) return [];

    final List membersData = data["members"];

    return membersData
        .map(
          (member) => MemberModel(
            uid: member['uid'],
            department: member['department'],
            image: member['avatar'],
            performance: member['performance'],
            title: member['title'],
            username: member['username'],
          ),
        )
        .toList();
  }

  Future<List<MemberModel>> getProjectMembers(
    String systemCode,
    String projectId,
  ) async {
    final docSnapshot = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .collection("projects")
        .doc(projectId)
        .get();

    if (!docSnapshot.exists) return [];

    final data = docSnapshot.data();
    if (data == null || !data.containsKey("members")) return [];

    final List membersData = data["members"];

    return membersData
        .map(
          (member) => MemberModel(
            uid: member['uid'],
            department: member['department'],
            image: member['avatar'],
            performance: member['performance'],
            title: member['title'],
            username: member['username'],
          ),
        )
        .toList();
  }

  Future<List<String>> getSystemDeps(String systemCode) async {
    final docSnapshot = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey("departments")) {
        final members = List<String>.from(data["departments"]);
        return members;
      }
    }
    return [];
  }

  Future<void> addAnncounce(
    String systemCode,
    String name,
    String desc,
    List<MemberModel> mems,
  ) async {
    await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .collection("announcements")
        .add({
          "sysem_code": systemCode,
          "title": name,
          "subtitle": desc,
          "mems": mems.map((e) => e.toMap()).toList(),
          "createdAt": FieldValue.serverTimestamp(),
        });
  }

  Future<void> addTask(
    String systemCode,
    String name,
    String desc,
    MemberModel member,
    String memberName,
    String projectId,
    String deadline,
  ) async {
    final taskRef = firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .collection("projects")
        .doc(projectId)
        .collection("tasks")
        .doc();

    final taskData = {
      'id': taskRef.id,
      'name': name,
      'description': desc,
      'assignedMember': {'uid': member.uid, 'username': memberName},
      'status': 'pending',
      'deadline': deadline,
      "projectId": projectId,
    };

    await taskRef.set(taskData);
  }

  Future<List<ProjectTasksModel>> getProjectsWithTasks(
    String systemCode,
  ) async {
    final projectsSnapshot = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .collection("projects")
        .get();

    final projects = <ProjectTasksModel>[];

    for (var projectDoc in projectsSnapshot.docs) {
      final projectData = projectDoc.data();

      final tasksSnapshot = await firebaseFirestore
          .collection("systems")
          .doc(systemCode)
          .collection("projects")
          .doc(projectDoc.id)
          .collection("tasks")
          .get();

      final tasks = tasksSnapshot.docs.map((doc) {
        final data = doc.data();
        return TaskModel(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          assignedMemberUid: data['assignedMember']['uid'],
          assignedMemberName: data['assignedMember']['username'],
          status: data['status'],
          deadline: data['deadline'],
        );
      }).toList();

      projects.add(
        ProjectTasksModel(
          projectId: projectDoc.id,
          name: projectData['name'] ?? '',
          description: projectData['description'] ?? '',
          members: (projectData['members'] as List<dynamic>? ?? [])
              .map(
                (m) => MemberModel(
                  uid: m['uid'],
                  department: m['department'],
                  image: m['avatar'],
                  performance: m['performance'],
                  title: m['title'],
                  username: m['username'],
                ),
              )
              .toList(),
          tasks: tasks,
        ),
      );
    }

    return projects;
  }

  Future<List<MemberModel>> getSystemEmployees(String systemCode) async {
    final docSnapshot = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .get();

    if (!docSnapshot.exists) return [];

    final data = docSnapshot.data();
    if (data == null || !data.containsKey("members")) return [];

    final List membersData = data["members"];

    return membersData
        .map(
          (member) => MemberModel(
            uid: member['uid'],
            department: member['department'],
            image: member['avatar'],
            performance: member['performance'],
            title: member['title'],
            username: member['username'],
          ),
        )
        .toList();
  }

  Future<List<String>> getEmployeeProject(String uid, String systemCode) async {
    final snapshot = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .collection("projects")
        .get();

    final projects = snapshot.docs
        .where((doc) {
          final members = List<Map<String, dynamic>>.from(doc["members"] ?? []);
          return members.any((member) => member["uid"] == uid);
        })
        .map((doc) => doc["name"] as String)
        .toList();

    return projects;
  }

  Future<Map<String, List<Map<String, dynamic>>>> getUserTasksInProjects(
    String uid,
    String systemCode,
  ) async {
    final projectsSnapshot = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .collection("projects")
        .get();

    Map<String, List<Map<String, dynamic>>> userTasks = {};

    for (var project in projectsSnapshot.docs) {
      final projectName = project["name"] as String;

      final tasksSnapshot = await project.reference.collection("tasks").get();

      final tasks = tasksSnapshot.docs
          .where((task) {
            final assigned = task.data()["assignedMember"];
            return assigned != null && assigned["uid"] == uid;
          })
          .map((task) {
            final data = task.data();
            return {
              "id": data["id"],
              "name": data["name"],
              "status": data["status"],
              "deadline": data["deadline"],
              "description": data["description"],
              "projectId"   : data['projectId']
            };
          })
          .toList();

      if (tasks.isNotEmpty) {
        userTasks[projectName] = tasks;
      }
    }

    return userTasks;
  }

  Future<List<AnnounceModel>> getAnncounce(
    String systemCode,
    String uid,
  ) async {
    final List<AnnounceModel> userAnnouncements = [];

    final querySnapshot = await firebaseFirestore
        .collection("systems")
        .doc(systemCode)
        .collection("announcements")
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      if (data.containsKey('mems') && data['mems'] is List) {
        final List<MemberModel> mems = (data['mems'] as List)
            .map((e) => MemberModel.fromMap(e as Map<String, dynamic>))
            .toList();

        final bool hasUser = mems.any((member) => member.uid == uid);

        if (hasUser) {
          final announce = AnnounceModel.fromJson(data);
          userAnnouncements.add(announce);
        }
      }
    }

    return userAnnouncements;
  }

  Future<void> updateTaskStatus({
    required String systemCode,
    required String projectId,
    required String taskId,
    required String status,
  }) async {
    await firebaseFirestore
        .collection('systems')
        .doc(systemCode)
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .update({'status': status});
  }
}
