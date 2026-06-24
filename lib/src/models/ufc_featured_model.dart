class UfcFeaturedModel {
  final int eventId;
  final String eventName;
  final String eventDate;
  final int? fightId;
  final int? redId;
  final int? blueId;
  final String redCorner;
  final String blueCorner;
  final String redImg;
  final String blueImg;
  final String weightClass;
  final bool titleFight;

  UfcFeaturedModel({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.fightId,
    required this.redId,
    required this.blueId,
    required this.redCorner,
    required this.blueCorner,
    required this.redImg,
    required this.blueImg,
    required this.weightClass,
    required this.titleFight,
  });

  factory UfcFeaturedModel.fromJson(Map<String, dynamic> json) {
    final fight = json['fight'] as Map<String, dynamic>?;
    return UfcFeaturedModel(
      eventId: json['event_id'] as int,
      eventName: json['event_name'] ?? '',
      eventDate: json['event_date'] ?? '',
      fightId: fight?['fight_id'] as int?,
      redId: fight?['red_id'] as int?,
      blueId: fight?['blue_id'] as int?,
      redCorner: fight?['red_corner'] ?? 'TBA',
      blueCorner: fight?['blue_corner'] ?? 'TBA',
      redImg: fight?['red_img'] ?? '',
      blueImg: fight?['blue_img'] ?? '',
      weightClass: fight?['weight_class'] ?? '',
      titleFight: fight?['title_fight'] ?? false,
    );
  }
}
