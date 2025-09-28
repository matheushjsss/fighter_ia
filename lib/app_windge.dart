import 'package:fighter_ia/app_controller.dart';
import 'package:fighter_ia/home_page.dart';
import 'package:fighter_ia/login_page.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, child) {
        return MaterialApp(
          initialRoute: '/home',
          routes: {
            '/': (context) => HomePage(),
            '/home': (context) => HomePage(),
          },
          theme: ThemeData(
            primaryColor: Colors.red,
            brightness: AppController.instance.DartTheme
                ? Brightness.light
                : Brightness.dark,
          ),
        );
      },
    );
  }
}
