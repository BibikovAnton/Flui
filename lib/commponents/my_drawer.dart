import 'package:chatty/services/auth/auth_services.dart';
import 'package:chatty/pages/settings_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    final _auth = AuthServices();

    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DrawerHeader(child: Icon(Icons.message)),
          Column(
            children: [
              ListTile(
                onTap: () => Navigator.pop(context),
                leading: Icon(Icons.home),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
                leading: Icon(Icons.settings),
              ),
            ],
          ),
          ListTile(onTap: () => logout(), leading: Icon(Icons.logout)),
        ],
      ),
    );
  }
}
