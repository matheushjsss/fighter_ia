import 'package:fighter_ia/drawer/user_drawer.dart';
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
          leading: Icon(Icons.exit_to_app),
          title: Text('Sair'),
          subtitle: Text('Sair da conta Logada'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Sair'),
          subtitle: Text('Sair da conta Logada'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
      ],
    );
  }
}
