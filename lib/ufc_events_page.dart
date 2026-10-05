import 'package:fighter_ia/src/models/ufc_event_model.dart';
import 'package:fighter_ia/src/repositories/ufc_repository.dart';
import 'package:fighter_ia/ufc_event_widgets.dart';
import 'package:fighter_ia/ufc_fights_page.dart';
import 'package:fighter_ia/util/app_colors.dart';
import 'package:flutter/material.dart';

class UfcEventsPage extends StatefulWidget {
  const UfcEventsPage({super.key});

  @override
  State<UfcEventsPage> createState() => _UfcEventsPageState();
}

class _UfcEventsPageState extends State<UfcEventsPage> {
  late Future<List<UfcEventModel>> _eventsFuture;

  static const _sports = ['PARA VOCÊ', 'MMA', 'JIU-JITSU', 'BOXE', 'MUAY THAI'];
  String _sport = 'PARA VOCÊ';

  @override
  void initState() {
    super.initState();
    _eventsFuture = UfcRepository().getEvents();
  }

  void _openEvent(UfcEventModel e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UfcFightsPage(eventId: e.id, eventName: e.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.card,
          onRefresh: () async {
            setState(() => _eventsFuture = UfcRepository().getEvents());
            await _eventsFuture;
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const _EventsHeader(),
              _sportChips(),
              _favoritesBar(),
              FutureBuilder<List<UfcEventModel>>(
                future: _eventsFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child:
                            CircularProgressIndicator(color: AppColors.accent),
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
                  final events = snap.data ?? [];
                  if (events.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nenhum evento encontrado',
                          style: TextStyle(color: AppColors.textDim)),
                    );
                  }
                  final featured = events.first;
                  final rest = events.skip(1).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('EM DESTAQUE'),
                      _featuredCard(featured),
                      const SizedBox(height: 8),
                      _sectionLabel('PRÓXIMOS EVENTOS'),
                      ...rest.map(_eventRow),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textDim,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      );

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

  Widget _favoritesBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: AppColors.accent, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(color: AppColors.textDim, fontSize: 13),
                children: [
                  TextSpan(text: 'Seus favoritos: '),
                  TextSpan(
                    text: 'MMA · Jiu-Jitsu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Text(
            'EDITAR',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredCard(UfcEventModel e) {
    return GestureDetector(
      onTap: () => _openEvent(e),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF26201C), Color(0xFF121214)],
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _DateBadge(date: e.date),
                const Spacer(),
                Text('${e.fightsCount} LUTAS',
                    style: const TextStyle(
                        color: AppColors.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                FcMiniBadge(text: e.badge),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              e.hasMain
                  ? '${e.mainRed.toUpperCase()}  ✕  ${e.mainBlue.toUpperCase()}'
                  : e.name.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (e.mainWeight.isNotEmpty) e.mainWeight,
                if (e.country.isNotEmpty) e.country,
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textDim, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventRow(UfcEventModel e) {
    return GestureDetector(
      onTap: () => _openEvent(e),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FcMiniBadge(text: e.badge),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        e.fcCode.isNotEmpty ? 'MMA · ${e.fcCode}' : 'MMA',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _DateBadge(date: e.date, plain: true),
              ],
            ),
            if (e.hasMain) ...[
              const SizedBox(height: 10),
              Text(
                '${e.mainRed.toUpperCase()}  ✕  ${e.mainBlue.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                [
                  if (e.mainWeight.isNotEmpty) e.mainWeight,
                  if (e.country.isNotEmpty) e.country,
                ].join(' · '),
                style: const TextStyle(color: AppColors.textDim, fontSize: 12),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text('${e.fightsCount} lutas',
                    style: const TextStyle(
                        color: AppColors.textDim, fontSize: 12)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text('LEMBRAR',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Widgets auxiliares
// ===========================================================================
class _EventsHeader extends StatelessWidget {
  const _EventsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const Text(
            'EVENTOS',
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

/// Data formatada em PT (ex.: "SÁB · 11/07").
class _DateBadge extends StatelessWidget {
  final String date;
  final bool plain;
  const _DateBadge({required this.date, this.plain = false});

  static const _weekdays = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];

  String get _label {
    final dt = DateTime.tryParse(date);
    if (dt == null) return date;
    final wd = _weekdays[(dt.weekday - 1) % 7];
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$wd · $d/$m';
  }

  @override
  Widget build(BuildContext context) {
    final text = Text(
      _label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
    );
    if (plain) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.stroke),
        ),
        child: text,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: text,
    );
  }
}
