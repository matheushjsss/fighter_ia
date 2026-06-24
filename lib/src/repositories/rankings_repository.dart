import 'package:fighter_ia/src/http/resilient_http.dart';
import 'package:fighter_ia/src/models/ranking_model.dart';
import 'package:http/http.dart';

class RankingsRepository {
  final client = Client();

  /// Ranking Pound-for-Pound (masculino) do UFC.
  Future<List<RankingModel>> getPoundForPound() async {
    final data = await getJsonResilient(
      client,
      Uri.parse('$apiBaseUrl/rankings/pound-for-pound'),
    );
    return _asRankingList(data);
  }

  /// Fight centers (UFC, Bellator...) cada um com seu P4P.
  Future<List<RankingFightCenterModel>> getFightCenters() async {
    final data = await getJsonResilient(
      client,
      Uri.parse('$apiBaseUrl/rankings/fightcenters'),
    );
    if (data is List) {
      return data.map((e) => RankingFightCenterModel.fromJson(e)).toList();
    }
    throw const FormatException('Resposta não é uma lista JSON');
  }

  /// Divisões disponíveis de um fight center.
  Future<List<RankingDivisionModel>> getDivisions(int fcId) async {
    final data = await getJsonResilient(
      client,
      Uri.parse('$apiBaseUrl/rankings/divisions?fc_id=$fcId'),
    );
    if (data is List) {
      return data.map((e) => RankingDivisionModel.fromJson(e)).toList();
    }
    throw const FormatException('Resposta não é uma lista JSON');
  }

  /// Ranking de uma divisão de um fight center.
  Future<List<RankingModel>> getByDivision(int fcId, String division) async {
    final uri = Uri.parse('$apiBaseUrl/rankings').replace(queryParameters: {
      'fc_id': '$fcId',
      'division': division,
    });
    final data = await getJsonResilient(client, uri);
    return _asRankingList(data);
  }

  List<RankingModel> _asRankingList(dynamic data) {
    if (data is List) {
      return data.map((e) => RankingModel.fromJson(e)).toList();
    }
    throw const FormatException('Resposta não é uma lista JSON');
  }
}
