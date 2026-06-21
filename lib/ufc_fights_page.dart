import 'package:fighter_ia/src/models/ufc_fight_model.dart';
import 'package:fighter_ia/src/repositories/ufc_repository.dart';
import 'package:flutter/material.dart';

class UfcFightsPage extends StatelessWidget {
  final int eventId;
  final String eventName;

  const UfcFightsPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventName)),
      body: FutureBuilder<List<UfcFightModel>>(
        future: UfcRepository().getFights(eventId),
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
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: fights.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final fight = fights[index];
              return _FightCard(fight: fight);
            },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          if (fight.titleFight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(bottom: 6),
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
                ),
              ),
            ),
          if (fight.weightClass.isNotEmpty)
            Text(
              fight.weightClass,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  fight.redCorner,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.red,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'VS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Expanded(
                child: Text(
                  fight.blueCorner,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
