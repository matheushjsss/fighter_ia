import 'package:fighter_ia/src/models/ufc_event_model.dart';
import 'package:fighter_ia/src/models/ufc_fight_model.dart';

/// Detalhe completo de um evento: cabeçalho + card de lutas.
class UfcEventDetailModel {
  final UfcEventHeaderModel event;
  final List<UfcFightModel> fights;

  UfcEventDetailModel({required this.event, required this.fights});

  factory UfcEventDetailModel.fromJson(Map<String, dynamic> json) {
    final fightsJson = json['fights'] as List? ?? [];
    return UfcEventDetailModel(
      event: UfcEventHeaderModel.fromJson(json['event'] as Map<String, dynamic>),
      fights: fightsJson.map((e) => UfcFightModel.fromJson(e)).toList(),
    );
  }
}
