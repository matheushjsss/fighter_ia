import 'package:fighter_ia/app_controller.dart';
import 'package:flutter/material.dart';

class SwitcherthemeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: AppController.instance.DartTheme,
      onChanged: (value) {
        AppController.instance.changeTheme();
      },
    );
  }
}
