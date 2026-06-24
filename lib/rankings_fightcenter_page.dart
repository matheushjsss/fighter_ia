import 'package:fighter_ia/rankings_tab.dart';
import 'package:fighter_ia/src/models/ranking_model.dart';
import 'package:fighter_ia/src/repositories/rankings_repository.dart';
import 'package:fighter_ia/util/app_colors.dart';
import 'package:fighter_ia/util/fighter_nav.dart';
import 'package:flutter/material.dart';

/// Ranking completo de um fight center, com chips de divisão e lista vertical.
class RankingsFightCenterPage extends StatefulWidget {
  final int fcId;
  final String fcName;

  const RankingsFightCenterPage({
    super.key,
    required this.fcId,
    required this.fcName,
  });

  @override
  State<RankingsFightCenterPage> createState() =>
      _RankingsFightCenterPageState();
}

class _RankingsFightCenterPageState extends State<RankingsFightCenterPage> {
  final _repo = RankingsRepository();

  late Future<List<RankingDivisionModel>> _divisions;
  Future<List<RankingModel>>? _ranking;
  RankingDivisionModel? _selected;

  @override
  void initState() {
    super.initState();
    _divisions = _repo.getDivisions(widget.fcId).then((divs) {
      // Seleciona a primeira divisão (P4P) automaticamente.
      if (divs.isNotEmpty) {
        _select(divs.first);
      }
      return divs;
    });
  }

  void _select(RankingDivisionModel div) {
    setState(() {
      _selected = div;
      _ranking = _repo.getByDivision(widget.fcId, div.division);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            _divisionChips(),
            const SizedBox(height: 8),
            Expanded(child: _list()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          FcBadge(text: widget.fcName.length <= 4 ? widget.fcName : widget.fcName[0]),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.fcName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const Text(
                'MMA · RANKINGS',
                style: TextStyle(color: AppColors.textDim, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divisionChips() {
    return SizedBox(
      height: 40,
      child: FutureBuilder<List<RankingDivisionModel>>(
        future: _divisions,
        builder: (context, snap) {
          final divs = snap.data ?? [];
          if (divs.isEmpty) return const SizedBox();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: divs.length,
            itemBuilder: (context, i) {
              final d = divs[i];
              final selected = d.division == _selected?.division;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _select(d),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : AppColors.chip,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.accent : AppColors.stroke,
                      ),
                    ),
                    child: Text(
                      d.shortLabel,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textDim,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _list() {
    if (_ranking == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    return FutureBuilder<List<RankingModel>>(
      future: _ranking,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Erro: ${snap.error}',
                  style: const TextStyle(color: AppColors.textDim)),
            ),
          );
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return const Center(
            child: Text('Sem ranking nesta divisão',
                style: TextStyle(color: AppColors.textDim)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: list.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  'RANKING ${_selected?.shortLabel ?? ''}',
                  style: const TextStyle(
                    color: AppColors.textDim,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }
            return _RankingRow(ranking: list[i - 1]);
          },
        );
      },
    );
  }
}

/// Linha vertical do ranking: posição, foto, nome, divisão·cartel, variação.
class _RankingRow extends StatelessWidget {
  final RankingModel ranking;
  const _RankingRow({required this.ranking});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            openFighterPage(context, ranking.fighterId, ranking.fighterName),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  ranking.positionLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ranking.isChampion ? AppColors.accent : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.chip,
                backgroundImage: ranking.imgFace.isNotEmpty
                    ? NetworkImage(ranking.imgFace)
                    : null,
                child: ranking.imgFace.isEmpty
                    ? const Icon(Icons.person, color: AppColors.textDim)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ranking.fighterName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDim,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _changeIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    if (ranking.weightDivision.isNotEmpty) parts.add(ranking.weightDivision);
    if (ranking.record.isNotEmpty) parts.add(ranking.record);
    return parts.join(' · ');
  }

  Widget _changeIndicator() {
    if (ranking.isInterim) {
      return const Text(
        'INT.',
        style: TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      );
    }
    final delta = ranking.changeDelta;
    if (delta == null || delta == 0) {
      return const Text('—',
          style: TextStyle(color: AppColors.textDim, fontSize: 16));
    }
    final up = delta > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: up ? Colors.green : Colors.red,
          size: 22,
        ),
        Text(
          '${delta.abs()}',
          style: TextStyle(
            color: up ? Colors.green : Colors.red,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
