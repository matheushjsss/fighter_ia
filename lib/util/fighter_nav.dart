import 'package:fighter_ia/fighter_datails.dart';
import 'package:flutter/material.dart';

/// Abre a tela de detalhe do lutador (a mesma usada na lista de lutadores).
/// Navega pelo id do banco. Ignora lutadores ainda não definidos (id nulo / TBA).
void openFighterPage(BuildContext context, int? fighterId, String name) {
  if (fighterId == null) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FighterDetailPage(fighterId: fighterId, fighterName: name),
    ),
  );
}
