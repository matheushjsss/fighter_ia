import 'dart:convert';

import 'package:fighter_ia/src/models/ufc_event_model.dart';
import 'package:fighter_ia/src/models/ufc_fight_model.dart';
import 'package:http/http.dart';

class UfcRepository {
  final client = Client();

  // 10.0.2.2 é o localhost do host quando rodando no emulador Android
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<UfcEventModel>> getEvents() async {
    final response = await client.get(Uri.parse('$baseUrl/ufc/events'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => UfcEventModel.fromJson(e)).toList();
    }
    throw Exception('Erro ao carregar eventos: ${response.statusCode}');
  }

  Future<List<UfcFightModel>> getFights(int eventId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/ufc/events/$eventId/fights'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => UfcFightModel.fromJson(e)).toList();
    }
    throw Exception('Erro ao carregar lutas: ${response.statusCode}');
  }
}
