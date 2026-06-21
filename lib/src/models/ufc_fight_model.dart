class UfcFightModel {
  final int id;
  final String redCorner;
  final String blueCorner;
  final String weightClass;
  final bool titleFight;
  final int? roundsScheduled;

  UfcFightModel({
    required this.id,
    required this.redCorner,
    required this.blueCorner,
    required this.weightClass,
    required this.titleFight,
    this.roundsScheduled,
  });

  factory UfcFightModel.fromJson(Map<String, dynamic> json) {
    return UfcFightModel(
      id: json['id'] as int,
      redCorner: json['red_corner'] ?? 'TBA',
      blueCorner: json['blue_corner'] ?? 'TBA',
      weightClass: json['weight_class'] ?? '',
      titleFight: json['title_fight'] ?? false,
      roundsScheduled: json['rounds_scheduled'] as int?,
    );
  }
}
