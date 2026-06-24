import 'package:fighter_ia/src/http/resilient_http.dart';
import 'package:fighter_ia/src/models/ufc_event_model.dart';
import 'package:fighter_ia/src/models/ufc_featured_model.dart';
import 'package:fighter_ia/src/models/ufc_fight_model.dart';
import 'package:fighter_ia/src/models/ufc_fight_result_model.dart';
import 'package:http/http.dart';

class UfcRepository {
  final client = Client();

  Future<List<UfcEventModel>> getEvents() async {
    final data = await _getList(Uri.parse('$apiBaseUrl/ufc/events'));
    return data.map((e) => UfcEventModel.fromJson(e)).toList();
  }

  Future<List<UfcFightModel>> getFights(int eventId) async {
    final data = await _getList(
      Uri.parse('$apiBaseUrl/ufc/events/$eventId/fights'),
    );
    // As imagens vêm do banco (img_body) já no JSON de cada luta.
    return data.map((e) => UfcFightModel.fromJson(e)).toList();
  }

  Future<UfcFeaturedModel?> getFeatured() async {
    final data = await getJsonResilient(
      client,
      Uri.parse('$apiBaseUrl/ufc/featured'),
    );
    if (data is Map<String, dynamic>) {
      return UfcFeaturedModel.fromJson(data);
    }
    return null;
  }

  Future<UfcFightResultModel> getFightDetail(int fightId) async {
    final data = await getJsonResilient(
      client,
      Uri.parse('$apiBaseUrl/ufc/fights/$fightId'),
    );
    if (data is Map<String, dynamic>) {
      return UfcFightResultModel.fromJson(data);
    }
    throw const FormatException('Resposta inesperada do detalhe da luta');
  }

  Future<List<dynamic>> _getList(Uri url) async {
    final decoded = await getJsonResilient(client, url);
    if (decoded is List) return decoded;
    throw const FormatException('Resposta não é uma lista JSON');
  }
}
