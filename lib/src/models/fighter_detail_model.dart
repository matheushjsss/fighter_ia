class FighterDetailModel {
  final int id;
  final String name;
  final String nickname;
  final String record;
  final String imgFace;
  final String imgBody;
  final String height;
  final int? weight;
  final String reach;
  final String team;
  final String country;
  final int? age;

  FighterDetailModel({
    required this.id,
    required this.name,
    required this.nickname,
    required this.record,
    required this.imgFace,
    required this.imgBody,
    required this.height,
    required this.weight,
    required this.reach,
    required this.team,
    required this.country,
    required this.age,
  });

  /// Imagem preferida: corpo inteiro; se não houver, o rosto.
  String get img => imgBody.isNotEmpty ? imgBody : imgFace;

  /// Cartel "W-L-D" desmembrado.
  ({String wins, String losses, String draws}) get recordParts {
    final parts = record.split('-');
    return (
      wins: parts.isNotEmpty ? parts[0].trim() : '0',
      losses: parts.length > 1 ? parts[1].trim() : '0',
      draws: parts.length > 2 ? parts[2].trim() : '0',
    );
  }

  factory FighterDetailModel.fromJson(Map<String, dynamic> json) {
    return FighterDetailModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      nickname: json['nickname'] ?? '',
      record: json['record'] ?? '',
      imgFace: json['img_face'] ?? '',
      imgBody: json['img_body'] ?? '',
      height: json['height'] ?? '',
      weight: json['weight'] as int?,
      reach: json['reach'] ?? '',
      team: json['team'] ?? '',
      country: json['country'] ?? '',
      age: json['age'] as int?,
    );
  }
}
