import 'package:fighter_ia/src/repositories/fighters_repository.dart';
import 'package:flutter/material.dart';

class FighterDetailPage extends StatelessWidget {
  static const double _imageHeight = 400;
  static const double _titleFontSize = 50;
  static const double _subtitleFontSize = 25;
  static const double _sectionSpacing = 30;

  final String fighterName;

  const FighterDetailPage({super.key, required this.fighterName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fighterName)),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: FightersRepository().getFighterDetails(fighterName),
      builder: (context, snapshot) {
        return switch (snapshot.connectionState) {
          ConnectionState.waiting => _buildLoadingState(),
          ConnectionState.done => _buildContentState(snapshot),
          _ => const SizedBox(),
        };
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContentState(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.hasError) {
      return _buildErrorState(snapshot.error);
    }

    if (snapshot.hasData) {
      return _buildFighterDetails(snapshot.data!);
    }

    return const SizedBox();
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Text(
        "Erro: ${error?.toString() ?? 'Erro desconhecido'}",
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFighterDetails(Map<String, dynamic> fighterData) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(fighterData),
          const SizedBox(height: _sectionSpacing),
          _buildInfoSection(fighterData),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> fighterData) {
    return Center(
      child: Column(
        children: [
          _buildFighterImage(fighterData['imgUrl']),
          _buildFighterName(fighterData['name']),
          _buildFighterNickname(fighterData['nickname']),
        ],
      ),
    );
  }

  Widget _buildFighterImage(String imageUrl) {
    return Image.network(imageUrl, height: _imageHeight, fit: BoxFit.cover);
  }

  Widget _buildFighterName(String name) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: _titleFontSize,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFighterNickname(String nickname) {
    return Text(
      '"$nickname"',
      style: const TextStyle(
        fontSize: _subtitleFontSize,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> fighterData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem('Categoria', fighterData['category']),
        Text('Cartel:'),
        _buildRecordInfo(fighterData),
        Text('Fisico:'),
        _buildInfoItem('Idade', fighterData['age']),
        _buildPhysicalInfo(fighterData),
        Text('Pessoal:'),
        _buildInfoItem('Estilo', fighterData['fightingStyle']),
        _buildInfoItem('Local de Nascimento', fighterData['placeOfBirth']),
        _buildInfoItem('Estreia no UFC', fighterData['octagonDebut']),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Text(
      '$label: $value',
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRecordInfo(Map<String, dynamic> fighterData) {
    return Text(
      'Vitórias: ${fighterData['wins']} • '
      'Derrotas: ${fighterData['losses']} • '
      'Empates: ${fighterData['draws']}',
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPhysicalInfo(Map<String, dynamic> fighterData) {
    return Text(
      'Altura: ${fighterData['height']} in • '
      'Peso: ${fighterData['weight']} lbs',
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    );
  }
}
