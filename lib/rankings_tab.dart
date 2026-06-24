import 'package:fighter_ia/rankings_fightcenter_page.dart';
import 'package:fighter_ia/src/models/ranking_model.dart';
import 'package:fighter_ia/src/repositories/rankings_repository.dart';
import 'package:fighter_ia/util/app_colors.dart';
import 'package:fighter_ia/util/fighter_nav.dart';
import 'package:flutter/material.dart';

/// Tela default de Rankings: cada fight center com seu Pound-for-Pound.
class RankingsTab extends StatefulWidget {
  const RankingsTab({super.key});

  @override
  State<RankingsTab> createState() => _RankingsTabState();
}

class _RankingsTabState extends State<RankingsTab> {
  final _repo = RankingsRepository();
  late Future<List<RankingFightCenterModel>> _future;

  // Chips de esporte (visuais — só MMA tem dados hoje).
  static const _sports = ['PARA VOCÊ', 'MMA', 'JIU-JITSU', 'BOXE', 'MUAY THAI'];
  String _sport = 'PARA VOCÊ';

  @override
  void initState() {
    super.initState();
    _future = _repo.getFightCenters();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      onRefresh: () async {
        setState(() => _future = _repo.getFightCenters());
        await _future;
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _RankingsHeader(),
          _sportChips(),
          const SizedBox(height: 8),
          FutureBuilder<List<RankingFightCenterModel>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                );
              }
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erro: ${snap.error}',
                      style: const TextStyle(color: AppColors.textDim)),
                );
              }
              final fcs = snap.data ?? [];
              if (fcs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum ranking disponível',
                      style: TextStyle(color: AppColors.textDim)),
                );
              }
              return Column(
                children: fcs.map((fc) => _fightCenterSection(fc)).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sportChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _sports.map((s) {
          final selected = s == _sport;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _sport = s),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : AppColors.chip,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.accent : AppColors.stroke,
                  ),
                ),
                child: Text(
                  s,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textDim,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _fightCenterSection(RankingFightCenterModel fc) {
    void openAll() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RankingsFightCenterPage(fcId: fc.fcId, fcName: fc.fcName),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              FcBadge(text: fc.badge),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fc.fcName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    'MMA · PESO POR PESO',
                    style: TextStyle(color: AppColors.textDim, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: openAll,
                child: const Text(
                  'VER TUDO ›',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: fc.p4p.length,
            itemBuilder: (context, i) => RankingMiniCard(ranking: fc.p4p[i]),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// Widgets compartilhados
// ===========================================================================

/// Selo do fight center (UFC, B...).
class FcBadge extends StatelessWidget {
  final String text;
  const FcBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Card horizontal do P4P (rank, foto de rosto, nome, cartel).
class RankingMiniCard extends StatelessWidget {
  final RankingModel ranking;
  const RankingMiniCard({super.key, required this.ranking});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          openFighterPage(context, ranking.fighterId, ranking.fighterName),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.stroke),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ranking.imgFace.isNotEmpty
                        ? Image.network(
                            ranking.imgFace,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => _fallback(),
                          )
                        : _fallback(),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ranking.positionLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ranking.fighterName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ranking.record.isNotEmpty
                        ? 'Cartel ${ranking.record}'
                        : 'P4P',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        color: AppColors.chip,
        child: const Icon(Icons.person, color: AppColors.textDim, size: 40),
      );
}

/// Cabeçalho da aba (título RANKINGS + busca + sino).
class _RankingsHeader extends StatelessWidget {
  const _RankingsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const Text(
            'RANKINGS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          _icon(Icons.search),
          const SizedBox(width: 10),
          _icon(Icons.notifications_none),
        ],
      ),
    );
  }

  Widget _icon(IconData icon) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      );
}
