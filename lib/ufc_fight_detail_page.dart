import 'package:fighter_ia/news_list.dart';
import 'package:fighter_ia/src/models/ufc_fight_model.dart';
import 'package:fighter_ia/src/models/ufc_fight_result_model.dart';
import 'package:fighter_ia/src/repositories/ufc_repository.dart';
import 'package:fighter_ia/util/fighter_nav.dart';
import 'package:flutter/material.dart';

class UfcFightDetailPage extends StatefulWidget {
  final UfcFightModel fight;

  const UfcFightDetailPage({super.key, required this.fight});

  @override
  State<UfcFightDetailPage> createState() => _UfcFightDetailPageState();
}

class _UfcFightDetailPageState extends State<UfcFightDetailPage> {
  late Future<UfcFightResultModel> _resultFuture;

  @override
  void initState() {
    super.initState();
    _resultFuture = UfcRepository().getFightDetail(widget.fight.id);
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.fight;
    return Scaffold(
      appBar: AppBar(title: Text('${f.redCorner} vs ${f.blueCorner}')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<UfcFightResultModel>(
              future: _resultFuture,
              builder: (context, snapshot) {
                final result = snapshot.data;
                return Column(
                  children: [
                    _buildMatchup(context, result),
                    _buildResultSection(context, snapshot),
                  ],
                );
              },
            ),
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                'Notícias',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // Mesmo widget de notícias usado na tela do lutador.
            NewsList(search: '${f.redCorner} ${f.blueCorner}'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchup(BuildContext context, UfcFightResultModel? result) {
    final f = widget.fight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          if (f.titleFight)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'DISPUTA DE CINTURÃO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          if (f.weightHeader.isNotEmpty)
            Text(
              f.weightHeader,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Colors.grey.shade500,
              ),
            ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => openFighterPage(context, f.redId, f.redCorner),
                    child: _fighterColumn(
                      name: f.redCorner,
                      img: f.redImg,
                      record: f.redRecord,
                      accent: Colors.red,
                      isWinner: result?.winnerCorner == 'red',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => openFighterPage(context, f.blueId, f.blueCorner),
                    child: _fighterColumn(
                      name: f.blueCorner,
                      img: f.blueImg,
                      record: f.blueRecord,
                      accent: Colors.blue,
                      isWinner: result?.winnerCorner == 'blue',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fighterColumn({
    required String name,
    required String img,
    required String record,
    required Color accent,
    required bool isWinner,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isWinner)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'VENCEDOR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        SizedBox(
          // Imagem de CORPO inteiro, grande, ocupando boa parte da tela.
          height: 300,
          child: img.isEmpty
              ? _placeholder(accent)
              : Image.network(
                  img,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _placeholder(accent),
                ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (record.isNotEmpty)
          Text(
            record,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
      ],
    );
  }

  Widget _placeholder(Color accent) {
    return Center(
      child: Container(
        width: 110,
        height: 140,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Icon(Icons.person, size: 60, color: accent.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildResultSection(
    BuildContext context,
    AsyncSnapshot<UfcFightResultModel> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    Widget card(List<Widget> children, {Color? border}) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border ?? Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Column(children: children),
      );
    }

    if (snapshot.hasError) {
      return card([
        const Icon(Icons.error_outline, color: Colors.orange),
        const SizedBox(height: 8),
        Text(
          'Não foi possível carregar o resultado.\n${snapshot.error}',
          textAlign: TextAlign.center,
        ),
      ]);
    }

    final r = snapshot.data!;

    // Resultado ainda não disponível (tabela fight_results vazia / luta futura).
    if (!r.hasResult) {
      return card([
        Icon(Icons.schedule, color: Colors.grey.shade500),
        const SizedBox(height: 8),
        const Text(
          'Resultado ainda não disponível',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Esta luta ainda não tem resultado registrado.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ]);
    }

    // Empate
    if (r.draw) {
      return card([
        const Text('EMPATE',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        _methodLine(r),
      ], border: Colors.grey);
    }

    // Sem resultado (No Contest)
    if (r.noContest) {
      return card([
        const Text('SEM RESULTADO (No Contest)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        _methodLine(r),
      ], border: Colors.grey);
    }

    // Vitória
    return card([
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Vencedor: ${r.winnerName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      _methodLine(r),
    ], border: Colors.green);
  }

  Widget _methodLine(UfcFightResultModel r) {
    final parts = <String>[];
    if (r.method.isNotEmpty) {
      parts.add(r.methodDetail.isNotEmpty
          ? '${r.method} (${r.methodDetail})'
          : r.method);
    }
    if (r.roundEnd != null) parts.add('Round ${r.roundEnd}');
    if (r.timeEnd.isNotEmpty) parts.add(r.timeEnd);

    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.join(' • '),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14),
    );
  }
}
