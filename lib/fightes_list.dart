import 'package:fighter_ia/fighter_datails.dart';
import 'package:fighter_ia/src/repositories/fighters_repository.dart';
import 'package:flutter/material.dart';

class FightesList extends StatefulWidget {
  const FightesList({super.key});

  @override
  State<FightesList> createState() => _FightesListState();
}

class _FightesListState extends State<FightesList> {
  final repo = FightersRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: repo.getFighters(),
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

        final fighters = snapshot.data!;

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 100,
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
              itemCount: fighters.length,
              itemBuilder: (context, index) {
                final f = fighters[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FighterDetailPage(
                          fighterName: f.name.toLowerCase().replaceAll(
                            " ",
                            "-",
                          ),
                        ),
                      ),
                    );
                  },
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
                              Text(
                                f.category,
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
