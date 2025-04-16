import 'package:chatty/pages/blocked_users_page.dart';
import 'package:chatty/theme/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Dark Mode'),
              CupertinoSwitch(
                value:
                    Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).isDarkMode,
                onChanged:
                    (value) =>
                        Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).toggleTheme(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Blocked Users'),
              IconButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlockedUsersPage(),
                      ),
                    ),
                icon: Icon(
                  Icons.arrow_forward_ios_sharp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
