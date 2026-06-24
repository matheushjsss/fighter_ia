class RankingModel {
  final int rank;
  final bool isChampion;
  final String rankChange;
  final String division;
  final String weightDivision;
  final int? fighterId;
  final String fighterName;
  final String imgFace;
  final String imgBody;
  final String record;

  RankingModel({
    required this.rank,
    required this.isChampion,
    required this.rankChange,
    required this.division,
    required this.weightDivision,
    required this.fighterId,
    required this.fighterName,
    required this.imgFace,
    required this.imgBody,
    required this.record,
  });

  /// Rótulo de posição: "C" para campeão, senão o número.
  String get positionLabel => isChampion ? 'C' : '$rank';

  /// Variação de posição parseada (ex.: "+2" -> 2, "-1" -> -1).
  int? get changeDelta {
    final m = RegExp(r'^([+-])(\d+)$').firstMatch(rankChange.trim());
    if (m == null) return null;
    final n = int.parse(m.group(2)!);
    return m.group(1) == '-' ? -n : n;
  }

  bool get movedUp => (changeDelta ?? 0) > 0;
  bool get movedDown => (changeDelta ?? 0) < 0;

  /// Campeão interino?
  bool get isInterim => rankChange.trim().toLowerCase() == 'interino';

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      rank: json['rank'] as int? ?? 0,
      isChampion: json['is_champion'] ?? false,
      rankChange: json['rank_change'] ?? '',
      division: json['division'] ?? '',
      weightDivision: json['weight_division'] ?? '',
      fighterId: json['fighter_id'] as int?,
      fighterName: json['fighter_name'] ?? '',
      imgFace: json['img_face'] ?? '',
      imgBody: json['img_body'] ?? '',
      record: json['record'] ?? '',
    );
  }
}

/// Um fight center (UFC, Bellator...) com seu Pound-for-Pound.
class RankingFightCenterModel {
  final int fcId;
  final String fcName;
  final List<RankingModel> p4p;

  RankingFightCenterModel({
    required this.fcId,
    required this.fcName,
    required this.p4p,
  });

  /// Sigla curta para o selo (UFC -> "UFC", Bellator -> "B").
  String get badge => fcName.length <= 4 ? fcName : fcName[0];

  factory RankingFightCenterModel.fromJson(Map<String, dynamic> json) {
    final list = (json['p4p'] as List? ?? [])
        .map((e) => RankingModel.fromJson(e))
        .toList();
    return RankingFightCenterModel(
      fcId: json['fc_id'] as int,
      fcName: json['fc_name'] ?? '',
      p4p: list,
    );
  }
}

/// Uma divisão de um fight center (para os chips).
class RankingDivisionModel {
  final String division;
  final bool isP4p;

  RankingDivisionModel({required this.division, required this.isP4p});

  /// Rótulo curto para o chip, ex.: "PESO POR PESO", "PESADO", "LEVE".
  String get shortLabel {
    const map = {
      "men's pound-for-pound": 'PESO POR PESO',
      'peso por peso feminino': 'P4P FEMININO',
      'peso-pesado': 'PESADO',
      'peso meio-pesado': 'MEIO-PESADO',
      'peso-médio': 'MÉDIO',
      'peso meio-médio': 'MEIO-MÉDIO',
      'peso-leve': 'LEVE',
      'peso-pena': 'PENA',
      'peso-galo': 'GALO',
      'peso-mosca': 'MOSCA',
      'peso-palha feminino': 'PALHA FEM.',
      'peso-galo feminino': 'GALO FEM.',
      'peso-mosca feminino': 'MOSCA FEM.',
    };
    return map[division.toLowerCase()] ?? division.toUpperCase();
  }

  factory RankingDivisionModel.fromJson(Map<String, dynamic> json) {
    return RankingDivisionModel(
      division: json['division'] ?? '',
      isP4p: json['is_p4p'] ?? false,
    );
  }
}
