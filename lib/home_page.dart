import 'package:fighter_ia/src/models/news_model.dart';
import 'package:fighter_ia/src/models/ranking_model.dart';
import 'package:fighter_ia/src/models/ufc_featured_model.dart';
import 'package:fighter_ia/src/repositories/news_repository.dart';
import 'package:fighter_ia/src/repositories/rankings_repository.dart';
import 'package:fighter_ia/src/repositories/ufc_repository.dart';
import 'package:fighter_ia/rankings_tab.dart';
import 'package:fighter_ia/ufc_events_page.dart';
import 'package:fighter_ia/ufc_fights_page.dart';
import 'package:fighter_ia/util/app_colors.dart';
import 'package:fighter_ia/util/env.dart';
import 'package:fighter_ia/util/fighter_nav.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  void _goTo(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _HomeFeed(),
      const RankingsTab(),
      const UfcEventsPage(),
      const _PerfilTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _tab, children: tabs),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.card,
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.accent : AppColors.textDim,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.accent : AppColors.textDim,
            );
          }),
        ),
        child: NavigationBar(
          height: 64,
          selectedIndex: _tab,
          onDestinationSelected: _goTo,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_filled), label: 'HOME'),
            NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined), label: 'RANKINGS'),
            NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined), label: 'EVENTOS'),
            NavigationDestination(
                icon: Icon(Icons.person_outline), label: 'PERFIL'),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// HOME FEED
// ===========================================================================
class _HomeFeed extends StatefulWidget {
  const _HomeFeed();

  @override
  State<_HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<_HomeFeed> {
  final _ufc = UfcRepository();
  final _rankingsRepo = RankingsRepository();
  final _newsRepo = NewsRepository(apiKey: keyApiNews);

  late Future<UfcFeaturedModel?> _featured;
  late Future<List<RankingModel>> _ranking;
  late Future<List<NewsModel>> _news;

  // Chips de categoria -> termo de busca das notícias.
  static const _categories = {
    'PARA VOCÊ': 'UFC',
    'MMA': 'MMA',
    'JIU-JITSU': 'Jiu-Jitsu',
    'BOXE': 'Boxe',
    'MUAY THAI': 'Muay Thai',
  };
  String _selectedCat = 'PARA VOCÊ';

  @override
  void initState() {
    super.initState();
    _featured = _ufc.getFeatured();
    _ranking = _rankingsRepo.getPoundForPound();
    _loadNews();
  }

  void _loadNews() {
    _news = _newsRepo.getSearchNews(_categories[_selectedCat] ?? 'UFC');
  }

  void _selectCat(String cat) {
    setState(() {
      _selectedCat = cat;
      _loadNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      onRefresh: () async {
        setState(() {
          _featured = _ufc.getFeatured();
          _ranking = _rankingsRepo.getPoundForPound();
          _loadNews();
        });
        await Future.wait([_featured, _ranking, _news]);
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _TopBar(),
          _categoryChips(),
          const SizedBox(height: 8),
          _featuredCard(),
          const SizedBox(height: 20),
          _rankingSection(),
          const SizedBox(height: 20),
          _newsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- Chips de categoria ---
  Widget _categoryChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _categories.keys.map((cat) {
          final selected = cat == _selectedCat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _selectCat(cat),
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
                  cat,
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

  // --- Card principal ---
  Widget _featuredCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<UfcFeaturedModel?>(
        future: _featured,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _cardSkeleton(190);
          }
          final f = snap.data;
          if (f == null) return const SizedBox.shrink();

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UfcFightsPage(
                  eventId: f.eventId,
                  eventName: f.eventName,
                ),
              ),
            ),
            child: Container(
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.stroke),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF23232A), Color(0xFF121214)],
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  if (f.redImg.isNotEmpty)
                    Positioned(
                      left: -10,
                      bottom: 0,
                      top: 30,
                      child: Opacity(
                        opacity: 0.30,
                        child: Image.network(f.redImg, fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox()),
                      ),
                    ),
                  if (f.blueImg.isNotEmpty)
                    Positioned(
                      right: -10,
                      bottom: 0,
                      top: 30,
                      child: Opacity(
                        opacity: 0.30,
                        child: Image.network(f.blueImg, fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox()),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _badge(
                              f.titleFight ? 'CINTURÃO' : 'CARD PRINCIPAL',
                              AppColors.accent,
                            ),
                            const Spacer(),
                            _badge(_formatDate(f.eventDate), AppColors.chip,
                                icon: Icons.calendar_today, dim: true),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'MMA · CARD PRINCIPAL',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${f.redCorner.toUpperCase()}  ✕  ${f.blueCorner.toUpperCase()}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          f.eventName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textDim,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Ranking rápido (Pound-for-Pound do UFC) ---
  Widget _rankingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('RANKING RÁPIDO',
            onSeeAll: () => _findHome(context)?._goTo(1)),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 2, 16, 0),
          child: Text(
            'Pound-for-Pound · UFC',
            style: TextStyle(color: AppColors.textDim, fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: FutureBuilder<List<RankingModel>>(
            future: _ranking,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }
              if (!snap.hasData || snap.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              final list = snap.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (context, i) => _rankingCard(list[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _rankingCard(RankingModel r) {
    return GestureDetector(
      onTap: () => openFighterPage(context, r.fighterId, r.fighterName),
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
                    // Foto de ROSTO do lutador (img_face).
                    child: r.imgFace.isNotEmpty
                        ? Image.network(
                            r.imgFace,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => _imgFallback(),
                          )
                        : _imgFallback(),
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
                        r.positionLabel,
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
                    r.fighterName,
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
                    r.record.isNotEmpty ? 'Cartel ${r.record}' : 'P4P',
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

  // --- Últimas notícias ---
  Widget _newsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('ÚLTIMAS NOTÍCIAS'),
        const SizedBox(height: 8),
        FutureBuilder<List<NewsModel>>(
          future: _news,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              );
            }
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Não foi possível carregar as notícias.',
                  style: TextStyle(color: AppColors.textDim),
                ),
              );
            }
            final list = snap.data ?? [];
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Nenhuma notícia encontrada',
                    style: TextStyle(color: AppColors.textDim)),
              );
            }
            return Column(
              children: list
                  .take(8)
                  .map((n) => _newsRow(n))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _newsRow(NewsModel n) {
    return InkWell(
      onTap: () => _launch(n.url),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: n.image.isNotEmpty
                  ? Image.network(
                      n.image,
                      width: 90,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _newsImgFallback(),
                    )
                  : _newsImgFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _selectedCat == 'PARA VOCÊ' ? 'MMA' : _selectedCat,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      if (n.timeAgo.isNotEmpty) ...[
                        const Text(' · ',
                            style: TextStyle(color: AppColors.textDim)),
                        Text(
                          n.timeAgo,
                          style: const TextStyle(
                            color: AppColors.textDim,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.25,
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

  // --- Helpers visuais ---
  Widget _sectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'Ver tudo ›',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color,
      {IconData? icon, bool dim = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: dim ? Border.all(color: AppColors.stroke) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: dim ? AppColors.textDim : Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: dim ? AppColors.textDim : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
        color: AppColors.chip,
        child: const Icon(Icons.person, color: AppColors.textDim, size: 40),
      );

  Widget _newsImgFallback() => Container(
        width: 90,
        height: 70,
        color: AppColors.chip,
        child: const Icon(Icons.image, color: AppColors.textDim),
      );

  Widget _cardSkeleton(double h) => Container(
        height: h,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  _HomePageState? _findHome(BuildContext context) =>
      context.findAncestorStateOfType<_HomePageState>();
}

// ===========================================================================
// TOP BAR
// ===========================================================================
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Row(
            children: const [
              Text(
                'CLIN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'CH',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 2),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: CircleAvatar(radius: 3, backgroundColor: AppColors.accent),
              ),
            ],
          ),
          const Spacer(),
          _circleIcon(Icons.search),
          const SizedBox(width: 10),
          _circleIcon(Icons.notifications_none, dot: true),
        ],
      ),
    );
  }

  static Widget _circleIcon(IconData icon, {bool dot = false}) {
    return Stack(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        if (dot)
          const Positioned(
            right: 10,
            top: 10,
            child: CircleAvatar(radius: 3.5, backgroundColor: AppColors.accent),
          ),
      ],
    );
  }
}

// ===========================================================================
// PERFIL TAB
// ===========================================================================
class _PerfilTab extends StatelessWidget {
  const _PerfilTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.card,
            child: Icon(Icons.person, size: 48, color: AppColors.textDim),
          ),
          SizedBox(height: 16),
          Text(
            'Perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Em breve',
            style: TextStyle(color: AppColors.textDim),
          ),
        ],
      ),
    );
  }
}
