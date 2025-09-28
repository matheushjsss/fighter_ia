import 'dart:convert';
import 'package:fighter_ia/src/models/news_model.dart';
import 'package:http/http.dart' as http;

class NewsRepository {
  final String apiKey;
  final http.Client httpClient;
  static const _baseUrl = 'gnews.io';
  static const _pathEverything = '/api/v4/search';

  NewsRepository({required this.apiKey, http.Client? client})
    : httpClient = client ?? http.Client();

  Future<List<NewsModel>> getSearchNews(String Search) async {
    final cleaned = Search.replaceAll(RegExp(r'[-_]'), ' ').trim();
    final query = '$cleaned';

    final uri = Uri.https(_baseUrl, _pathEverything, {
      'q': query,
      'lang': 'pt',
      'max': '10',
      'apikey': apiKey,
    });

    return _fetchArticles(uri);
  }

  Future<List<NewsModel>> _fetchArticles(Uri uri) async {
    final res = await httpClient.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Erro ao buscar : ${res.statusCode}');
    }

    final Map<String, dynamic> body = json.decode(res.body);
    final List articlesJson = body['articles'] ?? [];

    return articlesJson.map((a) {
      return NewsModel(
        a['title'] ?? '',
        a['description'] ?? '',
        a['url'] ?? '',
        a['image'] ?? '',
      );
    }).toList();
  }

  void dispose() {
    httpClient.close();
  }
}
