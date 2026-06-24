import 'package:fighter_ia/src/http/resilient_http.dart';
import 'package:fighter_ia/src/models/fighter_detail_model.dart';
import 'package:fighter_ia/src/models/fighters_model.dart';
import 'package:http/http.dart';

class FightersRepository {
  final client = Client();

  Future<List<FightersModel>> getFighters({String? search}) async {
    final query = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    final uri = Uri.parse(
      '$apiBaseUrl/fighters',
    ).replace(queryParameters: query.isEmpty ? null : query);

    final data = await getJsonResilient(client, uri);
    if (data is List) {
      return data.map((e) => FightersModel.fromJson(e)).toList();
    }
    throw const FormatException('Resposta não é uma lista JSON');
  }

  Future<FighterDetailModel> getFighterDetails(int fighterId) async {
    final data = await getJsonResilient(
      client,
      Uri.parse('$apiBaseUrl/fighters/$fighterId'),
    );
    if (data is Map<String, dynamic>) {
      return FighterDetailModel.fromJson(data);
    }
    throw const FormatException('Resposta inesperada do detalhe do lutador');
  }
}
