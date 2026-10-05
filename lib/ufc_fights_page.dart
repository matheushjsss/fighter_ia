import 'package:fighter_ia/src/models/ufc_event_detail_model.dart';
import 'package:fighter_ia/src/models/ufc_event_model.dart';
import 'package:fighter_ia/src/models/ufc_fight_model.dart';
import 'package:fighter_ia/src/repositories/ufc_repository.dart';
import 'package:fighter_ia/ufc_event_widgets.dart';
import 'package:fighter_ia/ufc_fight_detail_page.dart';
import 'package:fighter_ia/util/app_colors.dart';
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
  late Future<UfcEventDetailModel> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = UfcRepository().getEventDetail(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FutureBuilder<UfcEventDetailModel>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  _topBar(),
                  const Expanded(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                ],
              );
            }
            if (snapshot.hasError) {
              return Column(
                children: [
                  _topBar(),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Erro: ${snapshot.error}',
                            style: const TextStyle(color: AppColors.textDim)),
                      ),
                    ),
                  ),
                ],
              );
            }
            final detail = snapshot.data!;
            final fights = detail.fights;
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _topBar(),
                _eventHeader(detail.event, fights),
                if (fights.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('Card ainda não divulgado',
                          style: TextStyle(color: AppColors.textDim)),
                    ),
                  )
                else ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      'CARD PRINCIPAL',
                      style: TextStyle(
                        color: AppColors.textDim,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  ...fights.map((f) => _FightCard(fight: f)),
                ],
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _eventHeader(UfcEventHeaderModel ev, List<UfcFightModel> fights) {
    final main = fights.isNotEmpty ? fights.first : null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF23232A), Color(0xFF121214)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FcMiniBadge(text: ev.badge),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ev.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      main != null && main.weightClass.isNotEmpty
                          ? 'MMA · ${main.weightClass}'
                          : 'MMA',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (main != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _cornerName(
                    main.redCorner,
                    main.redRecord,
                    main.redCountrySigla,
                    CrossAxisAlignment.start,
                    TextAlign.start,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: _cornerName(
                    main.blueCorner,
                    main.blueRecord,
                    main.blueCountrySigla,
                    CrossAxisAlignment.end,
                    TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _infoBox('DATA', _formatDate(ev.date)),
              const SizedBox(width: 8),
              _infoBox('LOCAL', ev.country.isNotEmpty ? ev.country : '—'),
              const SizedBox(width: 8),
              _infoBox('LUTAS', '${ev.fightsCount} cards'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cornerName(String name, String record, String sigla,
      CrossAxisAlignment align, TextAlign textAlign) {
    final rec = [
      if (record.isNotEmpty) record,
      if (sigla.isNotEmpty) sigla.toUpperCase(),
    ].join(' · ');
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          name.toUpperCase(),
          textAlign: textAlign,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            height: 1.05,
          ),
        ),
        if (rec.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              rec,
              style: const TextStyle(color: AppColors.textDim, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _infoBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textDim,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
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
                      img: fight.redImgFace.isNotEmpty
                          ? fight.redImgFace
                          : fight.redImg,
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
                      img: fight.blueImgFace.isNotEmpty
                          ? fight.blueImgFace
                          : fight.blueImg,
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

  static const double _avatar = 88;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Foto de ROSTO, recortada em círculo com anel na cor do canto.
          Container(
            width: _avatar,
            height: _avatar,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.08),
              border: Border.all(color: accent.withValues(alpha: 0.6), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImage(),
          ),
          const SizedBox(height: 8),
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
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Icon(Icons.person, size: 44, color: accent.withValues(alpha: 0.5));
  }
}
