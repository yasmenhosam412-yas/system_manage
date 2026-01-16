import 'package:system_manage/models/member_model.dart';

class SystemModel {
  final String code;
  final String name;
  final List<String> deps;
  final List<String> workDays;
  final String startTime;
  final String endTime;
  final String systemImage;

  SystemModel({
    required this.name,
    required this.code,
    required this.deps,
    required this.startTime,
    required this.endTime,
    required this.workDays,
    required this.systemImage,
  });

  factory SystemModel.fromMap(Map<String, dynamic> json) {
    return SystemModel(
      name: json['name'],
      code: json['code'],
      deps: List<String>.from(json['departments'] ?? []),
      workDays: List<String>.from(json['workDays'] ?? []),
      startTime: json['start_time'],
      endTime: json['end_time'],
      systemImage: json['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "code": code,
      "name": name,
      "departments": deps,
      "start_time": startTime,
      "end_time": endTime,
      "workDays": workDays,
      "image": systemImage,
    };
  }
}
