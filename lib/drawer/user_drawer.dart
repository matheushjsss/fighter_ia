import 'package:flutter/material.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({super.key});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  @override
  Widget build(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: Text('Name'),
      accountEmail: Text("Email"),
      currentAccountPicture: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Image.network(
          'https://scontent-gru2-2.xx.fbcdn.net/v/t39.30808-6/349946054_1303666526891286_2698394623608463310_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeE3h4t9W96LDg1PW4I3yd-SCb4ab5z_YfEJvhpvnP9h8QXWlZZG-ebRORf8mRuY4jBAgUgqpIS7o5YIQDpzthtC&_nc_ohc=9nZczJOL0ywQ7kNvwECslf0&_nc_oc=Admdore-iSxpsX4bCSzaDykoti-4psjGOQyejGF50Y22YjpuH_jnigkg7YwfpDjVxt3e_UZ80j1rZOlLKU5a1cgr&_nc_zt=23&_nc_ht=scontent-gru2-2.xx&_nc_gid=d4X6Y5vVDNtheLbrPUOGSw&oh=00_Afa0UJog-iod4MsxjjgSOQJW0tWjOgsSJv-GJ9htifUV7g&oe=68DE2D9C',
        ),
      ),
    );
  }
}
