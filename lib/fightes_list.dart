import 'package:fighter_ia/src/models/fighters_model.dart';
import 'package:fighter_ia/src/repositories/fighters_repository.dart';
import 'package:fighter_ia/util/fighter_nav.dart';
import 'package:flutter/material.dart';

class FightesList extends StatefulWidget {
  final String? search;

  const FightesList({super.key, this.search});

  @override
  State<FightesList> createState() => _FightesListState();
}

class _FightesListState extends State<FightesList> {
  final repo = FightersRepository();
  late Future<List<FightersModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = repo.getFighters(search: widget.search);
  }

  @override
  void didUpdateWidget(covariant FightesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A busca é feita no servidor: ao mudar o termo, refaz a requisição.
    if (widget.search != oldWidget.search) {
      _future = repo.getFighters(search: widget.search);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FightersModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum lutador encontrado'));
        }

        final displayList = snapshot.data!;

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 100,
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final f = displayList[index];

                return GestureDetector(
                  onTap: () => openFighterPage(context, f.id, f.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          f.img,
                          width: 120,
                          height: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 180,
                            color: Colors.grey.withValues(alpha: 0.1),
                            child: const Icon(Icons.person, size: 60, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (f.nickname.isNotEmpty)
                                Text(
                                  '"${f.nickname}"',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (f.record.isNotEmpty)
                                Text(
                                  'Cartel: ${f.record}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
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
          ),
        );
      },
    );
  }
}
