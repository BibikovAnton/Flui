import 'package:Flui/core/shared/providers/auth_providers.dart';
import 'package:Flui/feature_chat/screens/blocked_users_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDrawer extends ConsumerWidget {
  MyDrawer({super.key});

  void logout(WidgetRef ref) {
    ref
        .read(authRepositoryProvider)
        .signOut(
          email: ref.read(authRepositoryProvider).getCurrentUser()!.email!,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authServiceProvider).currentUser;
    // final themeProvider = ref.watch(themeNotifierProvider);

    if (currentUser == null) {
      return const Drawer(child: Center(child: Text('Не авторизован')));
    }

    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(height: 11),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    onPressed: () {},
                    child: Text(
                      'Сохранить',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.040,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              const SizedBox(height: 40),

              StreamBuilder<DocumentSnapshot>(
                stream: ref
                    .read(userServiceProvider)
                    .rawUserStatusStream(currentUser.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final name =
                      userData['name'] ?? currentUser.email ?? 'Пользователь';
                  final initial = name.substring(0, 1).toUpperCase();
                  final email = userData['email'] ?? currentUser.email ?? '---';

                  return Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.35,
                            height: MediaQuery.of(context).size.width * 0.35,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: MediaQuery.of(context).size.width * 0.2,
                              backgroundImage: const AssetImage(
                                'assets/images/Code.png',
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height:
                                    MediaQuery.of(context).size.width * 0.25,
                                child: CircleAvatar(
                                  radius:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Text(
                                    initial,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 62),

              StreamBuilder<DocumentSnapshot>(
                stream: ref
                    .read(userServiceProvider)
                    .rawUserStatusStream(currentUser.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final name =
                      userData['name'] ?? currentUser.email ?? 'Пользователь';

                  return Column(
                    children: [
                      // CustomListTile(
                      //   icon: 'dark',
                      //   title: 'Dark Mode',
                      //   widgetTraling: CupertinoSwitch(
                      //     value: themeProvider.isDarkMode,
                      //     onChanged: (value) =>
                      //         ref.read(themeNotifierProvider.notifier).toggleTheme(),
                      //   ),
                      // ),
                      CustomListTile(
                        icon: 'surname',
                        title: 'Username',
                        widgetTraling: CupertinoButton(
                          child: Row(
                            children: [
                              Text(name),
                              const Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.only(top: 18, left: 16, bottom: 9),
                child: Row(
                  children: [
                    Text(
                      'Preferences'.toUpperCase(),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              CustomListTile(
                icon: 'noti',
                title: 'Notifications\n& Sounds',
                widgetTraling: CupertinoButton(
                  child: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {},
                ),
              ),
              CustomListTile(
                icon: 'del_people',
                title: 'People',
                widgetTraling: CupertinoButton(
                  child: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlockedUsersPage(),
                      ),
                    );
                  },
                ),
              ),
              ListTile(
                onTap: () => logout(ref),
                leading: const Icon(Icons.logout),
                title: const Text('Выйти'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.widgetTraling,
  });

  final String icon;
  final String title;
  final Widget widgetTraling;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/$icon.png',
                scale: MediaQuery.of(context).size.width * 0.009,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.042,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          widgetTraling,
        ],
      ),
    );
  }
}
