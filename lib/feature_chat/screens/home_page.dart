import 'dart:async';
import 'package:Flui/commponents/my_divider.dart';
import 'package:Flui/core/shared/providers/chat_providers.dart';
import 'package:Flui/feature_chat/widgets/my_drawer.dart';
import 'package:Flui/feature_drawing/screens/drawing_board_page.dart';
import 'package:animation_search_bar/animation_search_bar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../services/chat/auth_services.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _updateUserOnlineStatus(true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _updateUserOnlineStatus(false);
    super.dispose();
  }

  Future<void> _updateUserOnlineStatus(bool isOnline) async {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final currentUser = authState.value;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Чаты'),
        actions: [
          _buildSearchBar(),
          if (currentUser != null) _buildUserAvatar(currentUser),
          const SizedBox(width: 10),
        ],
      ),
      drawer: MyDrawer(),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Пользователь не авторизован'));
          }
          return const UserList();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimationSearchBar(
      hintText: 'Поиск ...',
      cursorColor: Colors.grey,
      centerTitle: '',
      searchBarWidth: MediaQuery.of(context).size.width * 0.48,
      onChanged: (text) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          ref.read(searchQueryProvider.notifier).state = text;
        });
      },
      searchTextEditingController: _searchController,
      horizontalPadding: 5,
      isBackButtonVisible: false,
    );
  }

  Widget _buildUserAvatar(User user) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.11,
      height: MediaQuery.of(context).size.width * 0.11,
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.2,
        child: Text(
          user.email?.substring(0, 1).toUpperCase() ?? '?',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class UserList extends ConsumerWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatService = ref.read(chatServiceProvider.notifier);
    final searchQuery = ref.watch(searchQueryProvider);
    final currentUser = ref.watch(authServiceProvider).currentUser;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatService.getUsersStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];
        final filteredUsers =
            users.where((userData) {
              final name = userData['name']?.toString().toLowerCase() ?? '';
              final email = userData['email']?.toString().toLowerCase() ?? '';
              final query = searchQuery.toLowerCase();
              return (name.contains(query) || email.contains(query)) &&
                  userData['email'] != currentUser?.email;
            }).toList();

        if (filteredUsers.isEmpty) {
          return const Center(child: Text('Пользователи не найдены'));
        }

        return ListView.separated(
          itemCount: filteredUsers.length,
          itemBuilder:
              (context, index) => UserListItem(userData: filteredUsers[index]),
          separatorBuilder:
              (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.2,
                ),
                child: const MyDivider(),
              ),
        );
      },
    );
  }
}

class UserListItem extends ConsumerWidget {
  final Map<String, dynamic> userData;

  const UserListItem({super.key, required this.userData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = userData['uid'] as String?;
    if (userId == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final isOnline = data['isOnline'] as bool? ?? false;
        final lastSeen = data['lastSeen'] as Timestamp?;
        final userName = data['name'] as String? ?? 'Пользователь';
        final userEmail = data['email'] as String? ?? '';

        return Slidable(
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => _showDeleteDialog(context, ref, userId),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Удалить',
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          child: ListTile(
            subtitle: Row(
              children: [
                Text(userData['lastMessage']?.toString() ?? 'Нет сообщений'),
                const SizedBox(width: 5),
                Text(
                  lastSeen != null
                      ? DateFormat('HH:mm').format(lastSeen.toDate())
                      : '--:--',
                ),
              ],
            ),
            trailing: const Icon(
              Icons.check_circle_outline,
              color: Colors.grey,
              size: 24,
            ),
            title: Row(
              children: [
                _buildUserAvatar(userName, isOnline, context),
                const SizedBox(width: 12),
                Expanded(child: Text(userName)),
              ],
            ),
            onTap: () => _navigateToChat(context, userId, userName),
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(String name, bool isOnline, BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.07,
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.background,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Удалить чат?'),
            content: const Text('Чат будет скрыт для вас'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(chatServiceProvider.notifier)
                      .blockUser(userId);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _navigateToChat(BuildContext context, String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrawingScreen(receiverId: userId),
      ),
    );
  }
}

// Providers
final searchQueryProvider = StateProvider<String>((ref) => '');
