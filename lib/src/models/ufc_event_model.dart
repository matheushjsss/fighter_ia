class UfcEventModel {
  final int id;
  final String name;
  final String date;
  final String fcCode;
  final String country;
  final int fightsCount;
  final bool upcoming;
  final String mainRed;
  final String mainBlue;
  final String mainRedRecord;
  final String mainBlueRecord;
  final String mainWeight;
  final bool titleFight;

  UfcEventModel({
    required this.id,
    required this.name,
    required this.date,
    this.fcCode = '',
    this.country = '',
    this.fightsCount = 0,
    this.upcoming = false,
    this.mainRed = '',
    this.mainBlue = '',
    this.mainRedRecord = '',
    this.mainBlueRecord = '',
    this.mainWeight = '',
    this.titleFight = false,
  });

  /// Sigla curta para o selo da organização (UFC, B, PFL...).
  String get badge => fcCode.length <= 4 && fcCode.isNotEmpty
      ? fcCode
      : (fcCode.isNotEmpty ? fcCode[0] : '?');

  bool get hasMain => mainRed.isNotEmpty && mainRed != 'TBA';

  factory UfcEventModel.fromJson(Map<String, dynamic> json) {
    return UfcEventModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      fcCode: json['fc_code'] ?? '',
      country: json['country'] ?? '',
      fightsCount: json['fights_count'] as int? ?? 0,
      upcoming: json['upcoming'] ?? false,
      mainRed: json['main_red'] ?? '',
      mainBlue: json['main_blue'] ?? '',
      mainRedRecord: json['main_red_record'] ?? '',
      mainBlueRecord: json['main_blue_record'] ?? '',
      mainWeight: json['main_weight'] ?? '',
      titleFight: json['title_fight'] ?? false,
    );
  }
}

/// Cabeçalho do detalhe do evento (organização, país, nº de lutas).
class UfcEventHeaderModel {
  final int id;
  final String name;
  final String date;
  final String fcCode;
  final String country;
  final int fightsCount;

  UfcEventHeaderModel({
    required this.id,
    required this.name,
    required this.date,
    required this.fcCode,
    required this.country,
    required this.fightsCount,
  });

  String get badge => fcCode.length <= 4 && fcCode.isNotEmpty
      ? fcCode
      : (fcCode.isNotEmpty ? fcCode[0] : '?');

  factory UfcEventHeaderModel.fromJson(Map<String, dynamic> json) {
    return UfcEventHeaderModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      fcCode: json['fc_code'] ?? '',
      country: json['country'] ?? '',
      fightsCount: json['fights_count'] as int? ?? 0,
    );
  }
}
