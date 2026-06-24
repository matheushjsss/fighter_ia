class FightersModel {
  final int id;
  final String name;
  final String nickname;
  final String record;
  final String imgFace;
  final String imgBody;
  final String country;

  FightersModel({
    required this.id,
    required this.name,
    required this.nickname,
    required this.record,
    required this.imgFace,
    required this.imgBody,
    required this.country,
  });

  /// Imagem preferida para listagem: rosto; se não houver, o corpo inteiro.
  String get img => imgFace.isNotEmpty ? imgFace : imgBody;

  factory FightersModel.fromJson(Map<String, dynamic> json) {
    return FightersModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      nickname: json['nickname'] ?? '',
      record: json['record'] ?? '',
      imgFace: json['img_face'] ?? '',
      imgBody: json['img_body'] ?? '',
      country: json['country'] ?? '',
    );
  }
}
