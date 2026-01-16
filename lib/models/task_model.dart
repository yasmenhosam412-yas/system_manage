import 'member_model.dart';

class TaskModel {
  final String id;
  final String name;
  final String description;
  final String assignedMemberUid;
  final String assignedMemberName;
  final String status;
  final String deadline;
  TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.assignedMemberUid,
    required this.assignedMemberName,
    required this.status,
    required this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deadline': deadline,
      'assignedMember': {
        'uid': assignedMemberUid,
        'username': assignedMemberName,
      },
      'status': status,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      assignedMemberUid: map['assignedMember']['uid'],
      assignedMemberName: map['assignedMember']['username'],
      status: map['status'],
      deadline: map['deadline']
    );
  }
}



class ProjectTasksModel {
  final String projectId;
  final String name;
  final String description;
  final List<MemberModel> members;
  final List<TaskModel> tasks;

  ProjectTasksModel({
    required this.projectId,
    required this.name,
    required this.description,
    required this.members,
    required this.tasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'name': name,
      'description': description,
      'members': members.map((m) => m.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
    };
  }

  factory ProjectTasksModel.fromMap(Map<String, dynamic> map, String projectId) {
    return ProjectTasksModel(
      projectId: projectId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      members: (map['members'] as List<dynamic>? ?? [])
          .map((m) => MemberModel.fromMap(m))
          .toList(),
      tasks: (map['tasks'] as List<dynamic>? ?? [])
          .map((t) => TaskModel.fromMap(t))
          .toList(),
    );
  }
}
