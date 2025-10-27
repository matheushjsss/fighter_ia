import 'package:fighter_ia/SwitcherTheme.button.dart';
import 'package:fighter_ia/drawer/drawer_default.dart';
import 'package:fighter_ia/fightes_list.dart';
import 'package:fighter_ia/news_list.dart';
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
  int refreshCounter = 0;

  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  String _fightersSearch = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: DrawerDefault()),
      appBar: AppBar(title: Text("data"), actions: [SwitcherthemeButton()]),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("UFC News"),
            NewsList(search: "UFC", refresh: refreshCounter),
            Text("Mundo da Luta News"),
            NewsList(search: "MMA", refresh: refreshCounter),
            headerLutadores(),
            // Passa o termo de busca atual para o widget de lista de lutadores
            FightesList(search: _fightersSearch),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.rotate_right),
        onPressed: () async {
          setState(() {
            _fightersSearch = '';
            refreshCounter++;
          });
        },
      ),
    );
  }

  Widget headerLutadores() {
    // Layout: título à esquerda e ícone sempre na borda direita.
    // Ao ativar _showSearch, mostramos um TextField abaixo do Row.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Lutadores em Destaque",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(_showSearch ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  }
                });
              },
            ),
          ],
        ),
        if (_showSearch)
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Digite sua busca...',
                border: OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showSearch = false;
                      _searchController.clear();
                      // limpar filtro também
                      _fightersSearch = '';
                    });
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              onSubmitted: (value) {
                // Atualiza o termo de busca usado por FightesList
                setState(() {
                  _fightersSearch = value.trim();
                  _showSearch = false; // esconde o campo após submeter
                });
                FocusScope.of(context).unfocus();
              },
            ),
          ),
      ],
    );
  }
}
