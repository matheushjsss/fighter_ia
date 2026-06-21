import 'package:fighter_ia/drawer/user_drawer.dart';
import 'package:fighter_ia/ufc_events_page.dart';
import 'package:flutter/material.dart';

class DrawerDefault extends StatefulWidget {
  const DrawerDefault({super.key});

  @override
  State<DrawerDefault> createState() => _DrawerDefaultState();
}

class _DrawerDefaultState extends State<DrawerDefault> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserDrawer(),
        ListTile(
          leading: const Icon(Icons.sports_mma, color: Colors.red),
          title: const Text('UFC'),
          subtitle: const Text('Eventos e Lutas'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UfcEventsPage()),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Sair'),
          subtitle: const Text('Sair da conta Logada'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
      ],
    );
  }
}
