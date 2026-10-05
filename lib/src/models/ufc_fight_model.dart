class UfcFightModel {
  final int id;
  final int? redId;
  final int? blueId;
  final String redCorner;
  final String blueCorner;
  final String redRecord;
  final String blueRecord;
  final String redCountry;
  final String blueCountry;
  final String redCountrySigla;
  final String blueCountrySigla;
  final String redImg;
  final String blueImg;
  final String redImgFace;
  final String blueImgFace;
  final String weightClass;
  final String weightLimitLbs;
  final bool titleFight;
  final int? roundsScheduled;

  UfcFightModel({
    required this.id,
    required this.redId,
    required this.blueId,
    required this.redCorner,
    required this.blueCorner,
    required this.redRecord,
    required this.blueRecord,
    required this.redCountry,
    required this.blueCountry,
    this.redCountrySigla = '',
    this.blueCountrySigla = '',
    required this.redImg,
    required this.blueImg,
    required this.redImgFace,
    required this.blueImgFace,
    required this.weightClass,
    required this.weightLimitLbs,
    required this.titleFight,
    this.roundsScheduled,
  });

  factory UfcFightModel.fromJson(Map<String, dynamic> json) {
    return UfcFightModel(
      id: json['id'] as int,
      redId: json['red_id'] as int?,
      blueId: json['blue_id'] as int?,
      redCorner: json['red_corner'] ?? 'TBA',
      blueCorner: json['blue_corner'] ?? 'TBA',
      redRecord: json['red_record'] ?? '',
      blueRecord: json['blue_record'] ?? '',
      redCountry: json['red_country'] ?? '',
      blueCountry: json['blue_country'] ?? '',
      redCountrySigla: json['red_country_sigla'] ?? '',
      blueCountrySigla: json['blue_country_sigla'] ?? '',
      redImg: json['red_img'] ?? '',
      blueImg: json['blue_img'] ?? '',
      redImgFace: json['red_img_face'] ?? '',
      blueImgFace: json['blue_img_face'] ?? '',
      weightClass: json['weight_class'] ?? '',
      weightLimitLbs: (json['weight_limit_lbs'] ?? '').toString(),
      titleFight: json['title_fight'] ?? false,
      roundsScheduled: json['rounds_scheduled'] as int?,
    );
  }

  // Tradução das categorias de peso para PT (estilo site do UFC).
  static const Map<String, String> _weightPt = {
    'strawweight': 'Peso Palha',
    'flyweight': 'Peso Mosca',
    'bantamweight': 'Peso Galo',
    'featherweight': 'Peso Pena',
    'lightweight': 'Peso Leve',
    'welterweight': 'Peso Meio-Médio',
    'middleweight': 'Peso Médio',
    'light heavyweight': 'Peso Meio-Pesado',
    'heavyweight': 'Peso Pesado',
    'catchweight': 'Peso Casado',
    '115': 'Peso Palha',
    '125': 'Peso Mosca',
    '135': 'Peso Galo',
    '145': 'Peso Pena',
    '155': 'Peso Leve',
    '170': 'Peso Meio-Médio',
    '185': 'Peso Médio',
    '205': 'Peso Meio-Pesado',
    '265': 'Peso Pesado',
  };

  /// Nome da categoria em PT e maiúsculas, ex.: "PESO PESADO".
  String get weightLabelPt {
    final raw = weightClass.trim();
    if (raw.isEmpty) return '';
    final pt = _weightPt[raw.toLowerCase()];
    if (pt != null) return pt.toUpperCase();
    // Número avulso (ex.: "171") = luta casada (catchweight).
    if (RegExp(r'^\d+$').hasMatch(raw)) return 'PESO CASADO';
    return raw.toUpperCase();
  }

  /// Limite da categoria convertido para kg, ex.: "120KG". Vazio se desconhecido.
  String get weightKg {
    final lbs = int.tryParse(weightLimitLbs.trim());
    if (lbs == null || lbs <= 0) return '';
    final kg = (lbs * 0.45359237).round();
    return '${kg}KG';
  }

  /// Cabeçalho completo, ex.: "PESO PESADO 120KG".
  String get weightHeader {
    final parts = [weightLabelPt, weightKg].where((s) => s.isNotEmpty);
    return parts.join(' ');
  }
}
