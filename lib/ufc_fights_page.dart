import 'package:fighter_ia/src/models/ufc_fight_model.dart';
import 'package:fighter_ia/src/repositories/ufc_repository.dart';
import 'package:fighter_ia/ufc_fight_detail_page.dart';
import 'package:fighter_ia/util/fighter_nav.dart';
import 'package:flutter/material.dart';

class UfcFightsPage extends StatefulWidget {
  final int eventId;
  final String eventName;

  const UfcFightsPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<UfcFightsPage> createState() => _UfcFightsPageState();
}

class _UfcFightsPageState extends State<UfcFightsPage> {
  late Future<List<UfcFightModel>> _fightsFuture;

  @override
  void initState() {
    super.initState();
    _fightsFuture = UfcRepository().getFights(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventName)),
      body: FutureBuilder<List<UfcFightModel>>(
        future: _fightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final fights = snapshot.data ?? [];
          if (fights.isEmpty) {
            return const Center(child: Text('Nenhuma luta encontrada'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: fights.length,
            itemBuilder: (context, index) => _FightCard(fight: fights[index]),
          );
        },
      ),
    );
  }
}

class _FightCard extends StatelessWidget {
  final UfcFightModel fight;

  const _FightCard({required this.fight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UfcFightDetailPage(fight: fight),
              ),
            );
          },
          child: Column(
            children: [
              // Cabeçalho: categoria de peso + selo de cinturão
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Column(
              children: [
                if (fight.titleFight)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'DISPUTA DE CINTURÃO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                if (fight.weightHeader.isNotEmpty)
                  Text(
                    fight.weightHeader,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          // Linha principal: foto + nome | VS | nome + foto
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        openFighterPage(context, fight.redId, fight.redCorner),
                    child: _FighterSide(
                      name: fight.redCorner,
                      img: fight.redImg,
                      accent: Colors.red,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        openFighterPage(context, fight.blueId, fight.blueCorner),
                    child: _FighterSide(
                      name: fight.blueCorner,
                      img: fight.blueImg,
                      accent: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Barra inferior: cartel (record) de cada lutador
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF5F5F5),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    fight.redRecord.isEmpty ? '—' : fight.redRecord,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'CARTEL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: Colors.grey.shade500,
                  ),
                ),
                Expanded(
                  child: Text(
                    fight.blueRecord.isEmpty ? '—' : fight.blueRecord,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FighterSide extends StatelessWidget {
  final String name;
  final String img;
  final Color accent;

  const _FighterSide({
    required this.name,
    required this.img,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 130,
            child: _buildImage(),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (img.isEmpty) return _placeholder();
    return Image.network(
      img,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Container(
        width: 90,
        height: 110,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Icon(Icons.person, size: 48, color: accent.withValues(alpha: 0.5)),
      ),
    );
  }
}
