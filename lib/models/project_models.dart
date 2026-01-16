import 'package:system_manage/models/member_model.dart';

class ProjectModel {
  final String projectId;
  final String name;
  final String description;
  final String startDate;
  final String endDate;
  final String status;
  final List<MemberModel> members;
  final List<String> links;
  final List<String> steps;
  final double progress;

  ProjectModel({
    required this.projectId,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.members,
    required this.links,
    required this.steps,
    required this.progress,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'members': members.map((m) => m.toMap()).toList(),
      'links': links,
      'steps': steps,
      "progress": progress,
      "id": projectId,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    List<MemberModel> membersList = [];
    if (map['members'] != null) {
      if (map['members'] is List) {
        membersList = (map['members'] as List)
            .map(
              (x) => x is Map<String, dynamic>
                  ? MemberModel.fromMap(x)
                  : MemberModel.fromMap({}),
            )
            .toList();
      } else if (map['members'] is String) {
        try {
          final parsed = List<Map<String, dynamic>>.from(
            (map['members'] as String).isNotEmpty
                ? List<Map<String, dynamic>>.from([])
                : [],
          );
          membersList = parsed.map((x) => MemberModel.fromMap(x)).toList();
        } catch (_) {
          membersList = [];
        }
      }
    }

    return ProjectModel(
      projectId: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      startDate: map['startDate']?.toString() ?? '',
      endDate: map['endDate']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      members: membersList,
      links: map['links'] != null
          ? List.from(map['links']).whereType<String>().toList()
          : [],
      steps: map['steps'] != null
          ? List.from(map['steps']).whereType<String>().toList()
          : [],
      progress: map['progress'] != null
          ? (map['progress'] is double
                ? map['progress']
                : double.tryParse(map['progress'].toString()) ?? 0)
          : 0.0,
    );
  }
}
