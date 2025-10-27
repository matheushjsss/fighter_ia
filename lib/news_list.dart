import 'package:fighter_ia/src/models/news_model.dart';
import 'package:fighter_ia/src/repositories/news_repository.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fighter_ia/util/env.dart';
import 'dart:math' as math;

class NewsList extends StatefulWidget {
  final String? search;
  final int? refresh; // contador para forçar refresh

  const NewsList({super.key, this.search, this.refresh});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  final repo = NewsRepository(apiKey: keyApiNews);

  late Future<List<NewsModel>> _newsFuture;

  static const int _baseDelayMillis = 1500; // base delay para backoff
  static const int _safetyMaxAttempts = 100; // trava de segurança para evitar loop infinito

  Future<List<NewsModel>> _fetchNewsWithRetry(String query) async {
    int attempt = 0;
    final random = math.Random();

    while (true) {
      try {
        return await repo.getSearchNews(query);
      } catch (e) {
        final errStr = e.toString();
        final isRateLimit = errStr.contains('429') || errStr.toLowerCase().contains('rate limit') || errStr.toLowerCase().contains('too many requests');

        if (!isRateLimit) {
          // Não é erro de rate limit — repassa o erro
          rethrow;
        }

        // Se o widget foi desmontado, aborta
        if (!mounted) {
          throw Exception('Widget disposed while retrying news fetch');
        }

        attempt++;
        if (attempt > _safetyMaxAttempts) {
          throw Exception('Máximo de tentativas alcançado ($_safetyMaxAttempts) ao aguardar rate limit');
        }

        // Exponential backoff com jitter (capado em 64x)
        final exponent = math.min(attempt - 1, 6); // limita o expoente para evitar delays enormes
        final multiplier = math.pow(2, exponent).toInt();
        final jitter = random.nextInt(500); // até 500ms de jitter
        final delayMillis = (_baseDelayMillis * multiplier) + jitter;

        // Opcional: você pode usar print() ou outro logger aqui para acompanhar tentativas
        // print('Rate limited (429) — tentativa $attempt — aguardando ${delayMillis}ms antes de tentar novamente');

        await Future.delayed(Duration(milliseconds: delayMillis));
        // loop continua e tentará novamente
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _newsFuture = _fetchNewsWithRetry(widget.search ?? '');
  }

  @override
  void didUpdateWidget(covariant NewsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refresh != oldWidget.refresh || widget.search != oldWidget.search) {
      setState(() {
        _newsFuture = _fetchNewsWithRetry(widget.search ?? '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: FutureBuilder<List<NewsModel>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma notícia encontrada'));
          }

          final newsList = snapshot.data!;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return _buildNewsCard(news);
            },
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(NewsModel news) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: GestureDetector(
        onTap: () => {_launchInBrowser(Uri.parse(news.url))},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.image.isNotEmpty) // ajusta conforme seu model
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  news.image,
                  width: 180,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 180,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                news.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
