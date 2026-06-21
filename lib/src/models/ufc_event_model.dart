class UfcEventModel {
  final int id;
  final String name;
  final String date;

  UfcEventModel({required this.id, required this.name, required this.date});

  factory UfcEventModel.fromJson(Map<String, dynamic> json) {
    return UfcEventModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
