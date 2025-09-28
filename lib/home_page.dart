import 'package:fighter_ia/SwitcherTheme.button.dart';
import 'package:fighter_ia/app_controller.dart';
import 'package:fighter_ia/drawer/drawer_default.dart';
import 'package:fighter_ia/fightes_list.dart';
import 'package:fighter_ia/src/repositories/fighters_repository.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int counter = 0;
  String title = 'data';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: DrawerDefault()),
      appBar: AppBar(title: Text("data"), actions: [SwitcherthemeButton()]),

      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [FightesList()],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final repo = FightersRepository();
          final fighters = await repo.getFighters();

          for (var f in fighters) {
            print("${f.name} - ${f.category} - ${f.img}");
          }
        },
      ),
    );
  }
}
