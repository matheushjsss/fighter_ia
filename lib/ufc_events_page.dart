import 'package:fighter_ia/src/models/ufc_event_model.dart';
import 'package:fighter_ia/src/repositories/ufc_repository.dart';
import 'package:fighter_ia/ufc_fights_page.dart';
import 'package:flutter/material.dart';

class UfcEventsPage extends StatefulWidget {
  const UfcEventsPage({super.key});

  @override
  State<UfcEventsPage> createState() => _UfcEventsPageState();
}

class _UfcEventsPageState extends State<UfcEventsPage> {
  // O Future é criado UMA vez em initState. Se fosse criado no build(),
  // cada rebuild dispararia uma nova requisição.
  late Future<List<UfcEventModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = UfcRepository().getEvents();
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos UFC')),
      body: FutureBuilder<List<UfcEventModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return const Center(child: Text('Nenhum evento encontrado'));
          }
          return ListView.separated(
            itemCount: events.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: const Icon(Icons.sports_mma, color: Colors.red),
                title: Text(
                  event.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_formatDate(event.date)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UfcFightsPage(
                        eventId: event.id,
                        eventName: event.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
