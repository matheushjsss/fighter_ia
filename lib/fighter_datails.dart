import 'package:fighter_ia/news_list.dart';
import 'package:fighter_ia/src/models/fighter_detail_model.dart';
import 'package:fighter_ia/src/repositories/fighters_repository.dart';
import 'package:flutter/material.dart';

class FighterDetailPage extends StatefulWidget {
  final int fighterId;
  final String fighterName;

  const FighterDetailPage({
    super.key,
    required this.fighterId,
    required this.fighterName,
  });

  @override
  State<FighterDetailPage> createState() => _FighterDetailPageState();
}

class _FighterDetailPageState extends State<FighterDetailPage> {
  static const double _imageHeight = 400;
  static const double _titleFontSize = 40;
  static const double _subtitleFontSize = 22;
  static const double _sectionSpacing = 24;

  late Future<FighterDetailModel> _future;

  @override
  void initState() {
    super.initState();
    _future = FightersRepository().getFighterDetails(widget.fighterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.fighterName)),
      body: FutureBuilder<FighterDetailModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) return const SizedBox();
          return _buildDetails(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildDetails(FighterDetailModel f) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(f),
          const SizedBox(height: _sectionSpacing),
          _buildInfo(f),
          const SizedBox(height: _sectionSpacing),
          NewsList(search: f.name),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildHeader(FighterDetailModel f) {
    return Center(
      child: Column(
        children: [
          if (f.img.isNotEmpty)
            Image.network(
              f.img,
              height: _imageHeight,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _imgPlaceholder(),
            )
          else
            _imgPlaceholder(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              f.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: _titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (f.nickname.isNotEmpty)
            Text(
              '"${f.nickname}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: _subtitleFontSize,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      height: _imageHeight,
      width: double.infinity,
      color: Colors.grey.withValues(alpha: 0.1),
      child: const Icon(Icons.person, size: 120, color: Colors.grey),
    );
  }

  Widget _buildInfo(FighterDetailModel f) {
    final r = f.recordParts;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Cartel'),
          _infoLine(
            'Vitórias: ${r.wins} • Derrotas: ${r.losses} • Empates: ${r.draws}',
          ),
          const SizedBox(height: 12),
          _sectionTitle('Físico'),
          if (f.age != null) _infoLine('Idade: ${f.age} anos'),
          if (f.height.isNotEmpty) _infoLine('Altura: ${f.height}'),
          if (f.weight != null) _infoLine('Peso: ${f.weight} lbs'),
          if (f.reach.isNotEmpty) _infoLine('Envergadura: ${f.reach}'),
          const SizedBox(height: 12),
          _sectionTitle('Pessoal'),
          if (f.team.isNotEmpty) _infoLine('Equipe: ${f.team}'),
          if (f.country.isNotEmpty) _infoLine('País: ${f.country}'),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
