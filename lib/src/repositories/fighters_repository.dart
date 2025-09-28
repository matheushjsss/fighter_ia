import 'dart:convert';

import 'package:fighter_ia/src/models/fighters_model.dart';
import 'package:http/http.dart';

class FightersRepository {
  final client = Client();
  String urlList = 'https://api.octagon-api.com/fighters';
  String urlDatail = 'https://api.octagon-api.com/fighter/';

  Future<List<FightersModel>> getFighters() async {
    final response = await client.get(Uri.parse(urlList));

    if (response.statusCode == 200) {
      return parseFighters(response.body);
    } else {
      throw Exception("Erro ao carregar fighters: ${response.statusCode}");
    }
  }

  List<FightersModel> parseFighters(String jsonFighters) {
    final Map<String, dynamic> decoded = json.decode(jsonFighters);

    return decoded.values.map<FightersModel>((fighter) {
      return FightersModel(
        fighter['name'] ?? '',
        fighter['category'] ?? '',
        fighter['imgUrl'] ?? '',
      );
    }).toList();
  }

  Future<Map<String, dynamic>> getFighterDetails(String fighterName) async {
    final response = await client.get(Uri.parse('$urlDatail$fighterName'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar detalhes do lutador');
    }
  }
}
