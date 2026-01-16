class AnnounceModel {
  final String name;
  final String desc;

  AnnounceModel({required this.name, required this.desc});

  factory AnnounceModel.fromJson(Map<String, dynamic> json) {
    return AnnounceModel(name: json['title'], desc: json['subtitle']);
  }
}
